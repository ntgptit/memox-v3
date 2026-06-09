import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/study/mx_flashcard.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(
    this.reviewResult, {
    this.resultResult = const Result<StudySessionResult>.err(
      Failure.notFound(entity: 'study_session', id: 'unused'),
    ),
    this.recordResult = const Result<void>.ok(null),
    this.finalizeResult = const Result<void>.ok(null),
  });

  Result<StudySessionReview> reviewResult;
  Result<StudySessionResult> resultResult;
  Result<void> recordResult;
  Result<void> finalizeResult;
  int reviewCalls = 0;
  int resultCalls = 0;
  int recordCalls = 0;
  int finalizeCalls = 0;
  int startCalls = 0;
  int findResumableCalls = 0;
  int latestSummaryCalls = 0;
  int cancelCalls = 0;
  int createCalls = 0;
  final List<({String sessionId, String sessionItemId, AttemptResult result})>
      recordedAnswers = <({
    String sessionId,
    String sessionItemId,
    AttemptResult result,
  })>[];

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    startCalls++;
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
  }) async {
    recordCalls++;
    recordedAnswers.add(
      (
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        result: result,
      ),
    );
    return recordResult;
  }

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

Widget _materialShell(
  Widget child, {
  List<Override> overrides = const <Override>[],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

GoRouter _studyRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: studyRoutes(rootNavigatorKey),
  );
}

GoRouter _studyResultRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const Scaffold(
          body: Text('Home destination'),
        ),
      ),
      GoRoute(
        path: RoutePaths.library,
        name: RouteNames.library,
        builder: (context, state) => const Scaffold(
          body: Text('Library destination'),
        ),
      ),
      ...studyRoutes(rootNavigatorKey),
    ],
  );
}

String _studySessionLocation(String sessionId) =>
    RoutePaths.studySession(sessionId);

