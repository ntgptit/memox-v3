import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/tag_management_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for Tag Management (11), identity by STABLE KEY
/// (`tool/parity/contracts/contracts.json`): the tag list card + the bottom
/// search dock.
Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagsWithCountProvider.overrideWith(
            (ref) => Stream<List<TagWithCount>>.value(const <TagWithCount>[
              TagWithCount(name: 'kanji', cardCount: 142),
              TagWithCount(name: 'vocab', cardCount: 210),
            ]),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsTagManagementScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('11-tag-management parity contract (loaded)', (tester) async {
    await pump(tester);
    expectParityContract('11-tag-management', <String, Finder>{
      'tag list card': _node('11-tag-management/tag-list'),
      'bottom search dock': _node('11-tag-management/search-dock'),
    });
  });

  testWidgets(
    '11-tag-management binding contract (keyed nodes realize kit components)',
    (tester) async {
      await pump(tester);
      // search-dock realizes the kit search-dock via the scoped sibling
      // MxScopedSearchDock (tag-scoped search; plain MxSearchDock can't host an
      // external controller — same as 06), so alias it. tag-list is a content
      // container with no kit component → skipped.
      expectGeneratedBindingContract(
        '11-tag-management',
        aliases: const <String, String>{'MxSearchDock': 'MxScopedSearchDock'},
      );
    },
  );
}
