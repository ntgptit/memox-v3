"""Đường dẫn chuẩn cho các stage. Mỗi stage đọc output stage trước, ghi output của mình."""

from __future__ import annotations

from pathlib import Path

# Gốc project = thư mục chứa package (topik-vocab/).
ROOT = Path(__file__).resolve().parent.parent

DATA = ROOT / "data"
RAW = DATA / "raw"                       # [1] input: ảnh/PDF scan
INTERIM = DATA / "interim"
OUTPUT = DATA / "output"

RAW_TEXT = INTERIM / "01_raw_text"       # [1] ingest → text thô mỗi đề
CLEAN_TEXT = INTERIM / "02_clean"        # [2] clean
TOKENS = INTERIM / "03_tokens.jsonl"     # [3] analyze (1 dòng JSON / token)
FREQUENCY = INTERIM / "04_frequency.csv" # [4] count
FREQUENCY_JSON = INTERIM / "04_frequency.json"
ENRICHED = INTERIM / "05_enriched.json"  # [5] enrich
ENRICH_CACHE = INTERIM / "05_enrich_cache.json"

OUT_FULL = OUTPUT / "topik_vocab.csv"    # [6] export đầy đủ
OUT_MEMOX = OUTPUT / "memox_import.csv"  # [6] export 2 cột front,back


def ensure_dirs() -> None:
    for d in (RAW, INTERIM, OUTPUT, RAW_TEXT, CLEAN_TEXT):
        d.mkdir(parents=True, exist_ok=True)
