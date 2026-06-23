"""Unit tests for golden_diff/diff.py — pins the hand-written glue around Pillow
(resize, tolerance mask, region crop, spec-bbox parse) and the SSIM path.

Dep-free for the pixel parts (stdlib unittest + Pillow, already required).
SSIM tests skip automatically when scikit-image isn't installed.

Run:  python tool/golden_diff/test_diff.py
"""

import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image  # noqa: E402

import diff  # noqa: E402

try:
    import skimage  # noqa: F401
    HAS_SKIMAGE = True
except ImportError:
    HAS_SKIMAGE = False


def solid(size, color):
    return Image.new("RGB", size, color)


def save(tmp, name, img):
    p = os.path.join(tmp, name)
    img.save(p)
    return p


BLACK = (0, 0, 0)
WHITE = (255, 255, 255)


class PixelTests(unittest.TestCase):
    def test_identical_is_zero(self):
        a = solid((40, 40), BLACK)
        r = diff.pixel_mismatch(a, a.copy(), tolerance=16)
        self.assertEqual(r["pct"], 0.0)
        self.assertIsNone(r["bbox"])

    def test_disjoint_is_full(self):
        a = solid((40, 40), BLACK)
        e = solid((40, 40), WHITE)
        r = diff.pixel_mismatch(a, e, tolerance=16)
        self.assertEqual(r["pct"], 100.0)
        self.assertEqual(r["bbox"], (0, 0, 40, 40))

    def test_tolerance_absorbs_small_delta(self):
        a = solid((20, 20), (100, 100, 100))
        e = solid((20, 20), (108, 108, 108))  # delta 8 < tolerance 16
        self.assertEqual(diff.pixel_mismatch(a, e, tolerance=16)["pct"], 0.0)
        # ...but a delta above tolerance counts.
        e2 = solid((20, 20), (130, 130, 130))  # delta 30 > 16
        self.assertEqual(diff.pixel_mismatch(a, e2, tolerance=16)["pct"], 100.0)

    def test_region_pct_localizes(self):
        # White 10x10 block at (5,5) on a black 40x40 field.
        e = solid((40, 40), BLACK)
        a = e.copy()
        a.paste(solid((10, 10), WHITE), (5, 5))
        over_block = diff.region_pct(a, e, (5, 5, 15, 15), tolerance=16)
        off_block = diff.region_pct(a, e, (20, 20, 30, 30), tolerance=16)
        self.assertEqual(over_block, 100.0)
        self.assertEqual(off_block, 0.0)

    def test_region_pct_clamps_and_rejects_degenerate(self):
        e = solid((40, 40), BLACK)
        self.assertIsNone(diff.region_pct(e, e.copy(), (50, 50, 60, 60), 16))
        self.assertIsNone(diff.region_pct(e, e.copy(), (10, 10, 10, 20), 16))

    def test_load_pair_resizes_actual_to_expected(self):
        with tempfile.TemporaryDirectory() as tmp:
            ap = save(tmp, "a.png", solid((100, 100), (50, 60, 70)))
            ep = save(tmp, "e.png", solid((50, 40), (50, 60, 70)))
            actual, expected, resized = diff.load_pair(ap, ep)
            self.assertEqual(actual.size, expected.size)
            self.assertEqual(expected.size, (50, 40))
            self.assertEqual(resized, (100, 100))
            # Same solid color survives resize → zero mismatch.
            self.assertEqual(diff.pixel_mismatch(actual, expected, 16)["pct"], 0.0)


SPEC_FIXTURE = (
    "- node: app-bar\n"
    "  box:\n"
    "    abs: [0,0 390x56]\n"
    "    rel: [0,0 390x56]\n"
    "  style: bg:surface r:14\n"
    "  - node: title\n"
    "    text: Library\n"
    "    box:\n"
    "      abs: [20,18 120x24]\n"
    "    style: font:18/700 color:text\n"
)


class SpecParseTests(unittest.TestCase):
    def test_parses_node_abs_style_text(self):
        with tempfile.TemporaryDirectory() as tmp:
            spec = save_text(tmp, "03.md", SPEC_FIXTURE)
            nodes = diff.parse_spec_nodes(spec)
            self.assertEqual([n["name"] for n in nodes], ["app-bar", "title"])
            self.assertEqual(nodes[0]["abs"], (0, 0, 390, 56))
            self.assertEqual(nodes[0]["style"], "bg:surface r:14")
            self.assertEqual(nodes[1]["abs"], (20, 18, 120, 24))
            self.assertEqual(nodes[1]["text"], "Library")
            self.assertEqual(nodes[1]["style"], "font:18/700 color:text")

    def test_skips_nodes_without_abs(self):
        with tempfile.TemporaryDirectory() as tmp:
            spec = save_text(tmp, "x.md", "- node: ghost\n  style: bg:accent\n")
            self.assertEqual(diff.parse_spec_nodes(spec), [])

    def test_missing_file_returns_empty(self):
        self.assertEqual(diff.parse_spec_nodes("/no/such/spec.md"), [])


