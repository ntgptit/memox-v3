import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_motion.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/finalize_study_session_usecase.dart';
import 'package:memox/domain/usecases/study/record_study_session_answer_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/features/study/screens/guess_session_screen.dart';

import '../../../support/golden_harness.dart';

/// Records each graded result without touching the DB.
class _FakeRecordAnswer implements RecordStudySessionAnswerUseCase {
  final List<AttemptResult> recorded = <AttemptResult>[];

  @override
  StudyRepository get repository => throw UnimplementedError();

  @override
  Future<Result<void>> call({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
  }) async {
    recorded.add(result);
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

StudySessionReviewItem _item(
  String front,
  String back,
  int i, {
  String? pronunciation,
}) => StudySessionReviewItem(
  sessionItemId: 'i$i',
  flashcardId: 'c$i',
  front: front,
  back: back,
  exampleSentence: null,
  pronunciation: pronunciation,
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
  _item('먹다', 'to eat', 0, pronunciation: 'meokda'),
  _item('물', 'water', 1),
  _item('하늘', 'sky', 2),
  _item('책', 'book', 3),
  _item('문', 'door', 4),
];

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionReview> Function() review,
  RecordStudySessionAnswerUseCase? record,
  Brightness brightness = Brightness.light,
}) async {
  // Size to the phone surface for every test so the full option list + Next
  // button lay out (the default 800×600 pushes the last option below the fold).
  tester.view.physicalSize = kGoldenSurface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studySessionReviewProvider(_sid).overrideWith((ref) => review()),
        if (record != null)
          recordStudySessionAnswerUseCaseProvider.overrideWithValue(record),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GuessSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('GuessSessionScreen', () {
    testWidgets('shell: prompt + reading + option set + count', (tester) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      expect(find.text('WHAT DOES THIS MEAN?'), findsOneWidget); // overline
      expect(find.text('먹다'), findsOneWidget); // the front (prompt)
      expect(find.text('meokda'), findsOneWidget); // the reading
      expect(find.text('to eat'), findsOneWidget); // the correct option
      expect(find.text('water'), findsOneWidget); // a distractor
      expect(find.text('0 / 5'), findsOneWidget);
      // mx-node parity: shared study chrome (StudyShell → exit + progress).
      expect(
        find.byKey(const ValueKey<String>('mx-node:study-session/exit')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('mx-node:study-session/progress')),
        findsOneWidget,
      );
    });

    testWidgets('a full option set has 5 options (correct + 4 distractors)', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      // The 4 other cards' backs are all distractors here.
      for (final String back in <String>['water', 'sky', 'book', 'door']) {
        expect(find.text(back), findsOneWidget);
      }
      expect(find.text('A'), findsOneWidget); // lettered badges
      expect(find.text('E'), findsOneWidget);
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

    testWidgets('pick the correct option → records perfect + reveals ✓', (
      tester,
    ) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_fiveCards()),
        record: record,
      );
      await tester.tap(find.text('to eat')); // the target's own back = correct
      await tester.pump(); // one frame: reveal, before the auto-advance timer
      expect(record.recorded, <AttemptResult>[AttemptResult.perfect]);
      expect(find.byIcon(Icons.check), findsOneWidget); // the correct ✓
      // Only the app-bar ✕ exit uses Icons.close (no wrong-pick ✗ on a correct answer).
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        find.text('Tap to continue'),
        findsOneWidget,
      ); // the countdown footer
    });

    testWidgets('pick a wrong option → records forgot + reveals ✗ and ✓', (
      tester,
    ) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_fiveCards()),
        record: record,
      );
      await tester.tap(find.text('water')); // a distractor = wrong
      await tester.pump(); // one frame: reveal, before the auto-advance timer
      expect(record.recorded, <AttemptResult>[AttemptResult.forgot]);
      // The correct option reveals ✓; the wrong pick reveals ✗ (Icons.close),
      // alongside the app-bar ✕ exit → two close icons.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('the countdown auto-advances to the next card', (tester) async {
      await _pump(
        tester,
        review: () async => _review(_fiveCards()),
        record: _FakeRecordAnswer(),
      );
      await tester.tap(find.text('to eat')); // answer card 1
      await tester.pump();
      expect(find.text('0 / 5'), findsOneWidget); // not yet advanced
      // Wait out the correct-pick countdown (0.8s) → the timer advances.
      await tester.pump(AppMotion.guessRevealCorrect);
      await tester.pump();
      expect(find.text('1 / 5'), findsOneWidget); // advanced to card 2
      expect(find.text('Tap to continue'), findsNothing); // fresh question
    });

    testWidgets('answering the last card finalizes + routes to result', (
      tester,
    ) async {
      final _FakeFinalize finalize = _FakeFinalize();
      final GoRouter router = GoRouter(
        initialLocation: '/g',
        routes: <RouteBase>[
          GoRoute(
            path: '/g',
            builder: (_, _) => const GuessSessionScreen(sessionId: _sid),
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
            // A single-card session: one option (the correct back), one card.
            studySessionReviewProvider(_sid).overrideWith(
              (ref) => Future<StudySessionReview>.value(
                _review(<StudySessionReviewItem>[
                  _item('먹다', 'to eat', 0, pronunciation: 'meokda'),
                ]),
              ),
            ),
            recordStudySessionAnswerUseCaseProvider.overrideWithValue(
              _FakeRecordAnswer(),
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
      await tester.tap(find.text('to eat')); // answer the only card
      await tester.pump();
      await tester.tap(find.text('Tap to continue')); // skip → finalize + route
      await tester.pumpAndSettle();
      expect(finalize.called, isTrue);
      expect(find.text('RESULT'), findsOneWidget);
    });
  });

  group('GuessSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('guess-question — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_fiveCards()),
        );
        await expectLater(
          find.byType(GuessSessionScreen),
          matchesGoldenFile(
            'goldens/guess_session_question__${brightness.name}.png',
          ),
        );
      });

      testWidgets('guess-answered — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_fiveCards()),
          record: _FakeRecordAnswer(),
        );
        await tester.tap(find.text('water')); // a wrong pick → ✗ + correct ✓
        // One frame only — pumpAndSettle would run the countdown + auto-advance.
        await tester.pump();
        await expectLater(
          find.byType(GuessSessionScreen),
          matchesGoldenFile(
            'goldens/guess_session_answered__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
