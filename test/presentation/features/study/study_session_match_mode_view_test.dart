import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/features/study/widgets/study_session_match_mode_view.dart';
import 'package:memox/presentation/shared/widgets/study/mx_match_tile.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(
    this.reviewResult, {
    this.resultResult = const Result<StudySessionResult>.err(
      Failure.notFound(entity: 'study_session', id: 'unused'),
    ),
  });

  Result<StudySessionReview> reviewResult;
  Result<StudySessionResult> resultResult;
  final Result<void> recordResult = const Result<void>.ok(null);
  final Result<void> finalizeResult = const Result<void>.ok(null);
  int reviewCalls = 0;
  int resultCalls = 0;
  int recordCalls = 0;
  int finalizeCalls = 0;
  int startCalls = 0;
  int findResumableCalls = 0;
  int latestSummaryCalls = 0;
  int cancelCalls = 0;
  int restartCalls = 0;
  int createCalls = 0;
  int buryCalls = 0;
  int suspendCalls = 0;
  final List<StudyMatchEvaluation> evaluations = <StudyMatchEvaluation>[];
  final List<
    ({
      String sessionId,
      String sessionItemId,
      FlashcardId flashcardId,
      int boardIndex,
      String pairId,
      String selectedFrontCellId,
      String selectedBackCellId,
      FlashcardId expectedFrontFlashcardId,
      FlashcardId expectedBackFlashcardId,
      bool isCorrect,
      StudyMode studyMode,
    })
  >
  recordedEvaluations =
      <
        ({
          String sessionId,
          String sessionItemId,
          FlashcardId flashcardId,
          int boardIndex,
          String pairId,
          String selectedFrontCellId,
          String selectedBackCellId,
          FlashcardId expectedFrontFlashcardId,
          FlashcardId expectedBackFlashcardId,
          bool isCorrect,
          StudyMode studyMode,
        })
      >[];

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = 20,
    StudyMode? mode,
  }) async {
    startCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    int dailyNewLimit = 20,
    StudyMode? mode,
  }) async {
    restartCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  }) async {
    reviewCalls++;
    return reviewResult;
  }

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
    required SessionId sessionId,
  }) async {
    resultCalls++;
    return resultResult;
  }

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    int? durationMs,
  }) async {
    recordCalls++;
    return recordResult;
  }

  @override
  Future<Result<void>> recordMatchEvaluation({
    required SessionId sessionId,
    required String sessionItemId,
    required FlashcardId flashcardId,
    required int boardIndex,
    required String pairId,
    required String selectedFrontCellId,
    required String selectedBackCellId,
    required FlashcardId expectedFrontFlashcardId,
    required FlashcardId expectedBackFlashcardId,
    required bool isCorrect,
    required StudyMode studyMode,
  }) async {
    recordCalls++;
    recordedEvaluations.add((
      sessionId: sessionId,
      sessionItemId: sessionItemId,
      flashcardId: flashcardId,
      boardIndex: boardIndex,
      pairId: pairId,
      selectedFrontCellId: selectedFrontCellId,
      selectedBackCellId: selectedBackCellId,
      expectedFrontFlashcardId: expectedFrontFlashcardId,
      expectedBackFlashcardId: expectedBackFlashcardId,
      isCorrect: isCorrect,
      studyMode: studyMode,
    ));
    final DateTime now = DateTime.now().toUtc();
    evaluations.add(
      StudyMatchEvaluation(
        id: 'eval-${evaluations.length}',
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: flashcardId,
        boardIndex: boardIndex,
        pairId: pairId,
        selectedFrontCellId: selectedFrontCellId,
        selectedBackCellId: selectedBackCellId,
        expectedFrontFlashcardId: expectedFrontFlashcardId,
        expectedBackFlashcardId: expectedBackFlashcardId,
        isCorrect: isCorrect,
        attemptOrder: evaluations.length,
        evaluatedAt: now,
        createdAt: now,
      ),
    );
    return recordResult;
  }

  @override
  Future<Result<List<StudyMatchEvaluation>>> loadMatchEvaluations({
    required SessionId sessionId,
  }) async => Result<List<StudyMatchEvaluation>>.ok(
    evaluations.toList(growable: false),
  );

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async {
    findResumableCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() async {
    latestSummaryCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> cancelStudySession({
    required SessionId sessionId,
  }) async {
    cancelCalls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    buryCalls++;
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    suspendCalls++;
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
  }) async {
    finalizeCalls++;
    return finalizeResult;
  }

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    createCalls++;
    throw UnimplementedError();
  }
}

