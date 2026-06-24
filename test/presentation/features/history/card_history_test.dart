import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/history/screens/card_history_screen.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/features/history/widgets/card_history_event_row.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

import '../../../support/golden_harness.dart';

const String _deckId = 'd1';
const String _cardId = 'c1';

// Fixed past dates → the meta line always renders the absolute "MMM d" branch,
// so goldens stay deterministic regardless of the run date.
final int _created = DateTime(2026, 2, 24, 14, 2).millisecondsSinceEpoch;
int _at(int month, int day, int h, int m) =>
    DateTime(2026, month, day, h, m).millisecondsSinceEpoch;

CardHistory _loaded() => CardHistory(
  header: CardHistoryHeader(
    front: '日本 — Japan',
    deckName: 'Japanese · N5',
    boxNumber: 4,
    reviewCount: 18,
    lapseCount: 1,
    createdAt: _created,
    avgDurationMs: 5400,
  ),
  events: <CardHistoryEvent>[
    CardHistoryEvent.attempt(
      occurredAt: _at(3, 2, 9, 30),
      result: AttemptResult.perfect,
      mode: StudyMode.review,
      boxBefore: 3,
      boxAfter: 4,
      durationMs: 4200,
    ),
    CardHistoryEvent.attempt(
      occurredAt: _at(2, 28, 8, 5),
      result: AttemptResult.recovered,
      mode: StudyMode.review,
      boxBefore: 3,
      boxAfter: 3,
      durationMs: 2800,
    ),
    CardHistoryEvent.attempt(
      occurredAt: _at(2, 26, 21, 10),
      result: AttemptResult.forgot,
      mode: StudyMode.review,
      boxBefore: 4,
      boxAfter: 1,
      durationMs: 11000,
    ),
    CardHistoryEvent.lifecycle(
      occurredAt: _created,
      kind: CardEventKind.created,
    ),
  ],
);

CardHistory _empty() => CardHistory(
  header: CardHistoryHeader(
    front: '日本 — Japan',
    deckName: 'Japanese · N5',
    boxNumber: 1,
    reviewCount: 0,
    lapseCount: 0,
    createdAt: _created,
  ),
  events: <CardHistoryEvent>[
    CardHistoryEvent.lifecycle(
      occurredAt: _created,
      kind: CardEventKind.created,
    ),
  ],
);

FlashcardListDetail _breadcrumbDetail() {
  final DateTime t = DateTime(2026, 1, 1);
  return FlashcardListDetail(
    deck: Deck(
      id: _deckId,
      folderId: 'f1',
      name: 'Japanese · N5',
      targetLanguage: TargetLanguage.english,
      sortOrder: 0,
      createdAt: t,
      updatedAt: t,
    ),
    breadcrumb: <Folder>[
      Folder(
        id: 'f1',
        parentId: null,
        name: 'Languages',
        contentMode: ContentMode.decks,
        sortOrder: 0,
        createdAt: t,
        updatedAt: t,
      ),
    ],
    cards: const <Flashcard>[],
    totalCount: 0,
  );
}

Result<CardHistory> _ok(CardHistory h) => (failure: null, data: h);
Result<CardHistory> _fail() => (
  failure: const Failure.storage(
    operation: StorageOp.read,
    table: 'study_attempts',
    cause: 'boom',
  ),
  data: null,
);
Future<Result<CardHistory>> _never() => Completer<Result<CardHistory>>().future;

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<Result<CardHistory>> Function() history,
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
        cardHistoryProvider(_cardId).overrideWith((ref) => history()),
        flashcardListStreamProvider(_deckId).overrideWith(
          (ref) => Stream<Result<FlashcardListDetail>>.value((
            failure: null,
            data: _breadcrumbDetail(),
          )),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CardHistoryScreen(deckId: _deckId, flashcardId: _cardId),
      ),
    ),
  );
}

void main() {
  group('CardHistoryScreen states', () {
    testWidgets('loaded shows header stats + the activity feed', (
      tester,
    ) async {
      await _pump(tester, history: () => _ok(_loaded()));
      await tester.pumpAndSettle();

      expect(find.text('日本 — Japan'), findsOneWidget);
      expect(find.text('Box 4'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.byType(CardHistoryEventRow), findsNWidgets(4));
      expect(find.text('Reviewed · Correct'), findsOneWidget);
      expect(find.text('Card created'), findsOneWidget);
      // Breadcrumb leaf.
      expect(find.text('Languages'), findsOneWidget);
    });

    testWidgets('no attempts shows the empty state', (tester) async {
      await _pump(tester, history: () => _ok(_empty()));
      await tester.pumpAndSettle();

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text('No history yet'), findsOneWidget);
      expect(find.byType(CardHistoryEventRow), findsNothing);
    });

    testWidgets('loading shows the loading state', (tester) async {
      await _pump(tester, history: _never);
      await tester.pump();
      expect(find.byType(MxLoadingState), findsOneWidget);
    });

    testWidgets('failure shows the error state with retry', (tester) async {
      await _pump(tester, history: _fail);
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('CardHistoryScreen goldens', () {
    final Map<String, FutureOr<Result<CardHistory>> Function()> cases =
        <String, FutureOr<Result<CardHistory>> Function()>{
          'loaded': () => _ok(_loaded()),
          'empty': () => _ok(_empty()),
          'loading': _never,
          'error': _fail,
        };
    for (final MapEntry<String, FutureOr<Result<CardHistory>> Function()> entry
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            history: entry.value,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(CardHistoryScreen),
            matchesGoldenFile(
              'goldens/card_history_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
