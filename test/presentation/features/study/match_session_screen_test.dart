import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/finalize_study_session_usecase.dart';
import 'package:memox/domain/usecases/study/record_match_evaluation_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/features/study/screens/match_session_screen.dart';

import '../../../support/golden_harness.dart';

/// Records the `isCorrect` of each Match evaluation without touching the DB.
class _FakeRecordMatchEval implements RecordMatchEvaluationUseCase {
  final List<bool> recorded = <bool>[];

  @override
  StudyRepository get repository => throw UnimplementedError();

  @override
  Future<Result<void>> call({
    required SessionId sessionId,
    required String sessionItemId,
    required int boardIndex,
    required String pairId,
    required String selectedFrontCellId,
    required String selectedBackCellId,
    required FlashcardId expectedFrontFlashcardId,
    required FlashcardId expectedBackFlashcardId,
    required bool isCorrect,
  }) async {
    recorded.add(isCorrect);
    return (failure: null, data: null);
  }
}

/// Records whether finalize was called (no DB).
class _FakeFinalize implements FinalizeStudySessionUseCase {
  bool called = false;

  @override
  StudyRepository get repository => throw UnimplementedError();

  @override
  Future<Result<void>> call({required SessionId sessionId}) async {
    called = true;
    return (failure: null, data: null);
  }
}

const String _sid = 's1';
final DateTime _t = DateTime.utc(2026);

StudySessionReviewItem _item(String front, String back, int i) =>
    StudySessionReviewItem(
      sessionItemId: 'i$i',
      flashcardId: 'c$i',
      front: front,
      back: back,
      exampleSentence: null,
      pronunciation: null,
      hint: null,
      sortOrder: i,
      answeredAt: null,
    );

StudySessionReview _review(List<StudySessionReviewItem> items) =>
    StudySessionReview(
      session: StudySession(
        id: _sid,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'd1',
          studyType: StudyType.srsReview,
        ),
        status: SessionStatus.inProgress,
        startedAt: _t,
        updatedAt: _t,
      ),
      items: items,
    );

List<StudySessionReviewItem> _fiveCards() => <StudySessionReviewItem>[
  _item('공부하다', 'to study', 0),
  _item('먹다', 'to eat', 1),
  _item('하늘', 'sky', 2),
  _item('도서관', 'library', 3),
  _item('책', 'book', 4),
];

List<StudySessionReviewItem> _tenCards() => <StudySessionReviewItem>[
  ..._fiveCards(),
  _item('의자', 'chair', 5),
  _item('문', 'door', 6),
  _item('창문', 'window', 7),
  _item('컵', 'cup', 8),
  _item('숟가락', 'spoon', 9),
];

/// Tap a card's front then back (a valid pair) and settle the board-advance.
Future<void> _matchPair(WidgetTester tester, String front, String back) async {
  await tester.tap(find.text(front));
  await tester.pump();
  await tester.tap(find.text(back));
  await tester.pumpAndSettle();
}

