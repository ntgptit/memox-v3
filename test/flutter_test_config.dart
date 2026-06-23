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
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Uint8List bytes = File(
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans[wght].ttf',
  ).readAsBytesSync();
  final FontLoader loader = FontLoader('Plus Jakarta Sans')
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
  await testMain();
}
