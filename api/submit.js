// Vercel 서버리스 함수 - 커피 주문 1건을 sales 표에 저장한다.
// 키는 코드에 쓰지 않는다. Vercel 환경변수(SUPABASE_URL, SUPABASE_ANON_KEY)에서 읽는다.
import { createClient } from "@supabase/supabase-js";

const PRICES = { "아메리카노": 3000, "카페라떼": 4000, "율무차": 3500, "코코아": 4000, "우유": 2500 };

export default async function handler(req, res) {
  const t0 = Date.now();

  if (req.method !== "POST") return res.status(405).json({ error: "POST만 받습니다" });

  const { buyer_name, product, quantity } = req.body || {};
  if (!buyer_name || !product) {
    return res.status(400).json({ error: "buyer_name, product가 필요합니다" });
  }
  const qty = Number(quantity) > 0 ? Number(quantity) : 1;
  const unit = PRICES[product] || 3000;

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
  try {
    const { error } = await supabase.from("sales").insert({
      buyer_name,
      product,
      quantity: qty,
      price_per_unit: unit,
      total_price: unit * qty,
    });
    if (error) throw error;
    console.log(JSON.stringify({ route: "submit", product, qty, duration_ms: Date.now() - t0 }));
    return res.status(200).json({ ok: true });
  } catch (e) {
    console.log(JSON.stringify({ route: "submit", error: e.message, duration_ms: Date.now() - t0 }));
    return res.status(500).json({ error: "저장에 실패했습니다: " + e.message });
  }
}