const List<(String, String)> _board1Pairs = <(String, String)>[
  ('공부하다', 'to study'),
  ('먹다', 'to eat'),
  ('하늘', 'sky'),
  ('도서관', 'library'),
  ('책', 'book'),
];

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionReview> Function() review,
  RecordMatchEvaluationUseCase? record,
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
        studySessionReviewProvider(_sid).overrideWith((ref) => review()),
        if (record != null)
          recordMatchEvaluationUseCaseProvider.overrideWithValue(record),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MatchSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('MatchSessionScreen', () {
    testWidgets('board shell: title + board cells + progress line + count', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      expect(find.text('Match the pairs'), findsOneWidget);
      expect(find.textContaining('Tap a term'), findsOneWidget);
      expect(find.text('공부하다'), findsOneWidget); // a front cell
      expect(find.text('to study'), findsOneWidget); // a back cell
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget); // matched / total
    });

    testWidgets('first board: 7 cards → only the first 5 cards render', (
      tester,
    ) async {
      final List<StudySessionReviewItem> items = <StudySessionReviewItem>[
        ..._fiveCards(),
        _item('의자', 'chair', 5),
        _item('문', 'door', 6),
      ];
      await _pump(tester, review: () async => _review(items));
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
      expect(find.text('0 / 7'), findsOneWidget);
      expect(find.text('의자'), findsNothing); // card 6 is on board 2
    });

    testWidgets('loading shows a spinner', (tester) async {
      await _pump(tester, review: () => Completer<StudySessionReview>().future);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a load failure shows the error surface', (tester) async {
      await _pump(tester, review: () async => throw Exception('boom'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load the session"), findsOneWidget);
    });

    testWidgets('an empty session shows the empty state', (tester) async {
      await _pump(
        tester,
        review: () async => _review(const <StudySessionReviewItem>[]),
      );
      expect(find.text('Nothing to review'), findsOneWidget);
    });

    testWidgets('tap a matching pair → matched + records correct', (
      tester,
    ) async {
      final _FakeRecordMatchEval record = _FakeRecordMatchEval();
      await _pump(
        tester,
        review: () async => _review(_fiveCards()),
        record: record,
      );
      // Tap card 0's front then its back → a valid pair.
      await tester.tap(find.text('공부하다'));
      await tester.pump();
      await tester.tap(find.text('to study'));
      await tester.pumpAndSettle();
      expect(record.recorded, <bool>[true]);
      expect(find.textContaining('1 matched · 4 left'), findsOneWidget);
      expect(find.text('1 / 5'), findsOneWidget);
    });

    testWidgets('tap a wrong pair → records wrong + reverts after the flash', (
      tester,
    ) async {
      final _FakeRecordMatchEval record = _FakeRecordMatchEval();
      await _pump(
        tester,
        review: () async => _review(_fiveCards()),
        record: record,
      );
      // card 0 front + card 1 back → not a pair.
      await tester.tap(find.text('공부하다'));
      await tester.pump();
      await tester.tap(find.text('to eat'));
      await tester.pumpAndSettle(); // flush the ~600ms wrong-flash
      expect(record.recorded, <bool>[false]);
      expect(find.text('0 / 5'), findsOneWidget); // nothing matched
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
    });

    testWidgets('clearing a board advances to the next board', (tester) async {
      // decision: S96
      await _pump(
        tester,
        review: () async => _review(_tenCards()),
        record: _FakeRecordMatchEval(),
      );
      for (final (String front, String back) in _board1Pairs) {
        await _matchPair(tester, front, back);
      }
      // Board two is now shown; the app-bar count carries the cleared board's
      // pairs, and the per-board status line starts fresh.
      expect(find.text('의자'), findsOneWidget); // card 5 front (board 2)
      expect(find.text('5 / 10'), findsOneWidget);
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
      expect(find.text('공부하다'), findsNothing); // board 1 cleared
    });

    testWidgets('clearing the last board finalizes + routes to result', (
      tester,
    ) async {
      // decision: S97
      final _FakeFinalize finalize = _FakeFinalize();
      final GoRouter router = GoRouter(
        initialLocation: '/m',
        routes: <RouteBase>[
          GoRoute(
            path: '/m',
            builder: (_, _) => const MatchSessionScreen(sessionId: _sid),
          ),
          GoRoute(
            path: '/result/:sessionId',
            name: RouteNames.studyResult,
            builder: (_, _) => const Scaffold(body: Text('RESULT')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionReviewProvider(_sid).overrideWith(
              (ref) => Future<StudySessionReview>.value(_review(_fiveCards())),
            ),
            recordMatchEvaluationUseCaseProvider.overrideWithValue(
              _FakeRecordMatchEval(),
            ),
            finalizeStudySessionUseCaseProvider.overrideWithValue(finalize),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final (String front, String back) in _board1Pairs) {
        await _matchPair(tester, front, back);
      }
      await tester.pumpAndSettle();
      expect(finalize.called, isTrue);
      expect(find.text('RESULT'), findsOneWidget);
    });
  });

  group('MatchSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('match-board-fresh — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          review: () async => _review(_fiveCards()),
        );
        await expectLater(
          find.byType(MatchSessionScreen),
          matchesGoldenFile(
            'goldens/match_session_board-fresh__${brightness.name}.png',
          ),
        );
      });

      testWidgets('match-board-mid — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          review: () async => _review(_fiveCards()),
          record: _FakeRecordMatchEval(),
        );
        // One matched pair (green ✓) + one selected cell (blue).
        await tester.tap(find.text('공부하다'));
        await tester.pump();
        await tester.tap(find.text('to study'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('먹다'));
        await tester.pump();
        await expectLater(
          find.byType(MatchSessionScreen),
          matchesGoldenFile(
            'goldens/match_session_board-mid__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