Widget _routerShell(
  GoRouter router, {
  List<Override> overrides = const <Override>[],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

GoRouter _studyRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) =>
            const Scaffold(body: Text('Home destination')),
      ),
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        builder: (context, state) =>
            const Scaffold(body: Text('Library destination')),
      ),
      ...studyRoutes(rootNavigatorKey),
    ],
  );
}

String _studySessionLocationWithMode(String sessionId, {StudyMode? mode}) {
  final Map<String, String> queryParameters = <String, String>{};
  if (mode != null) {
    queryParameters[RoutePaths.modeQueryParam] = mode.name;
  }
  return Uri(
    path: RoutePaths.studySession(sessionId),
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

StudySessionReview _review({
  required String sessionId,
  required List<({String front, String back})> cards,
}) {
  final DateTime now = DateTime.utc(2026, 1, 1);
  final StudySession session = StudySession(
    id: sessionId,
    entryType: EntryType.deck,
    entryRefId: 'deck-1',
    studyType: StudyType.newCards,
    status: SessionStatus.inProgress,
    startedAt: now,
    updatedAt: now,
  );
  return StudySessionReview(
    session: session,
    items: <StudySessionReviewItem>[
      for (int index = 0; index < cards.length; index++)
        StudySessionReviewItem(
          sessionItem: StudySessionItem(
            id: 'item-$sessionId-$index',
            sessionId: sessionId,
            flashcardId: 'card-$sessionId-$index',
            sortOrder: index,
            createdAt: now,
            updatedAt: now,
          ),
          flashcard: Flashcard(
            id: 'card-$sessionId-$index',
            deckId: 'deck-1',
            front: cards[index].front,
            back: cards[index].back,
            sortOrder: index,
            createdAt: now,
            updatedAt: now,
          ),
          targetLanguage: TargetLanguage.korean,
        ),
    ],
  );
}

StudySessionResult _result({
  required String sessionId,
  required SessionStatus status,
  required int totalCount,
  required int answeredCount,
  required int forgotCount,
  required int passedCount,
}) {
  final DateTime now = DateTime.utc(2026, 1, 1);
  return StudySessionResult(
    session: StudySession(
      id: sessionId,
      entryType: EntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.newCards,
      status: status,
      startedAt: now,
      updatedAt: now,
    ),
    totalCount: totalCount,
    answeredCount: answeredCount,
    forgotCount: forgotCount,
    passedCount: passedCount,
  );
}

MxMatchState _tileState(WidgetTester tester, String label) =>
    tester.widget<MxMatchTile>(find.widgetWithText(MxMatchTile, label)).state;

void main() {
  testWidgets('DT1 onOpen: match mode renders the board shell', (tester) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      Result<StudySessionReview>.ok(
        _review(
          sessionId: 'session-match-mode',
          cards: <({String front, String back})>[
            (front: '공부하다', back: 'to study'),
            (front: '먹다', back: 'to eat'),
            (front: '하늘', back: 'sky'),
            (front: '도서관', back: 'library'),
            (front: '책', back: 'book'),
          ],
        ),
      ),
      resultResult: Result<StudySessionResult>.ok(
        _result(
          sessionId: 'session-match-mode',
          status: SessionStatus.completed,
          totalCount: 5,
          answeredCount: 5,
          forgotCount: 0,
          passedCount: 5,
        ),
      ),
    );
    final GoRouter router = _studyRouter(
      _studySessionLocationWithMode(
        'session-match-mode',
        mode: StudyMode.match,
      ),
    );

    await tester.pumpWidget(
      _routerShell(
        router,
        overrides: <Override>[
          studyRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(StudySessionScreen)),
    );

    expect(find.byType(StudySessionMatchModeView), findsOneWidget);
    expect(find.text(l10n.studySessionMatchModeLabel), findsOneWidget);
    expect(
      find.text(l10n.studySessionMatchBoardIndicator(1, 1, 5)),
      findsOneWidget,
    );
    expect(find.byType(MxMatchTile), findsNWidgets(10));
    expect(repository.reviewCalls, 1);
    expect(repository.recordCalls, 0);
  });

  testWidgets(
    'DT2 wrong pair flashes red and records an append-only evaluation',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-match-wrong',
            cards: <({String front, String back})>[
              (front: '공부하다', back: 'to study'),
              (front: '먹다', back: 'to eat'),
              (front: '하늘', back: 'sky'),
              (front: '도서관', back: 'library'),
              (front: '책', back: 'book'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocationWithMode(
          'session-match-wrong',
          mode: StudyMode.match,
        ),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));

      await tester.tap(find.text('공부하다'));
      await tester.pump(const Duration(milliseconds: 1));
      expect(_tileState(tester, '공부하다'), MxMatchState.selected);

      await tester.tap(find.text('먹다'));
      await tester.pump(const Duration(milliseconds: 1));

      expect(repository.recordCalls, 1);
      expect(repository.recordedEvaluations.single.isCorrect, isFalse);
      expect(_tileState(tester, '공부하다'), MxMatchState.wrong);
      expect(_tileState(tester, '먹다'), MxMatchState.wrong);

      await tester.pump(const Duration(milliseconds: 601));

      expect(_tileState(tester, '공부하다'), MxMatchState.idle);
      expect(_tileState(tester, '먹다'), MxMatchState.idle);
    },
  );

  testWidgets('DT3 matching all pairs finalizes the session and opens result', (
    tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      Result<StudySessionReview>.ok(
        _review(
          sessionId: 'session-match-finalize',
          cards: <({String front, String back})>[
            (front: '공부하다', back: 'to study'),
            (front: '먹다', back: 'to eat'),
            (front: '하늘', back: 'sky'),
            (front: '도서관', back: 'library'),
            (front: '책', back: 'book'),
          ],
        ),
      ),
      resultResult: Result<StudySessionResult>.ok(
        _result(
          sessionId: 'session-match-finalize',
          status: SessionStatus.completed,
          totalCount: 5,
          answeredCount: 5,
          forgotCount: 0,
          passedCount: 5,
        ),
      ),
    );
    final GoRouter router = _studyRouter(
      _studySessionLocationWithMode(
        'session-match-finalize',
        mode: StudyMode.match,
      ),
    );

    await tester.pumpWidget(
      _routerShell(
        router,
        overrides: <Override>[
          studyRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));

    final List<({String front, String back})> pairs =
        <({String front, String back})>[
          (front: '공부하다', back: 'to study'),
          (front: '먹다', back: 'to eat'),
          (front: '하늘', back: 'sky'),
          (front: '도서관', back: 'library'),
          (front: '책', back: 'book'),
        ];

    for (final ({String front, String back}) pair in pairs) {
      await tester.ensureVisible(find.text(pair.front));
      await tester.tap(find.text(pair.front));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.ensureVisible(find.text(pair.back));
      await tester.tap(find.text(pair.back));
      await tester.pump(const Duration(milliseconds: 1));
    }

    await tester.pump(DurationTokens.pageTransition);
    await tester.pump(DurationTokens.pageTransition);

    expect(repository.recordCalls, 5);
    expect(repository.finalizeCalls, 1);
    expect(
      router.routeInformationProvider.value.uri.toString(),
      RoutePaths.studyResult('session-match-finalize'),
    );
  });
}
