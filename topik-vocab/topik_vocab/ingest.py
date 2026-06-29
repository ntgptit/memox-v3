"""[1] ingest — OCR ảnh/PDF scan đề TOPIK → text thô, mỗi đề một file .txt.

Mỗi "đề" = một file ảnh/PDF trong data/raw/, HOẶC một thư mục con chứa nhiều trang.
Tên file/thư mục được giữ làm doc id (dùng cho document-frequency ở stage count).

Hai backend OCR:
  - claude    : Claude vision — đọc tốt layout đề thi tiếng Hàn (cần ANTHROPIC_API_KEY).
  - tesseract : offline, cần gói hệ thống tesseract-ocr + tesseract-ocr-kor + poppler.
"""

from __future__ import annotations

import base64
import os
from pathlib import Path

from . import paths

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff"}
PDF_EXTS = {".pdf"}

# Model vision mặc định cho OCR (đủ mạnh cho chữ Hàn, rẻ hơn opus).
DEFAULT_VISION_MODEL = "claude-sonnet-4-6"

_OCR_PROMPT = (
    "Đây là một trang đề thi TOPIK tiếng Hàn. Hãy trích xuất TOÀN BỘ văn bản tiếng Hàn "
    "đúng nguyên văn, giữ thứ tự đọc. CHỈ xuất text, không giải thích, không dịch, "
    "không thêm số thứ tự câu nếu ảnh không có."
)


def _iter_exam_sources(raw_dir: Path):
    """Trả về (doc_id, [danh sách file trang]) cho từng đề."""
    for entry in sorted(raw_dir.iterdir()):
        if entry.is_dir():
            pages = sorted(
                p for p in entry.iterdir() if p.suffix.lower() in IMAGE_EXTS | PDF_EXTS
            )
            if pages:
                yield entry.name, pages
        elif entry.suffix.lower() in IMAGE_EXTS | PDF_EXTS:
            yield entry.stem, [entry]


def _pdf_to_images(pdf: Path):
    from pdf2image import convert_from_path  # lazy import

    return convert_from_path(str(pdf), dpi=300)


# ---- backend: claude vision -------------------------------------------------

def _ocr_claude_image_bytes(client, model: str, data: bytes, media_type: str) -> str:
    b64 = base64.standard_b64encode(data).decode("ascii")
    msg = client.messages.create(
        model=model,
        max_tokens=4096,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": b64,
                        },
                    },
                    {"type": "text", "text": _OCR_PROMPT},
                ],
            }
        ],
    )
    return "".join(block.text for block in msg.content if block.type == "text")


def _ocr_claude(pages, model: str) -> str:
    from anthropic import Anthropic  # lazy import

    client = Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    chunks: list[str] = []
    for page in pages:
        if page.suffix.lower() in PDF_EXTS:
            for img in _pdf_to_images(page):
                import io

                buf = io.BytesIO()
                img.save(buf, format="PNG")
                chunks.append(
                    _ocr_claude_image_bytes(client, model, buf.getvalue(), "image/png")
                )
        else:
            media = "image/jpeg" if page.suffix.lower() in {".jpg", ".jpeg"} else "image/png"
            chunks.append(
                _ocr_claude_image_bytes(client, model, page.read_bytes(), media)
            )
    return "\n".join(chunks)


# ---- backend: tesseract -----------------------------------------------------

def _ocr_tesseract(pages) -> str:
    import pytesseract  # lazy import
    from PIL import Image

    chunks: list[str] = []
    for page in pages:
        if page.suffix.lower() in PDF_EXTS:
            for img in _pdf_to_images(page):
                chunks.append(pytesseract.image_to_string(img, lang="kor"))
        else:
            chunks.append(pytesseract.image_to_string(Image.open(page), lang="kor"))
    return "\n".join(chunks)


def run(backend: str = "claude", model: str = DEFAULT_VISION_MODEL) -> None:
    paths.ensure_dirs()
    sources = list(_iter_exam_sources(paths.RAW))
    if not sources:
        print(f"⚠ Không tìm thấy đề nào trong {paths.RAW}. Bỏ ảnh/PDF scan vào đó.")
        return

    for doc_id, pages in sources:
        out = paths.RAW_TEXT / f"{doc_id}.txt"
        if out.exists():
            print(f"• {doc_id}: đã có, bỏ qua (xoá file nếu muốn OCR lại)")
            continue
        print(f"• OCR [{backend}] {doc_id} ({len(pages)} trang)…")
        text = _ocr_claude(pages, model) if backend == "claude" else _ocr_tesseract(pages)
        out.write_text(text, encoding="utf-8")
    print(f"✓ ingest xong → {paths.RAW_TEXT}")
