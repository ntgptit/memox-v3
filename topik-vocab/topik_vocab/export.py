"""[6] export — xuất 2 file:

  topik_vocab.csv  — đầy đủ: rank, lemma, pos, total_freq, doc_freq, nghĩa, cấp, ví dụ.
  memox_import.csv — 2 cột front,back để import THẲNG vào MemoX (parser đọc front/back,
                     cột thừa bị bỏ qua nên file đầy đủ cũng import được, nhưng file gọn
                     này cho thẻ sạch hơn).

front = từ tiếng Hàn (lemma). back = nghĩa Việt + cấp TOPIK + ví dụ (gộp 1 mặt sau).
"""

from __future__ import annotations

import csv
import json

from . import paths


def _load_records() -> list[dict]:
    if paths.ENRICHED.exists():
        return json.loads(paths.ENRICHED.read_text(encoding="utf-8"))
    if paths.FREQUENCY_JSON.exists():
        print("ℹ Chưa chạy enrich — export không có nghĩa/ví dụ (chỉ tần suất).")
        return json.loads(paths.FREQUENCY_JSON.read_text(encoding="utf-8"))
    raise SystemExit("Chưa có dữ liệu. Chạy `count` (và `enrich`) trước.")


def _back(r: dict) -> str:
    parts = []
    if r.get("meaning_vi"):
        parts.append(r["meaning_vi"])
    if r.get("topik_level"):
        parts.append(f"[TOPIK {r['topik_level']}]")
    if r.get("example_ko"):
        ex = r["example_ko"]
        if r.get("example_vi"):
            ex += f" ({r['example_vi']})"
        parts.append(ex)
    return " — ".join(parts) if parts else r["pos"]


def run() -> None:
    paths.ensure_dirs()
    records = _load_records()

    full_cols = ["rank", "lemma", "pos", "total_freq", "doc_freq",
                 "meaning_vi", "topik_level", "example_ko", "example_vi"]
    with paths.OUT_FULL.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=full_cols, extrasaction="ignore")
        w.writeheader()
        for r in records:
            w.writerow(r)

    # MemoX: chỉ thẻ có front (lemma) hợp lệ; back rỗng thì dùng POS để không vi phạm
    # "back required after trim" của parser.
    with paths.OUT_MEMOX.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["front", "back"])
        kept = 0
        for r in records:
            front = (r.get("lemma") or "").strip()
            back = _back(r).strip()
            if not front or not back:
                continue
            w.writerow([front, back])
            kept += 1

    print(f"✓ export xong:")
    print(f"  • {paths.OUT_FULL}  ({len(records)} từ)")
    print(f"  • {paths.OUT_MEMOX}  ({kept} thẻ MemoX)")
