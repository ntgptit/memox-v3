"""[3] analyze — Kiwi: tách hình thái, gắn POS, đưa về NGUYÊN THỂ.

Đây là bước cốt lõi giải quyết tính chắp dính của tiếng Hàn:
  먹었어요 / 먹고 / 먹는  → đều là  먹다   (động từ, nguyên thể + 다)
  책을 / 책이 / 책은      → đều là  책      (danh từ)

Chỉ giữ "từ nội dung" (danh/động/tính/phó từ); bỏ trợ từ (조사) và đuôi từ (어미)
vì chúng không phải từ vựng cần học.

Output: data/interim/03_tokens.jsonl — mỗi dòng {doc, lemma, pos, surface}.
"""

from __future__ import annotations

import json

from . import paths

# POS giữ lại (Kiwi/Sejong tagset). Có thể chỉnh qua --pos.
DEFAULT_KEEP_POS = {
    "NNG",  # danh từ chung
    "NNP",  # danh từ riêng
    "VV",   # động từ
    "VA",   # tính từ
    "MAG",  # phó từ
}
# Tag cần thêm 다 để thành nguyên thể (động/tính từ + bổ trợ).
_PREDICATE_TAGS = {"VV", "VA", "VX", "VCP", "VCN"}


def _lemma(form: str, tag: str) -> str:
    if tag in _PREDICATE_TAGS:
        return form + "다"
    return form


def run(keep_pos: set[str] | None = None, min_len: int = 1) -> None:
    try:
        from kiwipiepy import Kiwi  # lazy import
    except ImportError:
        raise SystemExit(
            "Thiếu kiwipiepy. Cài: pip install kiwipiepy  (xem requirements.txt)"
        )

    paths.ensure_dirs()
    keep = keep_pos or DEFAULT_KEEP_POS
    files = sorted(paths.CLEAN_TEXT.glob("*.txt"))
    if not files:
        print(f"⚠ Chưa có text sạch trong {paths.CLEAN_TEXT}. Chạy `clean` trước.")
        return

    kiwi = Kiwi()
    n = 0
    with paths.TOKENS.open("w", encoding="utf-8") as out:
        for src in files:
            doc = src.stem
            text = src.read_text(encoding="utf-8")
            for token in kiwi.tokenize(text):
                if token.tag not in keep:
                    continue
                if len(token.form) < min_len:
                    continue
                lemma = _lemma(token.form, token.tag)
                out.write(
                    json.dumps(
                        {"doc": doc, "lemma": lemma, "pos": token.tag,
                         "surface": token.form},
                        ensure_ascii=False,
                    )
                    + "\n"
                )
                n += 1
            print(f"• analyze {doc}")
    print(f"✓ analyze xong: {n} token → {paths.TOKENS}")
