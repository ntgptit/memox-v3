"""Điều phối CLI: python -m topik_vocab <stage> [tuỳ chọn].

Stage theo thứ tự: ingest → clean → analyze → count → enrich → export.
Mỗi stage độc lập, đọc output stage trước.
"""

from __future__ import annotations

import argparse
import sys


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="topik_vocab",
        description="Thống kê tần suất từ vựng đề TOPIK để học theo tần suất giảm dần.",
    )
    sub = p.add_subparsers(dest="stage", required=True)

    sp = sub.add_parser("ingest", help="[1] OCR ảnh/PDF scan → text")
    sp.add_argument("--backend", choices=["claude", "tesseract"], default="claude")
    sp.add_argument("--model", default=None, help="model vision (mặc định sonnet)")

    sub.add_parser("clean", help="[2] lọc nhiễu, giữ tiếng Hàn")

    sp = sub.add_parser("analyze", help="[3] Kiwi: hình thái + nguyên thể")
    sp.add_argument("--pos", default=None,
                    help="POS giữ lại, phẩy ngăn cách (vd: NNG,NNP,VV,VA,MAG)")
    sp.add_argument("--min-len", type=int, default=1, help="độ dài lemma tối thiểu")

    sub.add_parser("count", help="[4] gộp tần suất + doc_freq")

    sp = sub.add_parser("enrich", help="[5] Claude: nghĩa VN + cấp + ví dụ")
    sp.add_argument("--limit", type=int, default=None, help="chỉ enrich top N")
    sp.add_argument("--model", default=None, help="model (mặc định haiku)")
    sp.add_argument("--batch-size", type=int, default=None)

    sub.add_parser("export", help="[6] xuất CSV đầy đủ + CSV MemoX")
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    if args.stage == "ingest":
        from . import ingest
        ingest.run(backend=args.backend,
                   model=args.model or ingest.DEFAULT_VISION_MODEL)
    elif args.stage == "clean":
        from . import clean
        clean.run()
    elif args.stage == "analyze":
        from . import analyze
        keep = set(args.pos.split(",")) if args.pos else None
        analyze.run(keep_pos=keep, min_len=args.min_len)
    elif args.stage == "count":
        from . import count
        count.run()
    elif args.stage == "enrich":
        from . import enrich
        kwargs = {"limit": args.limit}
        if args.model:
            kwargs["model"] = args.model
        if args.batch_size:
            kwargs["batch_size"] = args.batch_size
        enrich.run(**kwargs)
    elif args.stage == "export":
        from . import export
        export.run()
    return 0


if __name__ == "__main__":
    sys.exit(main())
