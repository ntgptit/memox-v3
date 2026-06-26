import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';

/// Phase-1 spec-number gate for MxPrimaryButton — `docs/design/visual-parity-plan.md`
/// §4. Template: `mx_app_bar_spec_gate_test.dart` + `mx_secondary_button_spec_gate_test.dart`.
///
/// Measures the rendered primary button (the kit `21-account-sync/signin-button`
/// node) against its kit spec:
///   `bg:accent font:14/700 r:999(pill) h:44`
///
/// Asserted here (conformant + clean to measure):
/// - **Structural** — the primary realizes a Material `FilledButton`, scoped via
///   `find.descendant(of: MxPrimaryButton)`. NOTE this guards against a regression
///   to OutlinedButton/TextButton; it does NOT distinguish primary from a tonal
///   secondary (FilledButton.tonal is the same class). A primary-vs-tonal check
///   would need the resolved ButtonStyle backgroundColor (accent vs accentSoft).
/// - **Label font-size = 14** (labelLarge), measured via `RenderParagraph` —
///   engine-independent, honest. `Text(label)` carries no explicit style, so the
///   merged root span carries the full `labelLarge` (incl. fontSize 14); if the
///   label widget ever sets a partial explicit style, re-probe the resolved node.
///
/// NOT asserted (LOGGED finding — `docs/project-management/overnight-fe-sync-log.md`
/// §Spec-number gates): the spec label weight is **700** but `labelLarge` renders
/// **w600**. This is now confirmed on BOTH primary and secondary buttons (both read
/// `labelLarge`) → a SYSTEMIC button-label drift; the fix belongs at the shared
/// layer (the `labelLarge` token or a button-label role), handled deliberately with
/// a button-golden regen, then the weight assertion is added.
///
/// NOT asserted (box-model gotcha, plan §3.2): visual height 44 vs the padded
/// tap-target box — deferred to Phase-0 calibration.
void main() {
  const double kSpecLabelFontSize = 14; // spec `font:14/700` (size component)

  testWidgets('MxPrimaryButton realizes a FilledButton + 14px label', (
    WidgetTester tester,
  ) async {
    const String label = 'Sign in with Google';
    await tester.pumpWidget(
      MaterialApp(
        theme: MxTheme.light,
        home: const Scaffold(
          // No icon / not loading: keeps the label probe unambiguous.
          body: Center(child: MxPrimaryButton(label: label)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Structural: primary → FilledButton (solid fill).
    expect(
      find.descendant(
        of: find.byType(MxPrimaryButton),
        matching: find.byType(FilledButton),
      ),
      findsOneWidget,
      reason:
          'primary button must be a FilledButton, not OutlinedButton/TextButton',
    );

    // Label typography (size) — measured from the rendered paragraph.
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(MxPrimaryButton),
        matching: find.text(label),
      ),
    );
    expect(
      paragraph.text.style?.fontSize,
      kSpecLabelFontSize,
      reason: 'kit spec: primary-button label font-size = 14',
    );
  });
}
