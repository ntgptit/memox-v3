"""[5] enrich — Claude bổ sung nghĩa tiếng Việt + cấp TOPIK + câu ví dụ.

Đây là chỗ DUY NHẤT dùng LLM trong pipeline (tokenize/lemmatize đã do Kiwi lo).
Gọi theo BATCH (mặc định 40 từ/lần) để tiết kiệm token, có CACHE theo (lemma,pos)
nên chạy lại không tốn tiền cho từ đã enrich. Dùng `--limit N` để chỉ enrich top N.

Model mặc định: claude-haiku-4-5 (rẻ, đủ cho gloss từ vựng).
"""

from __future__ import annotations

import json
import os

from . import paths

DEFAULT_MODEL = "claude-haiku-4-5"
BATCH_SIZE = 40

_SYSTEM = (
    "Bạn là từ điển Hàn–Việt cho người luyện thi TOPIK. Với mỗi từ tiếng Hàn (đã ở "
    "dạng nguyên thể), trả về nghĩa tiếng Việt ngắn gọn, cấp độ TOPIK ước lượng "
    "(1-6), và một câu ví dụ tiếng Hàn ngắn kèm dịch. Trả về DUY NHẤT một JSON array, "
    "không markdown, không giải thích thêm."
)

_USER_TMPL = (
    "Danh sách từ (lemma | POS):\n{items}\n\n"
    "Trả JSON array, mỗi phần tử: "
    '{{"lemma": "...", "meaning_vi": "...", "topik_level": 1-6, '
    '"example_ko": "...", "example_vi": "..."}}. '
    "Giữ đúng lemma đã cho. Nếu là từ chức năng không có nghĩa từ vựng, "
    'meaning_vi để "" và topik_level để null.'
)


def _load_cache() -> dict:
    if paths.ENRICH_CACHE.exists():
        return json.loads(paths.ENRICH_CACHE.read_text(encoding="utf-8"))
    return {}


def _save_cache(cache: dict) -> None:
    paths.ENRICH_CACHE.write_text(
        json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8"
    )


def _enrich_batch(client, model: str, batch: list[dict]) -> list[dict]:
    items = "\n".join(f"{r['lemma']} | {r['pos']}" for r in batch)
    msg = client.messages.create(
        model=model,
        max_tokens=4096,
        system=_SYSTEM,
        messages=[{"role": "user", "content": _USER_TMPL.format(items=items)}],
    )
    text = "".join(b.text for b in msg.content if b.type == "text").strip()
    # Bóc JSON array dù model có lỡ bọc ```.
    start, end = text.find("["), text.rfind("]")
    if start == -1 or end == -1:
        raise ValueError(f"Không parse được JSON từ model:\n{text[:300]}")
    return json.loads(text[start : end + 1])


def run(limit: int | None = None, model: str = DEFAULT_MODEL,
        batch_size: int = BATCH_SIZE) -> None:
    try:
        from anthropic import Anthropic  # lazy import
    except ImportError:
        raise SystemExit("Thiếu anthropic. Cài: pip install anthropic")
    if "ANTHROPIC_API_KEY" not in os.environ:
        raise SystemExit("Cần export ANTHROPIC_API_KEY=sk-...")
    if not paths.FREQUENCY_JSON.exists():
        print(f"⚠ Chưa có {paths.FREQUENCY_JSON}. Chạy `count` trước.")
        return

    records = json.loads(paths.FREQUENCY_JSON.read_text(encoding="utf-8"))
    if limit:
        records = records[:limit]

    cache = _load_cache()
    client = Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

    todo = [r for r in records if f"{r['lemma']}|{r['pos']}" not in cache]
    print(f"• {len(records)} từ cần enrich, {len(todo)} chưa có trong cache.")

    for i in range(0, len(todo), batch_size):
        batch = todo[i : i + batch_size]
        try:
            result = _enrich_batch(client, model, batch)
        except Exception as e:  # batch lỗi không làm hỏng cả run
            print(f"  ⚠ batch {i // batch_size} lỗi: {e}")
            continue
        by_lemma = {r.get("lemma"): r for r in result}
        for rec in batch:
            g = by_lemma.get(rec["lemma"], {})
            cache[f"{rec['lemma']}|{rec['pos']}"] = {
                "meaning_vi": g.get("meaning_vi", ""),
                "topik_level": g.get("topik_level"),
                "example_ko": g.get("example_ko", ""),
                "example_vi": g.get("example_vi", ""),
            }
        _save_cache(cache)  # lưu sau mỗi batch (resume-safe)
        print(f"  • enrich {min(i + batch_size, len(todo))}/{len(todo)}")

    enriched = []
    for r in records:
        g = cache.get(f"{r['lemma']}|{r['pos']}", {})
        enriched.append({**r, **g})
    paths.ENRICHED.write_text(
        json.dumps(enriched, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"✓ enrich xong → {paths.ENRICHED}")
