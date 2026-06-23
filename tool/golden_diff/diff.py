"""golden_diff -- compare a Flutter golden/screenshot against a UI-kit mock shot.

Gives agents WITHOUT vision a text feedback loop for visual parity: run the app
screen (flutter golden test / integration screenshot), then compare against the
canonical mock PNG under docs/system-design/MemoX Design System/ui_kits/mobile/shots/.
Output is text an agent can act on: a per-pixel mismatch %, the bounding box of the
differing region (cross-reference it with the element bboxes in .../specs/NN-*.md),
an optional structural-similarity (SSIM) score, and optional heat-map PNGs.

Two metrics, different jobs:
  - PIXEL mismatch % (Pillow): "how many pixels differ" — sensitive to any shift.
  - SSIM (scikit-image, --ssim): perceptual structural similarity in [-1, 1]
    (1.0 = identical). More robust to renderer/anti-alias noise; better for a
    borderline "is this basically the same layout" judgment.

Usage:
  python tool/golden_diff/diff.py <actual.png> <expected.png> [--out heatmap.png]
                                  [--threshold 5.0] [--tolerance 16]
                                  [--spec <specfile.md>] [--top 15]
                                  [--ssim] [--min-ssim 0.90] [--ssim-out ssim.png]

  --threshold  max allowed pixel mismatch percent before exit 1 (default 5.0)
  --tolerance  per-channel delta treated as equal (default 16; absorbs
               anti-aliasing/font-hinting differences between renderers)
  --spec       a UI-kit DOM spec (specs/NN-*.md): report PER-ELEMENT mismatch by
               cropping each node's abs bbox, so a divergence is localized to a
               node ("list-row-meta 18%") instead of the whole frame.
  --top        with --spec, how many most-divergent nodes to print (default 15)
  --ssim       also compute and print the SSIM score (needs scikit-image)
  --min-ssim   fail (exit 1) when SSIM < this value; implies --ssim
  --ssim-out   write an SSIM dissimilarity heat-map PNG here (implies --ssim)

Exit codes: 0 = within thresholds, 1 = pixel mismatch > --threshold OR
SSIM < --min-ssim, 2 = usage/IO error.
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


def load_pair(actual_path, expected_path):
    """Open both PNGs as RGB and resize actual -> expected if sizes differ.

    Returns (actual, expected, resized) where resized is the original actual size
    or None when no resize happened.
    """
    actual = Image.open(actual_path).convert("RGB")
    expected = Image.open(expected_path).convert("RGB")
    resized = None
    if actual.size != expected.size:
        resized = actual.size
        actual = actual.resize(expected.size, Image.LANCZOS)
    return actual, expected, resized


def pixel_diff_mask(actual, expected, tolerance):
    """Binary mask (mode 'L', 255 where channel delta > tolerance)."""
    gray = ImageChops.difference(actual, expected).convert("L")
    return gray.point(lambda v, t=tolerance: 255 if v > t else 0)


def pixel_mismatch(actual, expected, tolerance):
    """Per-pixel mismatch over the whole image -> dict(pct, changed, total, bbox)."""
    mask = pixel_diff_mask(actual, expected, tolerance)
    total = expected.size[0] * expected.size[1]
    changed = total - mask.histogram()[0]
    return {
        "pct": 100.0 * changed / total,
        "changed": changed,
        "total": total,
        "bbox": mask.getbbox(),
        "mask": mask,
    }


def region_pct(actual, expected, box, tolerance):
    """Mismatch % inside one bbox (clamped to image bounds); None if degenerate."""
    w, h = expected.size
    x0, y0, x1, y1 = box
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(w, x1), min(h, y1)
    if x1 <= x0 or y1 <= y0:
        return None
    a = actual.crop((x0, y0, x1, y1))
    e = expected.crop((x0, y0, x1, y1))
    mask = pixel_diff_mask(a, e, tolerance)
    total = (x1 - x0) * (y1 - y0)
    changed = total - mask.histogram()[0]
    return 100.0 * changed / total


def ssim_score(actual, expected):
    """SSIM in [-1, 1] (1 = identical) + a per-pixel dissimilarity map (mode 'L').

    Lazy-imports scikit-image so pixel-only runs don't need it installed.
    Returns dict(score, dssim_pct, dissim_map).
    """
    try:
        import numpy as np
        from skimage.metrics import structural_similarity
    except ImportError:  # pragma: no cover
        print(
            "scikit-image + numpy are required for --ssim: "
            "pip install -r tool/golden_diff/requirements.txt",
            file=sys.stderr,
        )
        raise SystemExit(2)

    a = np.asarray(actual)
    e = np.asarray(expected)
    score, full = structural_similarity(
        e, a, channel_axis=-1, full=True, data_range=255
    )
    # full is HxWx3 in [0,1]; collapse channels, invert to dissimilarity, to 8-bit.
    dissim = ((1.0 - full.mean(axis=2)) * 255.0).clip(0, 255).astype("uint8")
    return {
        "score": float(score),
        "dssim_pct": (1.0 - float(score)) * 100.0,
        "dissim_map": Image.fromarray(dissim, mode="L"),
    }


def parse_spec_boxes(path):
    """Yield (label, x, y, w, h) for every node with an abs bbox in the spec."""
    boxes = []
    label = "?"
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except OSError as exc:
        print(f"cannot open spec: {exc}", file=sys.stderr)
        return boxes
    for line in lines:
        s = line.strip().lstrip("+-").strip()
        n = _NODE.match(s)
        if n:
            label = n.group(1)
        elif s.startswith("text:"):
            t = _TEXT.match(s)
            if t:
                label = '"' + t.group(1)[:20] + '"'
        a = _ABS.search(s)
        if a:
            x, y, w, h = (int(v) for v in a.groups())
            boxes.append((label, x, y, w, h))
    return boxes


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("actual")
    ap.add_argument("expected")
    ap.add_argument("--out", help="write a pixel diff heat-map PNG here")
    ap.add_argument("--threshold", type=float, default=5.0)
    ap.add_argument("--tolerance", type=int, default=16)
    ap.add_argument("--spec", help="DOM spec for per-element diff")
    ap.add_argument("--top", type=int, default=15)
    ap.add_argument("--ssim", action="store_true", help="also compute SSIM")
    ap.add_argument("--min-ssim", type=float, default=None,
                    help="fail when SSIM < this (implies --ssim)")
    ap.add_argument("--ssim-out", help="write an SSIM dissimilarity heat-map here")
    args = ap.parse_args(argv)
    want_ssim = args.ssim or args.min_ssim is not None or bool(args.ssim_out)

    try:
        actual, expected, resized = load_pair(args.actual, args.expected)
    except OSError as exc:
        print(f"cannot open image: {exc}", file=sys.stderr)
        return 2

    if resized:
        print(f"note: resizing actual {resized} -> expected {expected.size}")

    px = pixel_mismatch(actual, expected, args.tolerance)
    print(f"mismatch: {px['pct']:.2f}% ({px['changed']}/{px['total']} px, "
          f"tolerance={args.tolerance})")
    if px["bbox"]:
        x0, y0, x1, y1 = px["bbox"]
        print(f"diff region: [{x0},{y0} {x1 - x0}x{y1 - y0}] "
              f"(compare with element bboxes in ui_kits/mobile/specs/)")
    else:
        print("diff region: none")

    ssim = None
    if want_ssim:
        ssim = ssim_score(actual, expected)
        print(f"ssim: {ssim['score']:.4f} (dssim: {ssim['dssim_pct']:.2f}%, "
              f"1.0 = identical)")
        if args.ssim_out:
            ssim["dissim_map"].save(args.ssim_out)
            print(f"ssim heat-map written: {args.ssim_out}")

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

    if args.out and px["bbox"]:
        heat = expected.copy()
        red = Image.new("RGB", expected.size, (220, 30, 60))
        heat.paste(red, mask=px["mask"])
        heat.save(args.out)
        print(f"heat-map written: {args.out}")

    pixel_fail = px["pct"] > args.threshold
    ssim_fail = (
        ssim is not None
        and args.min_ssim is not None
        and ssim["score"] < args.min_ssim
    )
    if pixel_fail or ssim_fail:
        if pixel_fail:
            print(f"FAIL: mismatch {px['pct']:.2f}% > threshold {args.threshold}%")
        if ssim_fail:
            print(f"FAIL: ssim {ssim['score']:.4f} < min-ssim {args.min_ssim}")
        return 1
    msg = f"PASS: mismatch {px['pct']:.2f}% <= threshold {args.threshold}%"
    if ssim is not None and args.min_ssim is not None:
        msg += f" and ssim {ssim['score']:.4f} >= {args.min_ssim}"
    print(msg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
