import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';
import 'package:memox/presentation/features/search/viewmodels/global_search_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for global search (identity by KEY). The search dock
/// is the screen's defining node and renders in every state, so the idle pump
/// suffices.
void main() {
  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  testWidgets('05-library-search parity contract (idle)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [globalSearchResultsProvider.overrideWith((ref) => null)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GlobalSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expectParityContract('05-library-search', <String, Finder>{
      'search dock': node('05-library-search/search-dock'),
    });
  });
}
