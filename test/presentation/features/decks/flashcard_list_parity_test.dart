import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for flashcard-list, identity by KEY. The required
/// `mx-node:` ids are tagged in the kit JSX (data-mx-node) and generated into
/// tool/parity/contracts/contracts.json by gen_contract; the FE carries matching
/// keys. If either node stops rendering (or its key is removed) this fails.
void main() {
  const String id = 'deck1';
  final DateTime t = DateTime.utc(2026);
  final Deck deck = Deck(
    id: id,
    folderId: 'f1',
    name: 'Japanese · N5',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: t,
    updatedAt: t,
  );
  final FlashcardListDetail detail = FlashcardListDetail(
    deck: deck,
    breadcrumb: const <Folder>[],
    cards: <Flashcard>[
      Flashcard(
        id: 'c1',
        deckId: id,
        front: '日本',
        back: 'Japan',
        sortOrder: 0,
        createdAt: t,
        updatedAt: t,
      ),
    ],
    totalCount: 1,
  );

  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardListStreamProvider(id).overrideWith(
            (ref) => Stream<Result<FlashcardListDetail>>.value((
              failure: null,
              data: detail,
            )),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FlashcardListScreen(deckId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('06-flashcard-list parity contract (loaded)', (tester) async {
    await pump(tester);
    expectParityContract('06-flashcard-list', <String, Finder>{
      'add-card FAB': node('06-flashcard-list/add-card-fab'),
      'search dock': node('06-flashcard-list/search-dock'),
    });
  });

  testWidgets(
    '06-flashcard-list binding contract (keyed nodes realize kit components)',
    (tester) async {
      await pump(tester);
      // add-card-fab → MxFab. search-dock realizes the kit's generic search-dock
      // via the deck-scoped sibling MxScopedSearchDock (plain MxSearchDock cannot
      // host an external controller — see its doc), so alias it here (same
      // mechanism as learning-settings' MxBottomNav alias). card-list is a content
      // container with no kit component → skipped by the helper.
      expectGeneratedBindingContract(
        '06-flashcard-list',
        aliases: const <String, String>{'MxSearchDock': 'MxScopedSearchDock'},
      );
    },
  );
}
