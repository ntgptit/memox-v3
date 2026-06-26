import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

/// Phase-1 spec-number gate for MxSecondaryButton — `docs/design/visual-parity-plan.md`
/// §4. Template: `test/presentation/shared/widgets/navigation/mx_app_bar_spec_gate_test.dart`.
///
/// Measures the RENDERED tonal secondary button (the kit `23-audio-speech/
/// preview-button` node) against its kit spec:
///   `font:14/700  bg:accentSoft  r:999(pill)  h:44`
///
/// Asserted here (conformant + clean to measure):
/// - **Variant integrity** — the tonal variant realizes a Material `FilledButton`
///   (a tonal fill), NOT an `OutlinedButton`. This is exactly the class of the
///   23-audio-speech `outlined → tonal` bug (fixed at the screen in 1f27d69); the
///   component gate now locks that the tonal variant cannot silently render the
///   outlined widget.
/// - **Label font-size = 14** (labelLarge), measured via `RenderParagraph` —
///   engine-independent, honest (not a self-reported contract).
///
/// NOT asserted (LOGGED finding — see `docs/project-management/overnight-fe-sync-log.md`
/// §Spec-number gates): the spec label weight is **700** (bold) but `labelLarge`
/// renders **w600** (semibold) — a real drift. The fix needs a variant-consistency
/// decision (tonal-only vs all three variants vs the shared `labelLarge` token) + a
/// golden regen, so it is handled as a deliberate change rather than rushed inside
/// the loop; the weight assertion is added here once that lands.
///
/// Measurement note (carried from the M0 template): `RenderParagraph.text.style` is
/// the merged root TextSpan style. It carries `fontSize` here because the button's
/// `Text(label)` has no explicit style (the merge yields the full `labelLarge`); if
/// `_MxLabel` ever sets an explicit partial style, re-probe the resolved node.
///
/// NOT asserted (box-model gotcha, plan §3.2): visual height = 44, but
/// `MaterialTapTargetSize.padded` makes the widget bounds ≥ 48 — `getSize` would
/// read the tap-target box, not the 44 visual box. Deferred to Phase-0 calibration.
void main() {
  const double kSpecLabelFontSize = 14; // spec `font:14/700` (size component)

  testWidgets('MxSecondaryButton tonal realizes a FilledButton + 14px label', (
    WidgetTester tester,
  ) async {
    const String label = 'Play sample';
    await tester.pumpWidget(
      MaterialApp(
        theme: MxTheme.light,
        home: const Scaffold(
          body: Center(
            // No icon intentionally: with an icon, _MxLabel renders an extra Text
            // and find.text would need a tighter probe. The kit preview-button has
            // an icon, but the typography probe is unambiguous without one.
            child: MxSecondaryButton(
              label: label,
              variant: MxSecondaryVariant.tonal,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Variant integrity: tonal → FilledButton (tonal fill), not OutlinedButton.
    expect(
      find.descendant(
        of: find.byType(MxSecondaryButton),
        matching: find.byType(FilledButton),
      ),
      findsOneWidget,
      reason: 'kit preview-button is a tonal fill → FilledButton, not outlined',
    );

    // Label typography (size) — measured from the rendered paragraph.
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(MxSecondaryButton),
        matching: find.text(label),
      ),
    );
    expect(
      paragraph.text.style?.fontSize,
      kSpecLabelFontSize,
      reason: 'kit spec: secondary-button label font-size = 14',
    );
  });
}
