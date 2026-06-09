import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
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
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/study/mx_flashcard.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.reviewResult);

  Result<StudySessionReview> reviewResult;
  int reviewCalls = 0;
  int startCalls = 0;
  int findResumableCalls = 0;
  int latestSummaryCalls = 0;
  int cancelCalls = 0;
  int createCalls = 0;

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
    routes: studyRoutes(rootNavigatorKey),
  );
}

String _studySessionLocation(String sessionId) =>
    RoutePaths.studySession(sessionId);

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
  final StudySessionItem sessionItem = StudySessionItem(
    id: 'item-$sessionId',
    sessionId: sessionId,
    flashcardId: 'card-$sessionId',
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
  return StudySessionReview(
    session: session,
    items: <StudySessionReviewItem>[
      for (int index = 0; index < cards.length; index++)
        StudySessionReviewItem(
          sessionItem: sessionItem.copyWith(
            id: 'item-$sessionId-$index',
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
        ),
    ],
  );
}

void main() {
  testWidgets(
    'navigates between cards and resets reveal state',
    (tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySessionReview>.ok(
          _review(
            sessionId: 'session-1',
            cards: <({String front, String back})>[
              (front: 'Front 1', back: 'Back 1'),
              (front: 'Front 2', back: 'Back 2'),
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
      expect(find.text(l10n.studySessionTitle), findsOneWidget);
      expect(find.text(l10n.studySessionProgressLabel(1, 2)), findsOneWidget);
      expect(find.text('Front 1'), findsOneWidget);
      expect(find.text('Back 1'), findsNothing);
      expect(find.text('Front 2'), findsNothing);
      expect(find.text('Back 2'), findsNothing);
      expect(showAnswerFinder, findsOneWidget);
      expect(
        tester.widget<MxActionButton>(previousFinder).onPressed,
        isNull,
      );
      expect(tester.widget<MxActionButton>(nextFinder).onPressed, isNotNull);
      expect(repository.reviewCalls, 1);
      expect(repository.startCalls, 0);
      expect(repository.findResumableCalls, 0);
      expect(repository.latestSummaryCalls, 0);
      expect(repository.cancelCalls, 0);
      expect(repository.createCalls, 0);

      await tester.tap(showAnswerFinder);
      await tester.pumpAndSettle();

      expect(find.text('Front 1'), findsNothing);
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
  });
}
