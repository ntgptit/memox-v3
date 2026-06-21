import 'dart:async';

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
import 'package:memox/presentation/features/decks/widgets/flashcard_list_search.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

const String _id = 'deck1';
final DateTime _t = DateTime.utc(2026);

final Deck _deck = Deck(
  id: _id,
  folderId: 'f1',
  name: 'Japanese · N5',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

Flashcard _card(String id, String front, String back) => Flashcard(
  id: id,
  deckId: _id,
  front: front,
  back: back,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

FlashcardListDetail _detail(List<Flashcard> cards) => FlashcardListDetail(
  deck: _deck,
  breadcrumb: const <Folder>[],
  cards: cards,
  totalCount: cards.length,
);

final FlashcardListDetail _loaded = _detail(<Flashcard>[
  _card('c1', '日本', 'Japan'),
  _card('c2', '日曜日', 'Sunday'),
  _card('c3', '本', 'book'),
]);

final FlashcardListDetail _loadedDue = _loaded.copyWith(dueCount: 23);

Result<FlashcardListDetail> _ok(FlashcardListDetail d) =>
    (failure: null, data: d);

Future<void> _pump(
  WidgetTester tester,
  Stream<Result<FlashcardListDetail>> stream, {
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
        flashcardListStreamProvider(_id).overrideWith((ref) => stream),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FlashcardListScreen(deckId: _id),
      ),
    ),
  );
}

Stream<Result<FlashcardListDetail>> _value(FlashcardListDetail v) =>
    Stream<Result<FlashcardListDetail>>.value(_ok(v));
Stream<Result<FlashcardListDetail>> _never() =>
    Stream<Result<FlashcardListDetail>>.fromFuture(
      Completer<Result<FlashcardListDetail>>().future,
    );
Stream<Result<FlashcardListDetail>> _error() =>
    Stream<Result<FlashcardListDetail>>.error(Exception('boom'));

void main() {
  group('FlashcardListScreen states', () {
    testWidgets('loaded lists cards + add-card FAB', (tester) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();
      // The row title combines front — back (mock `06` `list-row-title`).
      expect(find.text('日本 — Japan'), findsOneWidget);
      // Cards have no progress → the NEW SRS subtitle (mock `06` `list-row-meta`).
      expect(find.text('New · not studied'), findsWidgets);
      expect(find.byType(MxFab), findsOneWidget);
      // The sort control is exposed so the user can reorder (WBS 2.23.1).
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
      // The search dock is persistent while the deck has cards (kit `06`) — the
      // dock owns search, so there is no app-bar search-toggle icon.
      expect(find.byType(FlashcardListSearchDock), findsOneWidget);
    });

    testWidgets('search dock is hidden in empty / reorder states', (
      tester,
    ) async {
      // Empty deck: nothing to search → no dock.
      await _pump(tester, _value(_detail(const <Flashcard>[])));
      await tester.pumpAndSettle();
      expect(find.byType(FlashcardListSearchDock), findsNothing);

      // Reorder mode removes the dock (kit `06` reorder).
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reorder cards'));
      await tester.pumpAndSettle();
      expect(find.byType(FlashcardListSearchDock), findsNothing);
    });

    testWidgets('overline shows the deck due badge when dueCount > 0', (
      tester,
    ) async {
      await _pump(tester, _value(_loadedDue));
      await tester.pumpAndSettle();
      expect(find.text('23 due'), findsOneWidget); // beside the count overline
    });

    testWidgets('no due badge when nothing is due', (tester) async {
      await _pump(tester, _value(_loaded)); // dueCount defaults to 0
      await tester.pumpAndSettle();
      expect(find.textContaining(' due'), findsNothing);
    });

    testWidgets('deck overflow → Reorder cards enters reorder mode (2.14.2)', (
      tester,
    ) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      // Kebab opens the overflow sheet with Reorder cards + Delete deck.
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Reorder cards'), findsOneWidget);
      expect(find.text('Delete deck'), findsOneWidget);

      // Entering reorder mode swaps to the reorder list with drag handles + Done.
      await tester.tap(find.text('Reorder cards'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('flashcard_reorder_list')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
      expect(find.byIcon(Icons.close), findsOneWidget); // X (cancel)
      expect(find.text('Done'), findsOneWidget); // primary pill
      expect(find.text('Drag the handles to reorder cards.'), findsOneWidget);

      // Done exits reorder mode back to the normal list.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('flashcard_reorder_list')),
        findsNothing,
      );
    });

    testWidgets('reorder mode X cancels back to the normal list', (
      tester,
    ) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reorder cards'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('flashcard_reorder_list')),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('flashcard_reorder_list')),
        findsNothing,
      );
      expect(find.byType(MxFab), findsOneWidget); // FAB restored
    });

    testWidgets('empty deck shows the add-card CTA', (tester) async {
      await _pump(tester, _value(_detail(const <Flashcard>[])));
      await tester.pumpAndSettle();
      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text('Add card'), findsWidgets);
    });

    testWidgets('error renders the error state', (tester) async {
      await _pump(tester, _error());
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
    });

    testWidgets('long-press a card opens the delete confirm (WBS 2.13.2)', (
      tester,
    ) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('日本 — Japan'));
      await tester.pumpAndSettle();
      // The destructive confirm dialog is shown before any deletion.
      expect(find.text('Delete this card?'), findsOneWidget);

      // Cancelling dismisses it without deleting (the card stays).
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this card?'), findsNothing);
      expect(find.text('日本 — Japan'), findsOneWidget);
    });
  });

  group('FlashcardListScreen goldens', () {
    final Map<String, Stream<Result<FlashcardListDetail>> Function()> cases =
        <String, Stream<Result<FlashcardListDetail>> Function()>{
          'loaded': () => _value(_loaded),
          'loaded-due': () => _value(_loadedDue),
          'empty': () => _value(_detail(const <Flashcard>[])),
          'loading': _never,
          'error': _error,
        };
    for (final MapEntry<String, Stream<Result<FlashcardListDetail>> Function()>
        c
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await _pump(tester, c.value(), brightness: brightness, golden: true);
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(FlashcardListScreen),
            matchesGoldenFile(
              'goldens/flashcard_list_${c.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }

    // Search matched nothing: the server-side filtered stream yields no cards
    // even though the deck still has cards, so the total stays positive.
    final FlashcardListDetail noMatch = FlashcardListDetail(
      deck: _deck,
      breadcrumb: const <Folder>[],
      cards: const <Flashcard>[],
      totalCount: 3,
    );
    for (final Brightness brightness in Brightness.values) {
      testWidgets('search-no-results — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          _value(noMatch),
          brightness: brightness,
          golden: true,
        );
        await tester.pumpAndSettle();
        // The search dock is persistent (no app-bar toggle): type into it.
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlashcardListScreen),
          matchesGoldenFile(
            'goldens/flashcard_list_search-no-results__${brightness.name}.png',
          ),
        );
      });
    }

    // Reorder mode (WBS 2.14.2): entered via the deck overflow → Reorder cards.
    for (final Brightness brightness in Brightness.values) {
      testWidgets('reorder — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          _value(_loaded),
          brightness: brightness,
          golden: true,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reorder cards'));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlashcardListScreen),
          matchesGoldenFile(
            'goldens/flashcard_list_reorder__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
