import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

import '../../../support/golden_harness.dart';

const String _deckId = 'deck1';
final DateTime _t = DateTime.utc(2026);

final Deck _deck = Deck(
  id: _deckId,
  folderId: 'f1',
  name: 'Japanese · N5',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

Flashcard _card() => Flashcard(
  id: 'c1',
  deckId: _deckId,
  front: '日本',
  back: 'Japan',
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

FlashcardListDetail _detail({List<Flashcard> cards = const <Flashcard>[]}) =>
    FlashcardListDetail(
      deck: _deck,
      breadcrumb: <Folder>[
        Folder(
          id: 'f1',
          parentId: null,
          name: 'Languages',
          contentMode: ContentMode.decks,
          sortOrder: 0,
          createdAt: _t,
          updatedAt: _t,
        ),
      ],
      cards: cards,
      totalCount: cards.length,
    );

Future<void> _pump(
  WidgetTester tester, {
  String? cardId,
  List<Flashcard> cards = const <Flashcard>[],
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flashcardListStreamProvider(_deckId).overrideWith(
          (ref) => Stream<Result<FlashcardListDetail>>.value((
            failure: null,
            data: _detail(cards: cards),
          )),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FlashcardEditorScreen(deckId: _deckId, cardId: cardId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _saveEnabled(WidgetTester tester) =>
    tester.widget<MxPrimaryButton>(find.byType(MxPrimaryButton)).onPressed !=
    null;

void main() {
  group('FlashcardEditorScreen', () {
    testWidgets('create: empty fields, Add title, Save disabled until filled', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Add card'), findsOneWidget); // app-bar title
      expect(find.byType(MxTextField), findsNWidgets(2)); // front + back
      expect(_saveEnabled(tester), isFalse); // front+back empty

      // Front alone is not enough — back is also required.
      await tester.enterText(find.byType(MxTextField).first, 'neko');
      await tester.pump();
      expect(_saveEnabled(tester), isFalse);

      await tester.enterText(find.byType(MxTextField).last, 'cat');
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
    });

    testWidgets('edit: fields pre-filled from the card, Edit title', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      expect(find.text('Edit card'), findsOneWidget);
      expect(find.text('日本'), findsOneWidget); // front prefilled
      expect(find.text('Japan'), findsOneWidget); // back prefilled
      expect(_saveEnabled(tester), isTrue); // prefilled → valid
    });

    testWidgets('create: a dirty draft shows the discard confirm on close', (
      tester,
    ) async {
      await _pump(tester);
      await tester.enterText(find.byType(MxTextField).first, 'neko');
      await tester.pump();
      // Tapping X with unsaved edits opens the discard-changes confirm (mock
      // `07`/`08` Rules), not an immediate pop.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
    });

    testWidgets('create mode has no trash/delete action (mock `07`)', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('edit: trash action opens the delete confirm (mock `08`)', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      // Tapping the trash opens the destructive delete confirm, reusing the
      // shared card-delete copy.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete this card?'), findsOneWidget);
    });

    testWidgets('edit: a missing card id shows the load-error surface', (
      tester,
    ) async {
      await _pump(tester, cardId: 'gone'); // not in (empty) cards
      expect(find.byType(MxTextField), findsNothing);
      expect(find.text('Edit card'), findsOneWidget); // shell app bar title
    });
  });

  group('FlashcardEditorScreen goldens', () {
    testWidgets('create-empty — light', (tester) async {
      await _pump(tester, golden: true);
      await expectLater(
        find.byType(FlashcardEditorScreen),
        matchesGoldenFile('goldens/flashcard_editor_create-empty__light.png'),
      );
    });

    testWidgets('create-empty — dark', (tester) async {
      await _pump(tester, brightness: Brightness.dark, golden: true);
      await expectLater(
        find.byType(FlashcardEditorScreen),
        matchesGoldenFile('goldens/flashcard_editor_create-empty__dark.png'),
      );
    });

    for (final Brightness brightness in Brightness.values) {
      testWidgets('edit-loaded — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          cards: <Flashcard>[_card()],
          brightness: brightness,
          golden: true,
        );
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_edit-loaded__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