class NodeRowsTests(unittest.TestCase):
    def test_reports_measured_color_and_intended_style(self):
        # shot: blue title box on white; golden: same layout but red title box.
        shot = solid((390, 56), WHITE)
        shot.paste(solid((120, 24), (0, 0, 255)), (20, 18))
        golden = solid((390, 56), WHITE)
        golden.paste(solid((120, 24), (255, 0, 0)), (20, 18))
        with tempfile.TemporaryDirectory() as tmp:
            spec = save_text(tmp, "s.md", SPEC_FIXTURE)
            rows = diff.node_rows(golden, shot, diff.parse_spec_nodes(spec), 16)
            title = next(r for r in rows if r["name"] == "title")
            self.assertGreater(title["pct"], 90.0)        # box fully changed
            self.assertGreater(title["drgb"], 200)         # red vs blue
            self.assertIn("color:text", title["style"])    # intended carried
            self.assertTrue(title["golden_hex"].startswith("#"))
            self.assertEqual(title["status"], "COLOR?")     # both present, wrong colour

    def test_flags_node_missing_in_render(self):
        # shot has a blue title box; golden is blank (node absent) → MISSING.
        shot = solid((390, 56), WHITE)
        shot.paste(solid((120, 24), (40, 70, 230)), (20, 18))
        golden = solid((390, 56), WHITE)  # nothing drawn at the title bbox
        with tempfile.TemporaryDirectory() as tmp:
            spec = save_text(tmp, "s.md", SPEC_FIXTURE)
            rows = diff.node_rows(golden, shot, diff.parse_spec_nodes(spec), 16)
            title = next(r for r in rows if r["name"] == "title")
            self.assertEqual(title["status"], "MISSING?")

    def test_sparse_content_not_flagged_missing(self):
        # golden has sparse "ink" (a stripe = text/icon-like detail), shot is a
        # solid fill. Different, but NOT missing — must not be MISSING?.
        shot = solid((390, 56), WHITE)
        shot.paste(solid((120, 24), (40, 70, 230)), (20, 18))
        golden = solid((390, 56), WHITE)
        golden.paste(solid((120, 4), (0, 0, 0)), (20, 28))  # a thin dark stripe
        with tempfile.TemporaryDirectory() as tmp:
            spec = save_text(tmp, "s.md", SPEC_FIXTURE)
            rows = diff.node_rows(golden, shot, diff.parse_spec_nodes(spec), 16)
            title = next(r for r in rows if r["name"] == "title")
            self.assertNotEqual(title["status"], "MISSING?")

    def test_figure_ground_present_vs_blank(self):
        img = solid((60, 60), WHITE)
        img.paste(solid((20, 20), (0, 0, 0)), (20, 20))
        self.assertGreater(diff.figure_ground(img, 20, 20, 20, 20), 100)  # stands out
        self.assertEqual(diff.figure_ground(solid((60, 60), WHITE), 20, 20, 20, 20), 0)


@unittest.skipUnless(HAS_SKIMAGE, "scikit-image not installed")
class SsimTests(unittest.TestCase):
    def test_identical_is_one(self):
        a = solid((64, 64), (30, 120, 200))
        s = diff.ssim_score(a, a.copy())
        self.assertAlmostEqual(s["score"], 1.0, places=6)
        self.assertAlmostEqual(s["dssim_pct"], 0.0, places=4)

    def test_disjoint_is_near_zero(self):
        s = diff.ssim_score(solid((64, 64), BLACK), solid((64, 64), WHITE))
        self.assertLess(s["score"], 0.1)
        self.assertEqual(s["dissim_map"].size, (64, 64))

    def test_symmetric(self):
        a = solid((64, 64), (10, 20, 30))
        b = a.copy()
        b.paste(solid((20, 20), WHITE), (5, 5))
        self.assertAlmostEqual(
            diff.ssim_score(a, b)["score"], diff.ssim_score(b, a)["score"], places=6
        )


class MainExitCodeTests(unittest.TestCase):
    def test_identical_passes_with_ssim_gate(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = save(tmp, "x.png", solid((40, 40), (12, 34, 56)))
            argv = [p, p, "--threshold", "0"]
            if HAS_SKIMAGE:
                argv += ["--min-ssim", "0.99"]
            self.assertEqual(diff.main(argv), 0)

    def test_disjoint_fails_pixel_threshold(self):
        with tempfile.TemporaryDirectory() as tmp:
            a = save(tmp, "a.png", solid((40, 40), BLACK))
            e = save(tmp, "e.png", solid((40, 40), WHITE))
            self.assertEqual(diff.main([a, e, "--threshold", "5"]), 1)

    @unittest.skipUnless(HAS_SKIMAGE, "scikit-image not installed")
    def test_disjoint_fails_ssim_gate(self):
        with tempfile.TemporaryDirectory() as tmp:
            a = save(tmp, "a.png", solid((40, 40), BLACK))
            e = save(tmp, "e.png", solid((40, 40), WHITE))
            # huge pixel threshold so only the SSIM gate can fail it
            self.assertEqual(
                diff.main([a, e, "--threshold", "100", "--min-ssim", "0.9"]), 1
            )


def save_text(tmp, name, text):
    p = os.path.join(tmp, name)
    with open(p, "w", encoding="utf-8") as fh:
        fh.write(text)
    return p


if __name__ == "__main__":
    unittest.main(verbosity=2)
