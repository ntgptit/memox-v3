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
import 'package:memox/presentation/features/decks/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for the flashcard editor in EDIT mode (08). Reuses
/// the shared `flashcard-editor/<node>` ids (the editor screen serves both 07 + 08);
/// asserts the prefilled front/back fields render with their keys.
void main() {
  const String deckId = 'deck1';
  final DateTime t = DateTime.utc(2026);
  final Deck deck = Deck(
    id: deckId,
    folderId: 'f1',
    name: 'Japanese · N5',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: t,
    updatedAt: t,
  );
  final Flashcard card = Flashcard(
    id: 'c1',
    deckId: deckId,
    front: '日本',
    back: 'Japan',
    sortOrder: 0,
    createdAt: t,
    updatedAt: t,
  );
  final FlashcardListDetail detail = FlashcardListDetail(
    deck: deck,
    breadcrumb: const <Folder>[],
    cards: <Flashcard>[card],
    totalCount: 1,
  );

  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  testWidgets('08-flashcard-edit parity contract (edit)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flashcardListStreamProvider(deckId).overrideWith(
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
          home: const FlashcardEditorScreen(deckId: deckId, cardId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expectParityContract('08-flashcard-edit', <String, Finder>{
      'front field': node('flashcard-editor/front-field'),
      'back field': node('flashcard-editor/back-field'),
      'back button': node('flashcard-editor/back-btn'),
      'delete button': node('flashcard-editor/delete-btn'),
      'save button': node('flashcard-editor/save-button'),
    });
  });
}
