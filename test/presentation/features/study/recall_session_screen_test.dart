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
import 'package:memox/presentation/features/study/screens/recall_session_screen.dart';

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

List<StudySessionReviewItem> _cards() => <StudySessionReviewItem>[
  _item('水曜日', 'Wednesday', 0, pronunciation: 'suiyoubi'),
  _item('木曜日', 'Thursday', 1, pronunciation: 'mokuyoubi'),
];

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionReview> Function() review,
  RecordStudySessionAnswerUseCase? record,
  Brightness brightness = Brightness.light,
}) async {
  // Size to the phone surface so the full card + grade row lay out.
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
        home: const RecallSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('RecallSessionScreen', () {
    testWidgets('hidden: prompt + reading + hint + Show answer + count', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_cards()));
      expect(find.text('RECALL THE MEANING'), findsOneWidget); // overline
      expect(find.text('水曜日'), findsOneWidget); // the front
      expect(find.text('suiyoubi'), findsOneWidget); // the reading
      expect(find.text('Say it in your head, then reveal.'), findsOneWidget);
      expect(find.text('Show answer'), findsOneWidget);
      expect(
        find.text('Wednesday'),
        findsNothing,
      ); // back hidden until revealed
      expect(find.text('0 / 2'), findsOneWidget);
    });

    testWidgets('Show answer reveals the back + the grade row', (tester) async {
      await _pump(tester, review: () async => _review(_cards()));
      await tester.tap(find.text('Show answer'));
      await tester.pump();
      expect(find.text('ANSWER'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget); // the back
      expect(find.text('HOW WELL DID YOU KNOW IT?'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Show answer'), findsNothing); // CTA replaced
    });

    testWidgets('Got it → records perfect + advances to the next card', (
      tester,
    ) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_cards()),
        record: record,
      );
      await tester.tap(find.text('Show answer'));
      await tester.pump();
      await tester.tap(find.text('Got it'));
      await tester.pump();
      expect(record.recorded, <AttemptResult>[AttemptResult.perfect]);
      expect(find.text('1 / 2'), findsOneWidget); // advanced
      expect(find.text('木曜日'), findsOneWidget); // the next front
      expect(find.text('Show answer'), findsOneWidget); // back hidden again
    });

    testWidgets('Missed → records forgot', (tester) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_cards()),
        record: record,
      );
      await tester.tap(find.text('Show answer'));
      await tester.pump();
      await tester.tap(find.text('Missed'));
      await tester.pump();
      expect(record.recorded, <AttemptResult>[AttemptResult.forgot]);
    });

    testWidgets('grading the last card finalizes + routes to result', (
      tester,
    ) async {
      final _FakeFinalize finalize = _FakeFinalize();
      final GoRouter router = GoRouter(
        initialLocation: '/r',
        routes: <RouteBase>[
          GoRoute(
            path: '/r',
            builder: (_, _) => const RecallSessionScreen(sessionId: _sid),
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
              (ref) => Future<StudySessionReview>.value(
                _review(<StudySessionReviewItem>[
                  _item('水曜日', 'Wednesday', 0, pronunciation: 'suiyoubi'),
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
      await tester.tap(find.text('Show answer'));
      await tester.pump();
      await tester.tap(find.text('Got it')); // last card → finalize + route
      await tester.pumpAndSettle();
      expect(finalize.called, isTrue);
      expect(find.text('RESULT'), findsOneWidget);
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
  });

  group('RecallSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('recall-hidden — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_cards()),
        );
        await expectLater(
          find.byType(RecallSessionScreen),
          matchesGoldenFile(
            'goldens/recall_session_hidden__${brightness.name}.png',
          ),
        );
      });

      testWidgets('recall-revealed — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_cards()),
        );
        await tester.tap(find.text('Show answer'));
        await tester.pump();
        await expectLater(
          find.byType(RecallSessionScreen),
          matchesGoldenFile(
            'goldens/recall_session_revealed__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
