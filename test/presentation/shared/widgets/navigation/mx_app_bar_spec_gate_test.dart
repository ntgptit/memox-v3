import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Phase-1 spec-number gate — `docs/design/visual-parity-plan.md` §4 Phase 1.
///
/// This is the M0 validating slice. It measures the RENDERED app-bar title
/// typography via `RenderParagraph` metrics (engine-independent + honest — a
/// real measurement, not a self-reported "debug contract" that could lie) and
/// asserts it against the kit spec NUMBER: every `appbar` / `appbar-lg` node in
/// `docs/system-design/MemoX Design System/ui_kits/mobile/specs/*.md` specifies
/// `font:24/700` for the title.
///
/// Why this gate exists: whole-frame SSIM is BLIND to this drift (the title is a
/// tiny pixel fraction) — the title had silently drifted to `headlineMedium`
/// (22px / w600) and only a per-element number gate catches it. Proven: revert
/// `MxAppBar`'s `titleTextStyle` to `headlineMedium` and this test goes red.
///
/// TEMPLATE NOTES (this pattern will be copied to MxCard / MxSecondaryButton / …):
/// - `RenderParagraph.text.style` is the TextSpan's ROOT style — i.e. the result
///   of `DefaultTextStyle.merge(explicitTextStyle)`. It is correct here because the
///   AppBar title `Text` carries NO explicit style, so the merge yields the full
///   `titleTextStyle`. For a sub-widget whose `Text` sets an explicit PARTIAL style
///   (e.g. `TextStyle(color: …)` only), this getter may return `fontSize: null` —
///   that fails loudly (safe), it does not false-green; still, probe the right node.
/// - Scope the probe to the component (`find.descendant(of: find.byType(…))`) so it
///   stays unambiguous when copied into a full-screen widget test that may repeat
///   the same string elsewhere.
void main() {
  // Kit spec contract for the app-bar title slot (specs/*.md, every appbar node).
  // The full Phase-1 build reads this from tool/parity/contracts/component-
  // contracts.json; the M0 slice asserts it inline with the spec citation.
  const double kSpecTitleFontSize = 24; // spec `font:24/700`
  const FontWeight kSpecTitleWeight = FontWeight.w700; // spec `font:24/700`

  testWidgets('MxAppBar title realizes the kit spec number (24px / w700)', (
    WidgetTester tester,
  ) async {
    const String title = 'Audio & speech';
    await tester.pumpWidget(
      MaterialApp(
        theme: MxTheme.light,
        home: const Scaffold(
          appBar: MxAppBar(title: title),
          body: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: find.byType(MxAppBar), matching: find.text(title)),
    );
    final TextStyle? style = paragraph.text.style;

    expect(
      style?.fontSize,
      kSpecTitleFontSize,
      reason: 'kit spec: app-bar title font-size = 24 (font:24/700)',
    );
    expect(
      style?.fontWeight,
      kSpecTitleWeight,
      reason: 'kit spec: app-bar title weight = 700 (font:24/700)',
    );
  });
}
