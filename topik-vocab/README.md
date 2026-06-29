# topik-vocab

Tool thống kê tần suất từ vựng từ **đề thi TOPIK thật** (đề nghe + đề đọc) để học
theo thứ tự tần suất giảm dần — từ nào xuất hiện nhiều nhất trong các đề thật thì học trước.

Đây là project **độc lập**, không phụ thuộc app MemoX. Hiện đang nằm trong repo
`memox-v3` cho tiện commit; muốn tách ra repo riêng chỉ cần:

```bash
cp -r topik-vocab ~/topik-vocab && cd ~/topik-vocab && git init
```

## Pipeline (7 stage, mỗi stage chạy lại độc lập)

```
đề scan (ảnh/PDF)
  → [1] ingest    OCR tiếng Hàn (Claude vision hoặc Tesseract) → text thô / đề
  → [2] clean     bỏ số câu, hướng dẫn, tiếng Anh, romanization
  → [3] analyze   Kiwi: tách hình thái + đưa về NGUYÊN THỂ (먹었어요 → 먹다, 책을 → 책)
  → [4] count     gộp tần suất toàn bộ đề (total_freq + doc_freq)
  → [5] enrich    Claude: nghĩa tiếng Việt + cấp TOPIK + câu ví dụ
  → [6] export    CSV đầy đủ + CSV import thẳng MemoX (front,back)
```

Vì sao **không** dùng Claude để tokenize/lemmatize: tiếng Hàn chắp dính, cần phân tích
hình thái (형태소 분석). Việc này dùng **Kiwi** (deterministic, miễn phí, nhanh) thay vì
LLM. Claude chỉ dùng ở lớp **enrichment** (nghĩa/ví dụ/cấp độ) — nơi nó vượt trội.

## Cài đặt

```bash
cd topik-vocab
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt          # core: kiwipiepy
# OCR offline (tuỳ chọn): cần thêm gói hệ thống tesseract-ocr + tesseract-ocr-kor, poppler
# Claude OCR/enrich: export ANTHROPIC_API_KEY=sk-...
```

## Dùng (end-to-end)

```bash
# 1. Bỏ ảnh/PDF scan các đề vào data/raw/  (mỗi đề 1 file hoặc 1 thư mục con)
python -m topik_vocab ingest  --backend claude        # hoặc --backend tesseract
python -m topik_vocab clean
python -m topik_vocab analyze
python -m topik_vocab count                            # → xem data/interim/04_frequency.csv ngay
python -m topik_vocab enrich  --limit 1000             # chỉ enrich top N để tiết kiệm token
python -m topik_vocab export

# kết quả:
#   data/output/topik_vocab.csv     (đầy đủ: rank, lemma, pos, freq, doc_freq, nghĩa, cấp, ví dụ)
#   data/output/memox_import.csv    (2 cột front,back — import thẳng vào MemoX)
```

Chạy `python -m topik_vocab <stage> -h` để xem cờ từng stage.

## Cấu trúc

```
topik_vocab/
  cli.py        điều phối subcommand
  ingest.py     OCR ảnh/PDF → text  (Claude vision | Tesseract)
  clean.py      lọc nhiễu, giữ lại tiếng Hàn
  analyze.py    Kiwi: morpheme + POS + nguyên thể
  count.py      gộp tần suất + document frequency
  enrich.py     Claude: nghĩa VN, cấp TOPIK, ví dụ (batch, có cache)
  export.py     CSV đầy đủ + CSV MemoX
data/
  raw/          input (ảnh/PDF scan)        [gitignored]
  interim/      file trung gian mỗi stage   [gitignored]
  output/       CSV cuối                     [gitignored]
```

## Metric

- `total_freq` — tổng số lần xuất hiện qua tất cả đề (sắp xếp chính).
- `doc_freq` — số đề khác nhau có chứa từ (phân biệt "lặp nhiều trong 1 đề" vs "phổ
  biến khắp các đề"). Từ `doc_freq` cao = an toàn để ưu tiên học.
