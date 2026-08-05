-- spec_ref: 주차나선 SOT §9 D13 + 한얼 260804 확정(오전=상세 라우트, 오후=규칙판, day13-starter 독립실행)
-- Day13 통합판 - Supabase SQL Editor에 통째로 붙여넣고 Run 한 번.
-- 어제(Day12) 이미 만든 분도 그대로 실행해도 안전합니다 (있으면 건너뛰고, 샘플은 비어 있을 때만 넣습니다).

-- [1] 판매 표 만들기 (어제 커피 SQL과 같은 구조)
create table if not exists sales (
  id bigint generated always as identity primary key,
  buyer_name text not null,
  product text not null,
  quantity int not null default 1,
  price_per_unit int not null,
  total_price int not null,
  purchased_at timestamptz not null default now()
);
alter table sales enable row level security;

-- [2] 정책: 넣기(insert)와 읽기(select) 둘 다 허용 - 어제 배운 두 정책입니다.
drop policy if exists "anon insert" on sales;
create policy "anon insert" on sales
  for insert to anon with check (true);
drop policy if exists "anon select" on sales;
create policy "anon select" on sales
  for select to anon using (true);

-- [3] 샘플 판매 데이터 (표가 비어 있을 때만 들어갑니다 - 중복 없음)
--     날짜가 "실행 시점 기준 최근 3일"로 들어가서 언제 실행해도 일별 매출 실습이 됩니다.
insert into sales (buyer_name, product, quantity, price_per_unit, total_price, purchased_at)
select * from (values
  ('김하늘', '카페라떼',   1, 4000, 4000,  now() - interval '10 minutes'),
  ('이준서', '아메리카노', 2, 3000, 6000,  now() - interval '1 hour'),
  ('박서연', '코코아',     1, 4000, 4000,  now() - interval '2 hours'),
  ('최민준', '아메리카노', 1, 3000, 3000,  now() - interval '3 hours'),
  ('정예린', '율무차',     2, 3500, 7000,  now() - interval '4 hours'),
  ('한도윤', '우유',       1, 2500, 2500,  now() - interval '5 hours'),
  ('오시우', '카페라떼',   2, 4000, 8000,  now() - interval '6 hours'),
  ('임하린', '아메리카노', 3, 3000, 9000,  now() - interval '7 hours'),
  ('서지호', '코코아',     1, 4000, 4000,  now() - interval '8 hours'),
  ('문가은', '아메리카노', 2, 3000, 6000,  now() - interval '9 hours'),
  ('김하늘', '아메리카노', 1, 3000, 3000,  now() - interval '1 day'),
  ('이준서', '율무차',     1, 3500, 3500,  now() - interval '1 day 1 hour'),
  ('박서연', '카페라떼',   2, 4000, 8000,  now() - interval '1 day 2 hours'),
  ('최민준', '우유',       2, 2500, 5000,  now() - interval '1 day 3 hours'),
  ('정예린', '아메리카노', 1, 3000, 3000,  now() - interval '1 day 4 hours'),
  ('한도윤', '코코아',     2, 4000, 8000,  now() - interval '1 day 5 hours'),
  ('오시우', '아메리카노', 1, 3000, 3000,  now() - interval '1 day 6 hours'),
  ('임하린', '카페라떼',   1, 4000, 4000,  now() - interval '1 day 7 hours'),
  ('서지호', '율무차',     2, 3500, 7000,  now() - interval '1 day 8 hours'),
  ('문가은', '우유',       1, 2500, 2500,  now() - interval '1 day 9 hours'),
  ('김하늘', '코코아',     1, 4000, 4000,  now() - interval '2 days'),
  ('이준서', '아메리카노', 2, 3000, 6000,  now() - interval '2 days 1 hour'),
  ('박서연', '아메리카노', 1, 3000, 3000,  now() - interval '2 days 2 hours'),
  ('최민준', '카페라떼',   1, 4000, 4000,  now() - interval '2 days 3 hours'),
  ('정예린', '코코아',     2, 4000, 8000,  now() - interval '2 days 4 hours'),
  ('한도윤', '아메리카노', 1, 3000, 3000,  now() - interval '2 days 5 hours'),
  ('오시우', '율무차',     1, 3500, 3500,  now() - interval '2 days 6 hours'),
  ('임하린', '우유',       2, 2500, 5000,  now() - interval '2 days 7 hours'),
  ('서지호', '카페라떼',   1, 4000, 4000,  now() - interval '2 days 8 hours'),
  ('문가은', '아메리카노', 1, 3000, 3000,  now() - interval '2 days 9 hours')
) as sample(buyer_name, product, quantity, price_per_unit, total_price, purchased_at)
where not exists (select 1 from sales);

-- 참고: 새 칸을 추가할 때는 not null을 붙이지 않습니다.
--   좋은 예: alter table sales add column memo text;
--   피할 예: alter table sales add column memo text not null;  <- 빈 값이 오면 넣기가 실패(500)합니다
