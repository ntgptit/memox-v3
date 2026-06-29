"""[4] count — gộp tần suất lemma toàn bộ đề.

Hai metric:
  total_freq — tổng số lần xuất hiện qua tất cả đề (sắp xếp chính).
  doc_freq   — số ĐỀ khác nhau có chứa lemma (phân biệt "lặp nhiều trong 1 đề"
               với "phổ biến khắp các đề" — doc_freq cao = ưu tiên học an toàn).

Output: 04_frequency.csv (xem được ngay) + 04_frequency.json (cho stage enrich/export).
"""

from __future__ import annotations

import csv
import json
from collections import Counter, defaultdict

from . import paths


def run() -> None:
    paths.ensure_dirs()
    if not paths.TOKENS.exists():
        print(f"⚠ Chưa có {paths.TOKENS}. Chạy `analyze` trước.")
        return

    total: Counter[tuple[str, str]] = Counter()    # (lemma, pos) → tần suất
    docs: defaultdict[tuple[str, str], set[str]] = defaultdict(set)

    with paths.TOKENS.open(encoding="utf-8") as f:
        for line in f:
            row = json.loads(line)
            key = (row["lemma"], row["pos"])
            total[key] += 1
            docs[key].add(row["doc"])

    # Sắp xếp: total_freq giảm dần, rồi doc_freq giảm dần, rồi lemma.
    items = sorted(
        total.items(),
        key=lambda kv: (-kv[1], -len(docs[kv[0]]), kv[0][0]),
    )

    records = []
    for rank, ((lemma, pos), freq) in enumerate(items, start=1):
        records.append(
            {
                "rank": rank,
                "lemma": lemma,
                "pos": pos,
                "total_freq": freq,
                "doc_freq": len(docs[(lemma, pos)]),
            }
        )

    with paths.FREQUENCY.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["rank", "lemma", "pos", "total_freq", "doc_freq"])
        w.writeheader()
        w.writerows(records)
    paths.FREQUENCY_JSON.write_text(
        json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print(f"✓ count xong: {len(records)} lemma duy nhất → {paths.FREQUENCY}")
    if records:
        print("  Top 10:")
        for r in records[:10]:
            print(f"    {r['rank']:>3}. {r['lemma']:<10} {r['pos']:<4} "
                  f"freq={r['total_freq']:<4} docs={r['doc_freq']}")
