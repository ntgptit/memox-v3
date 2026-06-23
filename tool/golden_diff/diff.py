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
                                  [--spec <specfile.md>] [--top 15]

  --threshold  max allowed mismatch percent before exit code 1 (default 5.0)
  --tolerance  per-channel delta treated as equal (default 16; absorbs
               anti-aliasing/font-hinting differences between renderers)
  --spec       a UI-kit DOM spec (specs/NN-*.md): report PER-ELEMENT mismatch by
               cropping each node's abs bbox, so a divergence is localized to a
               node ("list-row-meta 18%") instead of the whole frame.
  --top        with --spec, how many most-divergent nodes to print (default 15)

Exit codes: 0 = within threshold, 1 = mismatch above threshold, 2 = usage/IO error.
Sizes may differ (Flutter logical px vs 390px mock): the actual image is resized
to the expected size before comparison; layout shifts still show up as diffs.
"""

import argparse
import re
import sys

try:
    from PIL import Image, ImageChops
except ImportError:  # pragma: no cover
    print("Pillow is required: pip install Pillow", file=sys.stderr)
    sys.exit(2)

_ABS = re.compile(r"abs:\s*\[(\d+),(\d+)\s+(\d+)x(\d+)\]")
_NODE = re.compile(r"node:\s*(\S+)")
_TEXT = re.compile(r"text:\s*(.+?)\s*$")


def region_pct(actual, expected, box, tolerance):
    """Mismatch % inside one bbox (clamped to image bounds)."""
    w, h = expected.size
    x0, y0, x1, y1 = box
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(w, x1), min(h, y1)
    if x1 <= x0 or y1 <= y0:
        return None
    a = actual.crop((x0, y0, x1, y1))
    e = expected.crop((x0, y0, x1, y1))
    gray = ImageChops.difference(a, e).convert("L")
    mask = gray.point(lambda v, t=tolerance: 255 if v > t else 0)
    total = (x1 - x0) * (y1 - y0)
    changed = total - mask.histogram()[0]
    return 100.0 * changed / total


def parse_spec_boxes(path):
    """Yield (label, x, y, w, h) for every node with an abs bbox in the spec."""
    boxes = []
    label = "?"
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except OSError as e:
        print(f"cannot open spec: {e}", file=sys.stderr)
        return boxes
    for line in lines:
        s = line.strip().lstrip("+-").strip()
        n = _NODE.match(s)
        if n:
            label = n.group(1)
        else:
            t = _TEXT.match(s)
            if t and s.startswith("text:"):
                label = '"' + t.group(1)[:20] + '"'
        a = _ABS.search(s)
        if a:
            x, y, w, h = (int(v) for v in a.groups())
            boxes.append((label, x, y, w, h))
    return boxes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("actual")
    ap.add_argument("expected")
    ap.add_argument("--out", help="write a diff heat-map PNG here")
    ap.add_argument("--threshold", type=float, default=5.0)
    ap.add_argument("--tolerance", type=int, default=16)
    ap.add_argument("--spec", help="DOM spec for per-element diff")
    ap.add_argument("--top", type=int, default=15)
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

    if args.spec:
        rows = []
        for label, x, y, w, h in parse_spec_boxes(args.spec):
            rp = region_pct(actual, expected, (x, y, x + w, y + h), args.tolerance)
            if rp is not None:
                rows.append((rp, label, x, y, w, h))
        rows.sort(reverse=True)
        print(f"\nper-element (top {args.top} of {len(rows)} nodes, by mismatch%):")
        for rp, label, x, y, w, h in rows[: args.top]:
            print(f"  {rp:6.2f}%  {label:24} [{x},{y} {w}x{h}]")

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
