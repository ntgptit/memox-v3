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
      expect(find.text('日本'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
      expect(find.byType(MxFab), findsOneWidget);
      // The sort control is exposed so the user can reorder (WBS 2.23.1).
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
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
  });

  group('FlashcardListScreen goldens', () {
    final Map<String, Stream<Result<FlashcardListDetail>> Function()> cases =
        <String, Stream<Result<FlashcardListDetail>> Function()>{
          'loaded': () => _value(_loaded),
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
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
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
  });
}
