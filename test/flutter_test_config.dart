import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Auto-discovered by `flutter test`: wraps EVERY test so goldens render the real
/// app typeface (Plus Jakarta Sans, bundled in `assets/fonts/`) instead of the
/// Ahem block-font the test harness uses by default.
///
/// Why: golden↔kit-shot pixel diffs (`tool/golden_diff/diff.py`,
/// `tool/parity/report.mjs`) were dominated by Ahem-vs-real-text noise (dark ≈ 2×
/// light on every screen) — masking real divergences. With the real font loaded,
/// diff% becomes a meaningful signal and `report.mjs --check --max <pct>` can gate
/// pixel regressions. Regenerate goldens after changing this file:
/// `node tool/verify/run.mjs --full --update-goldens`.
///
/// Plus Jakarta Sans carries no CJK glyphs, so Korean/kanji sample text (kit 23
/// Audio & speech preview, the CJK study-mode fixtures) rendered as tofu boxes in
/// goldens. The fix is two parts: the app theme declares a CJK
/// `fontFamilyFallback` (`MxTypography.fontFamilyCjkFallback = 'Noto Sans KR'`,
/// unbundled — device uses the platform CJK font), and here we register a
/// **subset** of Noto Sans KR (only the CJK codepoints that appear in golden
/// text — `assets/fonts/noto_sans_kr/NotoSansKR-goldensubset.ttf`, ~77 KB) under
/// that family so the fallback resolves in tests. Flutter only falls back across
/// *families* listed in `fontFamilyFallback`, not across fonts loaded under one
/// family — hence the dedicated family here. **When a golden adds new CJK
/// characters, extend the subset** (regenerate via `pyftsubset`; see
/// `tool/README.md`). The serif accent family (`Lora`,
/// `MxTypography.fontFamilySerif`) is also loaded for tests so serif content
/// renders its real shapes rather than the platform fallback.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  ByteData read(String path) =>
      ByteData.sublistView(File(path).readAsBytesSync());

  Future<void> loadFamily(String family, String path) =>
      (FontLoader(family)..addFont(Future<ByteData>.value(read(path)))).load();

  await loadFamily(
    'Plus Jakarta Sans',
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans[wght].ttf',
  );
  // CJK fallback (own family — matches MxTypography.fontFamilyCjkFallback).
  await loadFamily(
    'Noto Sans KR',
    'assets/fonts/noto_sans_kr/NotoSansKR-goldensubset.ttf',
  );
  // Serif accent (MxTypography.fontFamilySerif = 'Lora').
  await loadFamily('Lora', 'assets/fonts/lora/Lora.ttf');

  await testMain();
}