StudySessionReview _review({
  required String sessionId,
  required List<({String front, String back})> cards,
  Set<int> answeredIndices = const <int>{},
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
            answeredAt: answeredIndices.contains(index) ? now : null,
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

void main() {
  testWidgets(
    'navigates between cards and resets reveal state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-nav',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-nav'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );
      final Finder previousFinder = find.widgetWithText(
        MxActionButton,
        l10n.studyPreviousAction,
      );
      final Finder nextFinder = find.widgetWithText(
        MxActionButton,
        l10n.studyNextAction,
      );
      final Finder showAnswerFinder = find.text(l10n.studySessionShowAction);

      expect(find.text(l10n.studySessionProgressLabel(1, 2)), findsOneWidget);
      expect(find.text('Front 1'), findsOneWidget);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text('Front 2'), findsNothing);
      expect(find.text('Back 2'), findsNothing);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNotNull);
      expect(repository.reviewCalls, 1);
      expect(repository.recordCalls, 0);

      await tester.tap(showAnswerFinder);
      await tester.pumpAndSettle();

      expect(find.text('Back 1'), findsOneWidget);
      expect(find.text(l10n.studySessionHideAction), findsOneWidget);

      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(find.text(l10n.studySessionProgressLabel(2, 2)), findsOneWidget);
      expect(find.text('Front 1'), findsNothing);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text('Front 2'), findsOneWidget);
      expect(find.text('Back 2'), findsNothing);
      expect(find.text(l10n.studySessionShowAction), findsOneWidget);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNotNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNull);

      await tester.tap(previousFinder);
      await tester.pumpAndSettle();

      expect(find.text(l10n.studySessionProgressLabel(1, 2)), findsOneWidget);
      expect(find.text('Front 1'), findsOneWidget);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text('Front 2'), findsNothing);
      expect(find.text('Back 2'), findsNothing);
      expect(find.text(l10n.studySessionShowAction), findsOneWidget);
      expect(find.text(l10n.studySessionHideAction), findsNothing);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNotNull);
    },
  );

  testWidgets(
    'before reveal the grade buttons are hidden and after reveal they appear',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-1',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-1'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );
      final Finder previousFinder = find.widgetWithText(
        MxActionButton,
        l10n.studyPreviousAction,
      );
      final Finder nextFinder = find.widgetWithText(
        MxActionButton,
        l10n.studyNextAction,
      );
      final Finder showAnswerFinder = find.text(l10n.studySessionShowAction);

      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.byType(MxFlashcard), findsOneWidget);
      expect(find.text(l10n.studySessionProgressLabel(1, 1)), findsOneWidget);
      expect(find.text('Front 1'), findsOneWidget);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text(l10n.studyForgotAction), findsNothing);
      expect(find.text(l10n.studyGotItAction), findsNothing);
      expect(find.text(l10n.studyFinalizeAction), findsNothing);
      expect(showAnswerFinder, findsOneWidget);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNull);
      expect(repository.reviewCalls, 1);
      expect(repository.recordCalls, 0);
      expect(repository.startCalls, 0);
      expect(repository.findResumableCalls, 0);
      expect(repository.latestSummaryCalls, 0);
      expect(repository.cancelCalls, 0);
      expect(repository.createCalls, 0);

      await tester.tap(showAnswerFinder);
      await tester.pumpAndSettle();

      expect(find.text('Front 1'), findsNothing);
      expect(find.text('Back 1'), findsOneWidget);
      expect(find.text(l10n.studyForgotAction), findsOneWidget);
      expect(find.text(l10n.studyGotItAction), findsOneWidget);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNull);
      expect(repository.recordCalls, 0);
    },
  );

  testWidgets(
    'tapping got it records an attempt, marks the item answered, and advances to the next unanswered card',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-2',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
              (front: 'Front 3', back: 'Back 3'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-2'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );
      final Finder showAnswerFinder = find.text(l10n.studySessionShowAction);

      await tester.tap(showAnswerFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.sessionId, 'session-2');
      expect(repository.recordedAnswers.single.sessionItemId, 'item-session-2-0');
      expect(repository.recordedAnswers.single.result, AttemptResult.perfect);
      expect(find.text('Front 1'), findsNothing);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text('Front 2'), findsOneWidget);
      expect(find.text('Back 2'), findsNothing);
      expect(find.text(l10n.studySessionProgressLabel(2, 3)), findsOneWidget);
      expect(find.text(l10n.studySessionShowAction), findsOneWidget);
      expect(find.text(l10n.studySessionHideAction), findsNothing);
      expect(find.text(l10n.studyForgotAction), findsNothing);
      expect(find.text(l10n.studyGotItAction), findsNothing);
    },
  );

  testWidgets(
    'tapping forgot records an attempt, marks the item answered, and advances to the next unanswered card',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-3',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-3'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyForgotAction));
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(repository.recordedAnswers.single.result, AttemptResult.forgot);
      expect(find.text('Front 1'), findsNothing);
      expect(find.text('Front 2'), findsOneWidget);
      expect(find.text(l10n.studySessionProgressLabel(2, 2)), findsOneWidget);
      expect(find.text(l10n.studyForgotAction), findsNothing);
      expect(find.text(l10n.studyGotItAction), findsNothing);
      expect(find.text(l10n.studySessionShowAction), findsOneWidget);
    },
  );

  testWidgets(
    'Finish Session CTA appears only after all cards are answered',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-4',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-4'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 2);
      expect(repository.finalizeCalls, 0);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.text(l10n.studySessionAllAnsweredMessage), findsOneWidget);
      expect(find.text(l10n.studyFinalizeAction), findsOneWidget);
      expect(find.text('Front 2'), findsOneWidget);
      expect(find.text('Back 2'), findsNothing);
      expect(find.text(l10n.studyForgotAction), findsNothing);
      expect(find.text(l10n.studyGotItAction), findsNothing);
    },
  );

  testWidgets(
    'tapping Finish Session commits the finalization and navigates to the result placeholder',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-6',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-6'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyFinalizeAction));
      await tester.pumpAndSettle();

      expect(repository.finalizeCalls, 1);
      expect(find.byType(StudySessionScreen), findsNothing);
      expect(find.byType(StudyResultScreen), findsOneWidget);
    },
  );

  testWidgets(
    'when Finish Session fails the user stays on the session and sees a controlled error',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-7',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
        finalizeResult: const Result<void>.err(
          Failure.finalization(sessionId: 'session-7'),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-7'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyFinalizeAction));
      await tester.pumpAndSettle();

      expect(repository.finalizeCalls, 1);
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.text(l10n.studySessionFinalizeFailedMessage), findsOneWidget);
      expect(find.text(l10n.studyFinalizeAction), findsOneWidget);
    },
  );

  testWidgets(
    'shows a controlled save failure message and keeps the user on the current card when recording fails',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-5',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
            ],
          ),
        ),
        recordResult: const Result<void>.err(
          Failure.storage(
            operation: StorageOp.transaction,
            cause: 'boom',
            table: 'study_attempts',
          ),
        ),
      );
      final GoRouter router = _studyRouter(
        _studySessionLocation('session-5'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudySessionScreen)),
      );

      await tester.tap(find.text(l10n.studySessionShowAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.studyGotItAction));
      await tester.pumpAndSettle();

      expect(repository.recordCalls, 1);
      expect(find.text(l10n.studySessionProgressLabel(1, 2)), findsOneWidget);
      expect(find.text('Back 1'), findsOneWidget);
      expect(find.text('Front 2'), findsNothing);
      expect(find.text(l10n.studySessionRecordFailedMessage), findsOneWidget);
      expect(find.text(l10n.studySessionHideAction), findsOneWidget);
      expect(find.text(l10n.studyForgotAction), findsOneWidget);
      expect(find.text(l10n.studyGotItAction), findsOneWidget);
      expect(
        tester.widget<MxActionButton>(
          find.widgetWithText(MxActionButton, l10n.studyGotItAction),
        ).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('shows a controlled not-found state when the session is missing', (
    tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudySessionReview>.err(
        Failure.notFound(entity: 'study_session', id: 'missing-session'),
      ),
    );
    final GoRouter router = _studyRouter(
      _studySessionLocation('missing-session'),
    );

    await tester.pumpWidget(
      _routerShell(
        router,
        overrides: <Override>[
          studyRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(StudySessionScreen)),
    );

    expect(find.byType(StudySessionScreen), findsOneWidget);
    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.text(l10n.studySessionNotFoundTitle), findsOneWidget);
    expect(find.text(l10n.studySessionNotFoundMessage), findsOneWidget);
    expect(find.text(l10n.commonBack), findsOneWidget);
    expect(repository.reviewCalls, greaterThan(0));
    expect(repository.recordCalls, 0);
  });

  testWidgets(
    'empty result session id shows a controlled invalid state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: 'unused'),
        ),
      );

      await tester.pumpWidget(
        _materialShell(
          const StudyResultScreen(sessionId: ''),
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyResultScreen)),
      );

      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text(l10n.studyResultInvalidTitle), findsOneWidget);
      expect(find.text(l10n.studyResultInvalidMessage), findsOneWidget);
      expect(repository.resultCalls, 0);
    },
  );

  testWidgets(
    'result route renders the real Study Result screen and shows the summary counts',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: 'unused'),
        ),
        resultResult: Result<StudySessionResult>.ok(
          _result(
            sessionId: 'session-result',
            status: SessionStatus.completed,
            totalCount: 4,
            answeredCount: 4,
            forgotCount: 1,
            passedCount: 3,
          ),
        ),
      );
      final GoRouter router = _studyResultRouter(
        RoutePaths.studyResult('session-result'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyResultScreen)),
      );

      expect(find.byType(StudyResultScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.text(l10n.studyResultCompleted), findsOneWidget);
      expect(find.text(l10n.studyResultCardsCompleted(4, 4)), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(repository.resultCalls, 1);
    },
  );

  testWidgets(
    'missing result session shows a controlled not-found state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: 'unused'),
        ),
        resultResult: const Result<StudySessionResult>.err(
          Failure.notFound(entity: 'study_session', id: 'missing-session'),
        ),
      );
      final GoRouter router = _studyResultRouter(
        RoutePaths.studyResult('missing-session'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyResultScreen)),
      );

      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text(l10n.studySessionNotFoundTitle), findsOneWidget);
      expect(find.text(l10n.studySessionNotFoundMessage), findsOneWidget);
    },
  );

  testWidgets(
    'incomplete result session shows the not-completed state instead of success',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: 'unused'),
        ),
        resultResult: Result<StudySessionResult>.ok(
          _result(
            sessionId: 'session-incomplete',
            status: SessionStatus.inProgress,
            totalCount: 4,
            answeredCount: 2,
            forgotCount: 0,
            passedCount: 2,
          ),
        ),
      );
      final GoRouter router = _studyResultRouter(
        RoutePaths.studyResult('session-incomplete'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyResultScreen)),
      );

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text(l10n.studyResultNotCompleteTitle), findsOneWidget);
      expect(find.textContaining(l10n.studyResultNotCompleteMessage), findsOneWidget);
      expect(find.text(l10n.studyResultCompleted), findsNothing);
    },
  );

  testWidgets(
    'study result CTA navigates using existing route constants',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        const Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: 'unused'),
        ),
        resultResult: Result<StudySessionResult>.ok(
          _result(
            sessionId: 'session-cta',
            status: SessionStatus.completed,
            totalCount: 1,
            answeredCount: 1,
            forgotCount: 0,
            passedCount: 1,
          ),
        ),
      );
      final GoRouter router = _studyResultRouter(
        RoutePaths.studyResult('session-cta'),
      );

      await tester.pumpWidget(
        _routerShell(
          router,
          overrides: <Override>[
            studyRepositoryProvider.overrideWithValue(repository),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyResultScreen)),
      );

      await tester.tap(find.widgetWithText(MxActionButton, l10n.studyResultBackToLibraryAction));
      await tester.pumpAndSettle();

      expect(find.text('Library destination'), findsOneWidget);
    },
  );
}
