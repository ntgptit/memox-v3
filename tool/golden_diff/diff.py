"""golden_diff -- pixel-diff a Flutter golden/screenshot against a UI-kit mock shot.

Gives agents WITHOUT vision a text feedback loop for visual parity: run the app
screen (flutter golden test / integration screenshot), then compare against the
canonical mock PNG under docs/system-design/MemoX Design System/ui_kits/mobile/shots/.
Output is text an agent can act on: mismatch %, bounding box of the differing
region (cross-reference it with the element bboxes in .../specs/NN-*.md), and an
optional heat-map PNG for humans.

Usage:
  python tool/golden_diff/diff.py <actual.png> <expected.png> [--out heatmap.png]
                                  [--threshold 5.0] [--tolerance 16]

  --threshold  max allowed mismatch percent before exit code 1 (default 5.0)
  --tolerance  per-channel delta treated as equal (default 16; absorbs
               anti-aliasing/font-hinting differences between renderers)

Exit codes: 0 = within threshold, 1 = mismatch above threshold, 2 = usage/IO error.
Sizes may differ (Flutter logical px vs 390px mock): the actual image is resized
to the expected size before comparison; layout shifts still show up as diffs.
"""

import argparse
import sys

try:
    from PIL import Image, ImageChops
except ImportError:  # pragma: no cover
    print("Pillow is required: pip install Pillow", file=sys.stderr)
    sys.exit(2)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("actual")
    ap.add_argument("expected")
    ap.add_argument("--out", help="write a diff heat-map PNG here")
    ap.add_argument("--threshold", type=float, default=5.0)
    ap.add_argument("--tolerance", type=int, default=16)
    args = ap.parse_args()

    try:
        actual = Image.open(args.actual).convert("RGB")
        expected = Image.open(args.expected).convert("RGB")
    except OSError as e:
        print(f"cannot open image: {e}", file=sys.stderr)
        return 2

    if actual.size != expected.size:
        print(f"note: resizing actual {actual.size} -> expected {expected.size}")
        actual = actual.resize(expected.size, Image.LANCZOS)

    diff = ImageChops.difference(actual, expected)
    # Per-pixel max channel delta, thresholded by tolerance.
    gray = diff.convert("L")
    mask = gray.point(lambda v, t=args.tolerance: 255 if v > t else 0)

    histogram = mask.histogram()
    total = expected.size[0] * expected.size[1]
    changed = total - histogram[0]
    pct = 100.0 * changed / total

    bbox = mask.getbbox()
    print(f"mismatch: {pct:.2f}% ({changed}/{total} px, tolerance={args.tolerance})")
    if bbox:
        x0, y0, x1, y1 = bbox
        print(f"diff region: [{x0},{y0} {x1 - x0}x{y1 - y0}] "
              f"(compare with element bboxes in ui_kits/mobile/specs/)")
    else:
        print("diff region: none")

    if args.out and bbox:
        heat = expected.copy()
        red = Image.new("RGB", expected.size, (220, 30, 60))
        heat.paste(red, mask=mask)
        heat.save(args.out)
        print(f"heat-map written: {args.out}")

    if pct > args.threshold:
        print(f"FAIL: mismatch {pct:.2f}% > threshold {args.threshold}%")
        return 1
    print(f"PASS: mismatch {pct:.2f}% <= threshold {args.threshold}%")
    return 0


if __name__ == "__main__":
    sys.exit(main())
