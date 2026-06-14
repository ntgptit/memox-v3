// Golden renders of the Library inline search field for visual parity against
// the kit mock (`docs/system-design/MemoX Design System/ui_kits/mobile/shots/
// 03-library-overview--*.png`, search row). Goldens use the test-default Ahem
// font, so they verify layout/spacing/alignment (e.g. the trailing "K" keycap
// inset) and color — not glyph shapes. This is the pilot for wiring per-screen
// visual-regression gates into `verify` (see docs/design/mock-to-ui-playbook.md
// Phase 7).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';

Future<void> _pump(WidgetTester tester, Brightness brightness) async {
  tester.view.physicalSize = const Size(390, 160);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topCenter,
              child: LibrarySearchField(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final Brightness brightness in <Brightness>[
    Brightness.light,
    Brightness.dark,
  ]) {
    final String theme = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('golden: search field empty ($theme)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, brightness);
      await expectLater(
        find.byType(LibrarySearchField),
        matchesGoldenFile('goldens/03-library--search-field-empty--$theme.png'),
      );
    });

    testWidgets('golden: search field with text ($theme)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, brightness);
      await tester.enterText(find.byType(TextField), 'Korean');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(LibrarySearchField),
        matchesGoldenFile('goldens/03-library--search-field-typed--$theme.png'),
      );
    });
  }
}
