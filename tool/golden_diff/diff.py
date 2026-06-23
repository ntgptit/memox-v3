"""golden_diff -- compare a Flutter golden/screenshot against a UI-kit mock shot.

Gives agents WITHOUT vision a text feedback loop for visual parity: run the app
screen (flutter golden test / integration screenshot), then compare against the
canonical mock PNG under docs/system-design/MemoX Design System/ui_kits/mobile/shots/.
Output is text an agent can act on: a per-pixel mismatch %, the bounding box of the
differing region, an optional SSIM score, an optional PER-NODE divergence log
(--spec), and optional heat-map PNGs.

Two metrics, different jobs:
  - PIXEL mismatch % (Pillow): "how many pixels differ" — sensitive to any shift.
  - SSIM (scikit-image, --ssim): perceptual structural similarity in [-1, 1]
    (1.0 = identical). More robust to renderer/anti-alias noise.

The --spec log is the actionable part for an AI fixer: for each divergent node it
prints WHERE (bbox), HOW MUCH (pixel% + node SSIM), the INTENDED design values
parsed from the spec (font/color/bg/r/border), and the MEASURED mean colour of the
golden crop vs the shot crop (with a ΔRGB) — so a colour bug ("intended bg:accent,
golden #2a2f3a vs shot #5b7cff") is distinguishable from a text/position bug
(colours match, pixel% high).

Usage:
  python tool/golden_diff/diff.py <actual.png> <expected.png> [--out heatmap.png]
                                  [--threshold 5.0] [--tolerance 16]
                                  [--spec <specfile.md>] [--top 15]
                                  [--ssim] [--min-ssim 0.90] [--ssim-out ssim.png]

  --threshold  max allowed pixel mismatch percent before exit 1 (default 5.0)
  --tolerance  per-channel delta treated as equal (default 16; absorbs
               anti-aliasing/font-hinting differences between renderers)
  --spec       a UI-kit DOM spec (specs/NN-*.md): emit the per-node divergence log.
  --top        with --spec, how many most-divergent nodes to print (default 15)
  --ssim       also compute and print the whole-image SSIM score (needs scikit-image)
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
    from PIL import Image, ImageChops, ImageStat
except ImportError:  # pragma: no cover
    print("Pillow is required: pip install Pillow", file=sys.stderr)
    sys.exit(2)

_ABS = re.compile(r"abs:\s*\[(\d+),(\d+)\s+(\d+)x(\d+)\]")
_NODE = re.compile(r"node:\s*(\S+)")
_STYLE_KEYS = ("font", "color", "bg", "r:", "border", "tracking", "shadow")


def _skimage():
    """Return (numpy, structural_similarity) or None if not installed (soft)."""
    try:
        import numpy as np
        from skimage.metrics import structural_similarity
        return np, structural_similarity
    except ImportError:
        return None


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


def clamp_box(box, size):
    """Clamp (x0,y0,x1,y1) to an image size; return None if degenerate."""
    w, h = size
    x0, y0, x1, y1 = box
    x0, y0 = max(0, x0), max(0, y0)
    x1, y1 = min(w, x1), min(h, y1)
    if x1 <= x0 or y1 <= y0:
        return None
    return (x0, y0, x1, y1)


def region_pct(actual, expected, box, tolerance):
    """Mismatch % inside one bbox (clamped to image bounds); None if degenerate."""
    cb = clamp_box(box, expected.size)
    if cb is None:
        return None
    mask = pixel_diff_mask(actual.crop(cb), expected.crop(cb), tolerance)
    total = (cb[2] - cb[0]) * (cb[3] - cb[1])
    changed = total - mask.histogram()[0]
    return 100.0 * changed / total


def mean_color(img):
    """Mean RGB of an image -> ((r,g,b), '#rrggbb')."""
    r, g, b = (int(round(v)) for v in ImageStat.Stat(img).mean[:3])
    return (r, g, b), f"#{r:02x}{g:02x}{b:02x}"


def rgb_delta(a, b):
    """Max per-channel absolute difference between two (r,g,b)."""
    return max(abs(a[i] - b[i]) for i in range(3))


def ssim_score(actual, expected, soft=False):
    """SSIM in [-1, 1] (1 = identical) + a per-pixel dissimilarity map (mode 'L').

    soft=True returns None when scikit-image is missing or the image is smaller
    than the SSIM window (for per-node use); soft=False is the hard CLI path that
    prints a hint and exits 2 when scikit-image is missing.
    Returns dict(score, dssim_pct, dissim_map) or None.
    """
    lib = _skimage()
    if lib is None:
        if soft:
            return None
        print(
            "scikit-image + numpy are required for --ssim: "
            "pip install -r tool/golden_diff/requirements.txt",
            file=sys.stderr,
        )
        raise SystemExit(2)
    np, structural_similarity = lib
    if soft and min(actual.size) < 7:  # smaller than the default SSIM window
        return None

    a = np.asarray(actual)
    e = np.asarray(expected)
    score, full = structural_similarity(
        e, a, channel_axis=-1, full=True, data_range=255
    )
    dissim = ((1.0 - full.mean(axis=2)) * 255.0).clip(0, 255).astype("uint8")
    return {
        "score": float(score),
        "dssim_pct": (1.0 - float(score)) * 100.0,
        "dissim_map": Image.fromarray(dissim, mode="L"),
    }


def parse_spec_nodes(path):
    """Parse a specs/NN-*.md DOM spec into per-node dicts.

    Each node: {name, abs:(x,y,w,h), style:str, text:str|None}. A node's own abs
    is the first abs after its `- node:` line; style is its first `style:` line.
    Only nodes that have an abs bbox are returned.
    """
    nodes = []
    cur = None
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except OSError as exc:
        print(f"cannot open spec: {exc}", file=sys.stderr)
        return nodes
    for raw in lines:
        s = raw.strip().lstrip("+-").strip()
        n = _NODE.match(s)
        if n:
            if cur:
                nodes.append(cur)
            cur = {"name": n.group(1), "abs": None, "style": "", "text": None}
            continue
        if cur is None:
            continue
        if cur["abs"] is None:
            a = _ABS.search(s)
            if a:
                cur["abs"] = tuple(int(v) for v in a.groups())
        if cur["text"] is None and s.startswith("text:"):
            cur["text"] = s[len("text:"):].strip()[:24]
        if not cur["style"] and s.startswith("style:"):
            cur["style"] = s[len("style:"):].strip()
    if cur:
        nodes.append(cur)
    # Dedupe identical (name, abs) — a spec lists a node once per state section,
    # so the same node+bbox can appear several times across the file.
    seen, out = set(), []
    for n in nodes:
        if not n["abs"]:
            continue
        key = (n["name"], n["abs"])
        if key in seen:
            continue
        seen.add(key)
        out.append(n)
    return out


def node_rows(actual, expected, nodes, tolerance):
    """Build the per-node divergence rows (sorted by pixel% desc)."""
    rows = []
    for n in nodes:
        x, y, w, h = n["abs"]
        cb = clamp_box((x, y, x + w, y + h), expected.size)
        if cb is None:
            continue
        a_crop, e_crop = actual.crop(cb), expected.crop(cb)
        mask = pixel_diff_mask(a_crop, e_crop, tolerance)
        total = (cb[2] - cb[0]) * (cb[3] - cb[1])
        pct = 100.0 * (total - mask.histogram()[0]) / total
        a_rgb, a_hex = mean_color(a_crop)
        e_rgb, e_hex = mean_color(e_crop)
        ns = ssim_score(a_crop, e_crop, soft=True)
        rows.append({
            "name": n["name"],
            "abs": n["abs"],
            "pct": pct,
            "ssim": ns["score"] if ns else None,
            "style": n["style"] or "—",
            "golden_hex": a_hex,
            "shot_hex": e_hex,
            "drgb": rgb_delta(a_rgb, e_rgb),
        })
    rows.sort(key=lambda r: -r["pct"])
    return rows


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("actual")
    ap.add_argument("expected")
    ap.add_argument("--out", help="write a pixel diff heat-map PNG here")
    ap.add_argument("--threshold", type=float, default=5.0)
    ap.add_argument("--tolerance", type=int, default=16)
    ap.add_argument("--spec", help="DOM spec for the per-node divergence log")
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
        rows = node_rows(actual, expected, parse_spec_nodes(args.spec), args.tolerance)
        print(f"\nper-node divergence (top {args.top} of {len(rows)} nodes, "
              f"by pixel%) — intended = from spec, golden→shot = measured mean colour:")
        print(f"  {'node':22} {'bbox':16} {'pix%':>6} {'ssim':>5}  "
              f"{'golden→shot (ΔRGB)':22} intended")
        for r in rows[: args.top]:
            x, y, w, h = r["abs"]
            box = f"[{x},{y} {w}x{h}]"
            sval = f"{r['ssim']:.2f}" if r["ssim"] is not None else "  - "
            color = f"{r['golden_hex']}→{r['shot_hex']} ({r['drgb']:>3})"
            print(f"  {r['name'][:22]:22} {box:16} {r['pct']:6.2f} {sval:>5}  "
                  f"{color:22} {r['style']}")
        print("  hint: ΔRGB high → colour/token bug; ΔRGB low but pix% high → "
              "text/position/size — check the spec's font/rel against the widget.")

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
