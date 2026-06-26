import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/presentation/shared/widgets/mx_section_header.dart';

import '../../../support/component_spec.dart';

/// Phase-1 spec-number gate for MxSectionHeader — `docs/design/visual-parity-plan.md`
/// §4. UNLIKE the earlier gates (which inline their spec number with a citation),
/// this one reads the asserted number from the GENERATED contract via
/// `componentTextSpec('MxSectionHeader')`. MxSectionHeader is the one cleanly
/// single-font component (status `ok`, 16/700), so it proves the contract → gate
/// CENTRALIZED read end-to-end: the spec number has ONE source.
///
/// Asserted: the rendered title font-size == the contract value (16), measured via
/// `RenderParagraph` — engine-independent.
///
/// NOT asserted (LOGGED finding — overnight-fe-sync-log §Spec-number gates): the
/// contract weight is 700 but MxSectionHeader's title role (`titleMedium`) renders
/// w600 — the SAME systemic semibold-vs-bold drift as the buttons. Asserting it would
/// red this gate; it is fixed deliberately with the other label-weight drifts.
void main() {
  testWidgets('MxSectionHeader title font-size matches the contract', (
    WidgetTester tester,
  ) async {
    final ComponentTextSpec spec = componentTextSpec('MxSectionHeader');

    const String title = 'Per-deck mastery';
    await tester.pumpWidget(
      MaterialApp(
        theme: MxTheme.light,
        home: const Scaffold(body: MxSectionHeader(title: title)),
      ),
    );
    await tester.pumpAndSettle();

    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(MxSectionHeader),
        matching: find.text(title),
      ),
    );
    expect(
      paragraph.text.style,
      isNotNull,
      reason: 'rendered title text style must resolve — probe the right node',
    );
    expect(
      paragraph.text.style?.fontSize,
      spec.fontSize,
      reason:
          'MxSectionHeader title font-size must equal the contract spec number',
    );
  });
}
