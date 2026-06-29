"""[2] clean — lọc nhiễu khỏi text OCR, giữ lại tiếng Hàn để thống kê.

Bỏ: số thứ tự câu, đáp án ①②③④, ký tự Latin/số, romanization, ký hiệu thừa.
Giữ: Hangul + dấu câu cơ bản (để Kiwi tách câu tốt hơn).
"""

from __future__ import annotations

import re

from . import paths

# Hangul âm tiết + jamo.
_HANGUL = r"가-힣ᄀ-ᇿ㄰-㆏"
# Giữ Hangul, khoảng trắng, và vài dấu câu để Kiwi ngắt câu.
_KEEP = re.compile(rf"[^{_HANGUL}\s.\?!,]")
# Vòng tròn đáp án trắc nghiệm.
_CHOICE_MARKS = re.compile(r"[①②③④⑤⑥]")
_MULTISPACE = re.compile(r"[ \t]+")
_MULTINL = re.compile(r"\n{3,}")


def clean_text(text: str) -> str:
    text = _CHOICE_MARKS.sub(" ", text)
    text = _KEEP.sub(" ", text)          # mọi thứ không phải Hangul/dấu → space
    text = _MULTISPACE.sub(" ", text)
    text = _MULTINL.sub("\n\n", text)
    # Bỏ dòng không còn Hangul.
    lines = [ln.strip() for ln in text.splitlines()]
    lines = [ln for ln in lines if re.search(rf"[{_HANGUL}]", ln)]
    return "\n".join(lines).strip()


def run() -> None:
    paths.ensure_dirs()
    files = sorted(paths.RAW_TEXT.glob("*.txt"))
    if not files:
        print(f"⚠ Chưa có text thô trong {paths.RAW_TEXT}. Chạy `ingest` trước.")
        return
    for src in files:
        cleaned = clean_text(src.read_text(encoding="utf-8"))
        (paths.CLEAN_TEXT / src.name).write_text(cleaned, encoding="utf-8")
        print(f"• clean {src.stem}")
    print(f"✓ clean xong → {paths.CLEAN_TEXT}")
