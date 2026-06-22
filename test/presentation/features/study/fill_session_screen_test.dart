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
import 'package:memox/presentation/features/study/screens/fill_session_screen.dart';

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

List<StudySessionReviewItem> _cards() => <StudySessionReviewItem>[
  _item('yama', 'mountain', 0),
  _item('umi', 'sea', 1),
];

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionReview> Function() review,
  RecordStudySessionAnswerUseCase? record,
  Brightness brightness = Brightness.light,
}) async {
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
        home: const FillSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('FillSessionScreen', () {
    testWidgets('typing: hint + answer field + Check + count', (tester) async {
      await _pump(tester, review: () async => _review(_cards()));
      expect(find.text('TYPE THE ANSWER'), findsOneWidget); // overline
      expect(find.text('mountain'), findsOneWidget); // the hint (back)
      expect(find.text('YOUR ANSWER'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Check answer'), findsOneWidget);
      expect(find.text('0 / 2'), findsOneWidget);
    });

    testWidgets('a correct answer → ✓ feedback + Next', (tester) async {
      await _pump(tester, review: () async => _review(_cards()));
      await tester.enterText(find.byType(TextField), 'yama');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsWidgets); // the ✓ glyph
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Check answer'), findsNothing);
    });

    testWidgets('a wrong answer → shows the correct answer + Retry/Next', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_cards()));
      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      expect(find.text('Not quite — see the answer below.'), findsOneWidget);
      expect(find.text('CORRECT ANSWER'), findsOneWidget);
      expect(find.text('yama'), findsOneWidget); // the correct front
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Retry returns to typing', (tester) async {
      await _pump(tester, review: () async => _review(_cards()));
      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('Check answer'), findsOneWidget); // back to typing
      expect(find.text('CORRECT ANSWER'), findsNothing);
    });

    testWidgets('correct → Next records perfect + advances', (tester) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_cards()),
        record: record,
      );
      await tester.enterText(find.byType(TextField), 'yama');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(record.recorded, <AttemptResult>[AttemptResult.perfect]);
      expect(find.text('1 / 2'), findsOneWidget); // advanced
      expect(find.text('sea'), findsOneWidget); // the next hint
    });

    testWidgets('wrong → Next records forgot + advances', (tester) async {
      final _FakeRecordAnswer record = _FakeRecordAnswer();
      await _pump(
        tester,
        review: () async => _review(_cards()),
        record: record,
      );
      await tester.enterText(find.byType(TextField), 'nope');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(record.recorded, <AttemptResult>[AttemptResult.forgot]);
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('grading the last card finalizes + routes to result', (
      tester,
    ) async {
      final _FakeFinalize finalize = _FakeFinalize();
      final GoRouter router = GoRouter(
        initialLocation: '/f',
        routes: <RouteBase>[
          GoRoute(
            path: '/f',
            builder: (_, _) => const FillSessionScreen(sessionId: _sid),
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
                _review(<StudySessionReviewItem>[_item('yama', 'mountain', 0)]),
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
      await tester.enterText(find.byType(TextField), 'yama');
      await tester.pump(); // flush canSubmit enablement
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      await tester.tap(find.text('Next')); // last card → finalize + route
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

  group('FillSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('fill-typing — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_cards()),
        );
        await expectLater(
          find.byType(FillSessionScreen),
          matchesGoldenFile(
            'goldens/fill_session_typing__${brightness.name}.png',
          ),
        );
      });

      testWidgets('fill-wrong — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_cards()),
        );
        await tester.enterText(find.byType(TextField), 'wrong');
        await tester.pump(); // flush canSubmit enablement
        await tester.tap(find.text('Check answer'));
        await tester.pump();
        await expectLater(
          find.byType(FillSessionScreen),
          matchesGoldenFile(
            'goldens/fill_session_wrong__${brightness.name}.png',
          ),
        );
      });

      testWidgets('fill-correct — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          review: () async => _review(_cards()),
        );
        await tester.enterText(find.byType(TextField), 'yama');
        await tester.pump(); // flush canSubmit enablement
        await tester.tap(find.text('Check answer'));
        await tester.pump();
        await expectLater(
          find.byType(FillSessionScreen),
          matchesGoldenFile(
            'goldens/fill_session_correct__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
