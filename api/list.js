// Vercel 서버리스 함수 - 판매 데이터 읽기. 목록(전체)과 단건(?id=N)을 겸한다.
// 키는 코드에 쓰지 않는다. Vercel 환경변수(SUPABASE_URL, SUPABASE_ANON_KEY)에서 읽는다.
import { createClient } from "@supabase/supabase-js";

export default async function handler(req, res) {
  const t0 = Date.now();
  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
  const id = req.query.id;

  try {
    if (id) {
      const { data, error } = await supabase
        .from("sales")
        .select("*")
        .eq("id", id)
        .single();
      if (error) throw error;
      console.log(JSON.stringify({ route: "detail", id, duration_ms: Date.now() - t0 }));
      return res.status(200).json(data);
    }
    const { data, error } = await supabase
      .from("sales")
      .select("*")
      .order("purchased_at", { ascending: false });
    if (error) throw error;
    console.log(JSON.stringify({ route: "list", count: data.length, duration_ms: Date.now() - t0 }));
    return res.status(200).json(data);
  } catch (e) {
    console.log(JSON.stringify({ route: id ? "detail" : "list", error: e.message, duration_ms: Date.now() - t0 }));
    return res.status(500).json({ error: "읽기에 실패했습니다" });
  }
}
