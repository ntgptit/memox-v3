import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/status/mx_mastery_ring.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository({
    required this.resumeSummaryResult,
    required this.reviewResult,
    required this.startResult,
  }) : cancelResult = const Result<void>.ok(null);

  FutureOr<Result<DashboardResumeSessionSummary?>> resumeSummaryResult;
  Result<StudySessionReview> reviewResult;
  Result<StudyEntryStartResult> startResult;
  Result<void> cancelResult;

  int cancelCalls = 0;
  int startCalls = 0;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = 20,
    StudyMode? mode,
  }) async {
    startCalls++;
    return startResult;
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    int dailyNewLimit = 20,
    StudyMode? mode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  }) async => reviewResult;

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
    required SessionId sessionId,
  }) async => throw UnimplementedError();

  @override
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() async => await resumeSummaryResult;

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async => const Result<StudySession?>.ok(null);

  @override
  Future<Result<void>> cancelStudySession({
    required SessionId sessionId,
  }) async {
    cancelCalls++;
    return cancelResult;
  }

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    int? durationMs,
  }) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  Future<Result<List<StudyMatchEvaluation>>> loadMatchEvaluations({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    throw UnimplementedError();
  }
}

Folder _folder(String id) => Folder(
  id: id,
  parentId: null,
  name: 'Folder $id',
  contentMode: ContentMode.decks,
  sortOrder: 0,
  createdAt: _utc,
  updatedAt: _utc,
);

FolderWithCount _folderWithCount(
  String id, {
  int deckCount = 1,
  int cardCount = 10,
  int dueCount = 0,
}) => FolderWithCount(
  folder: _folder(id),
  subfolderCount: 0,
  deckCount: deckCount,
  cardCount: cardCount,
  dueCount: dueCount,
);

LibraryOverviewReadModel _libraryModel({
  List<FolderWithCount> folders = const <FolderWithCount>[],
  int dueToday = 0,
}) => LibraryOverviewReadModel(
  folders: folders,
  dueToday: dueToday,
  totalFolderCount: folders.length,
);

DashboardResumeSessionSummary _resumeSummary({
  String sessionId = 'session-1',
  EntryType entryType = EntryType.deck,
  String? entryRefId = 'deck-1',
  String? scopeLabel = 'Korean',
  int answeredCount = 2,
  int totalCount = 5,
}) => DashboardResumeSessionSummary(
  session: StudySession(
    id: sessionId,
    entryType: entryType,
    entryRefId: entryRefId,
    studyType: StudyType.newCards,
    status: SessionStatus.inProgress,
    startedAt: _utc,
    updatedAt: _utc,
  ),
  answeredCount: answeredCount,
  totalCount: totalCount,
  scopeLabel: scopeLabel,
);

StudySessionReview _review({
  String sessionId = 'session-1',
  String flashcardId = 'card-1',
  Set<int> answeredIndices = const <int>{},
  int totalCount = 1,
  TargetLanguage targetLanguage = TargetLanguage.korean,
}) => StudySessionReview(
  session: StudySession(
    id: sessionId,
    entryType: EntryType.deck,
    entryRefId: 'deck-1',
    studyType: StudyType.newCards,
    status: SessionStatus.inProgress,
    startedAt: _utc,
    updatedAt: _utc,
  ),
  items: <StudySessionReviewItem>[
    for (int index = 0; index < totalCount; index++)
      StudySessionReviewItem(
        sessionItem: StudySessionItem(
          id: 'item-${index + 1}',
          sessionId: sessionId,
          flashcardId: index == 0 ? flashcardId : 'card-${index + 1}',
          sortOrder: index,
          answeredAt: answeredIndices.contains(index) ? _utc : null,
          createdAt: _utc,
          updatedAt: _utc,
        ),
        flashcard: Flashcard(
          id: index == 0 ? flashcardId : 'card-${index + 1}',
          deckId: 'deck-1',
          front: 'Front ${index + 1}',
          back: 'Back ${index + 1}',
          sortOrder: index,
          createdAt: _utc,
          updatedAt: _utc,
        ),
        targetLanguage: targetLanguage,
      ),
  ],
);

final DateTime _utc = DateTime.utc(2026, 1, 1);

DashboardProgressSummary _progressSummary({
  int dueTodayCount = 0,
  DashboardGoalSummary goal = const DashboardGoalSummary.unknown(),
  DashboardStreakSummary streak = const DashboardStreakSummary.unknown(),
}) => DashboardProgressSummary(
  dueTodayCount: dueTodayCount,
  goal: goal,
  streak: streak,
);

ProgressDueSummary _dueSummary({
  int totalDueCount = 0,
  List<DeckDueSummary> decks = const <DeckDueSummary>[],
}) => ProgressDueSummary(totalDueCount: totalDueCount, decks: decks);

DeckDueSummary _deckDue(String id, {int dueCount = 1}) => DeckDueSummary(
  deckId: id,
  deckName: 'Deck $id',
  parentFolderId: 'folder-$id',
  dueCount: dueCount,
);

DashboardDeckHighlights _deckHighlights({
  List<DashboardRecentDeck> recentDecks = const <DashboardRecentDeck>[],
  int newCardCount = 0,
}) => DashboardDeckHighlights(
  recentDecks: recentDecks,
  newCardCount: newCardCount,
);

DashboardRecentDeck _recentDeck(
  String id, {
  String name = 'Recent deck',
  int cardCount = 12,
  int dueCount = 0,
  DateTime? lastStudiedAt,
}) => DashboardRecentDeck(
  deckId: id,
  deckName: name,
  cardCount: cardCount,
  dueCount: dueCount,
  lastStudiedAt: lastStudiedAt,
);

Future<({ProviderContainer container, GoRouter router})> _pumpApp(
  WidgetTester tester, {
  required _FakeStudyRepository repository,
  required Stream<LibraryOverviewReadModel> libraryStream,
  DashboardProgressSummary? progressSummary,
  ProgressDueSummary? dueSummary,
  DashboardDeckHighlights? deckHighlights,
  DashboardVisualChrome visualChrome = const DashboardVisualChrome(),
  List<Override> extraOverrides = const <Override>[],
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      studyRepositoryProvider.overrideWithValue(repository),
      libraryOverviewQueryProvider.overrideWith((Ref ref) => libraryStream),
      dashboardProgressSummaryQueryProvider.overrideWithValue(
        AsyncData<DashboardProgressSummary>(
          progressSummary ?? _progressSummary(),
        ),
      ),
      dashboardDueSummaryQueryProvider.overrideWithValue(
        AsyncData<ProgressDueSummary>(dueSummary ?? _dueSummary()),
      ),
      dashboardDeckHighlightsQueryProvider.overrideWithValue(
        AsyncData<DashboardDeckHighlights>(deckHighlights ?? _deckHighlights()),
      ),
      dashboardVisualChromeProvider.overrideWithValue(visualChrome),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);

  final GoRouter router = container.read(goRouterProvider);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return (container: container, router: router);
}

void main() {
  testWidgets('boots to Library on `/`', (WidgetTester tester) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    await _pumpApp(
      tester,
      repository: repository,
      libraryStream: Stream<LibraryOverviewReadModel>.value(
        _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LibraryOverviewScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('`/home` renders Dashboard instead of RoutePlaceholder', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text(l10n.dashboardGreetingTitle), findsOneWidget);
    expect(find.byType(RoutePlaceholder), findsNothing);
  });

  testWidgets('loading renders section skeletons', (WidgetTester tester) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final Completer<LibraryOverviewReadModel> pending =
        Completer<LibraryOverviewReadModel>();
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.fromFuture(
            pending.future,
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byType(MxSkeleton), findsWidgets);
    expect(find.text(l10n.dashboardTodayReviewTitle), findsNothing);
    expect(find.byType(MxMasteryRing), findsNothing);
  });

  testWidgets('error renders retry UI', (WidgetTester tester) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.error(
            Exception('boom'),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('resume summary error renders controlled state', (
    WidgetTester tester,
  ) async {
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: _FakeStudyRepository(
            resumeSummaryResult:
                const Result<DashboardResumeSessionSummary?>.ok(null),
            reviewResult: Result<StudySessionReview>.ok(_review()),
            startResult: const Result<StudyEntryStartResult>.ok(
              StudyEntryStartResult.empty(
                emptyState: StudyEntryEmptyState(
                  variant: StudyEntryEmptyVariant.todayAllDone,
                ),
              ),
            ),
          ),
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          extraOverrides: <Override>[
            dashboardResumeSessionQueryProvider.overrideWithValue(
              const AsyncError<DashboardResumeSessionSummary?>(
                Failure.storage(
                  operation: StorageOp.read,
                  cause: 'boom',
                  table: 'study_sessions',
                ),
                StackTrace.empty,
              ),
            ),
          ],
        );
    harness.router.go(RoutePaths.home);
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.text(l10n.sharedErrorTitle), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('resume summary loading shows a dashboard-safe skeleton', (
    WidgetTester tester,
  ) async {
    final Completer<Result<DashboardResumeSessionSummary?>> pending =
        Completer<Result<DashboardResumeSessionSummary?>>();
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: pending.future,
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byType(MxSkeleton), findsWidgets);
    expect(find.text(l10n.dashboardResumeSectionTitle), findsNothing);
    expect(find.text(l10n.dashboardNoDueTitle), findsOneWidget);
  });

  testWidgets('zero-content dashboard shows onboarding only', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.dashboardOnboardingHeroTitle), findsOneWidget);
    expect(find.text(l10n.dashboardCreateFirstDeckAction), findsOneWidget);
    expect(find.text(l10n.dashboardImportDeckAction), findsOneWidget);
    expect(find.text(l10n.dashboardOnboardingLocalFirstTitle), findsOneWidget);
    // Engagement/recent surfaces are hidden on the zero-content onboarding body.
    expect(find.byType(MxMasteryRing), findsNothing);
    expect(find.text(l10n.dashboardRecentDecksTitle), findsNothing);
    // The app bar (incl. search shortcut) still renders over onboarding.
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('resume card stays hidden when no resumable session exists', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardResumeSectionTitle), findsNothing);
    expect(find.text(l10n.dashboardContinueSessionAction), findsNothing);
    expect(repository.startCalls, 0);
    expect(repository.cancelCalls, 0);
  });

  testWidgets('resume card shows continue CTA and progress', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
        _resumeSummary(),
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(
      find.text(l10n.dashboardResumeSectionTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(l10n.dashboardContinueSessionAction), findsOneWidget);
    expect(find.text(l10n.dashboardDiscardAction), findsOneWidget);
    expect(find.textContaining('2/5'), findsOneWidget);
    expect(repository.startCalls, 0);
    expect(repository.cancelCalls, 0);
  });

  testWidgets(
    'continue opens the persisted session and shows the loaded item state',
    (WidgetTester tester) async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
          _resumeSummary(answeredCount: 1, totalCount: 3),
        ),
        reviewResult: Result<StudySessionReview>.ok(
          _review(totalCount: 3, answeredIndices: <int>{0}),
        ),
        startResult: const Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.empty(
            emptyState: StudyEntryEmptyState(
              variant: StudyEntryEmptyVariant.todayAllDone,
            ),
          ),
        ),
      );
      final ({ProviderContainer container, GoRouter router}) harness =
          await _pumpApp(
            tester,
            repository: repository,
            libraryStream: Stream<LibraryOverviewReadModel>.value(
              _libraryModel(
                folders: <FolderWithCount>[_folderWithCount('root')],
              ),
            ),
          );
      harness.router.go(RoutePaths.home);
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(DashboardScreen)),
      );
      await tester.tap(
        find.widgetWithText(
          MxActionButton,
          l10n.dashboardContinueSessionAction,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.path,
        RoutePaths.studySession('session-1'),
      );
      expect(find.byType(StudySessionScreen), findsOneWidget);
      expect(find.text('Front 2'), findsOneWidget);
      expect(find.text('Front 1'), findsNothing);
      expect(find.text(l10n.studySessionProgressLabel(2, 3)), findsOneWidget);
      expect(repository.startCalls, 0);
      expect(repository.cancelCalls, 0);
    },
  );

  testWidgets('Today CTA routes to the study today entry', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          dueSummary: _dueSummary(
            totalDueCount: 3,
            decks: <DeckDueSummary>[_deckDue('a', dueCount: 3)],
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final MxActionButton todayButton = tester.widget<MxActionButton>(
      find.widgetWithText(
        MxActionButton,
        AppLocalizations.of(
          tester.element(find.byType(DashboardScreen)),
        ).dashboardStartReviewAction,
      ),
    );
    todayButton.onPressed!();
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      RoutePaths.studyTodayTemplate,
    );
  });

  testWidgets('Today CTA stays disabled when there are no due cards', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardNoDueTitle), findsOneWidget);
    expect(find.text(l10n.dashboardNoDueMessage), findsOneWidget);
    expect(
      find.widgetWithText(MxActionButton, l10n.dashboardStartReviewAction),
      findsNothing,
    );
    expect(repository.startCalls, 0);
    expect(find.byType(StudySessionScreen), findsNothing);
  });

  testWidgets('streak chip and goal ring render when engagement data exists', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          progressSummary: _progressSummary(
            streak: const DashboardStreakSummary.known(currentStreak: 11),
            goal: const DashboardGoalSummary.enabled(
              dailyGoal: 20,
              todayAttemptCount: 12,
            ),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    expect(find.byType(MxMasteryRing), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('/20'), findsOneWidget);
    // Reminders stay future/target — no notification affordance.
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
  });

  testWidgets('goal off hides streak and keeps the goal card visible', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          progressSummary: _progressSummary(
            streak: const DashboardStreakSummary.known(currentStreak: 0),
            goal: DashboardGoalSummary.disabled(
              dailyGoal: 20,
              disabledSince: _utc,
              todayAttemptCount: 0,
            ),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(
      find.text(l10n.dashboardTodayGoalLabel.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/20'), findsOneWidget);
  });

  testWidgets('streak chip is hidden when the streak is zero', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          progressSummary: _progressSummary(
            streak: const DashboardStreakSummary.known(currentStreak: 0),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.byIcon(Icons.local_fire_department), findsNothing);
    expect(find.text(l10n.sharedStreakLabel), findsNothing);
  });

  testWidgets('offline chrome renders above the dashboard content', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
        _resumeSummary(),
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          visualChrome: const DashboardVisualChrome(showOfflineBanner: true),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardOfflineTitle), findsOneWidget);
    expect(find.text(l10n.dashboardOfflineMessage), findsOneWidget);
  });

  testWidgets('streak-broken chrome renders above the dashboard content', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
        _resumeSummary(),
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          visualChrome: const DashboardVisualChrome(
            showStreakBrokenBanner: true,
            streakBrokenDays: 11,
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardStreakBrokenTitle(11)), findsOneWidget);
    expect(find.text(l10n.dashboardStreakBrokenMessage), findsOneWidget);
  });

  testWidgets('multi-resume chrome renders the paused-session chip', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
        _resumeSummary(),
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          visualChrome: const DashboardVisualChrome(pausedSessionCount: 4),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardMorePausedSessions(3)), findsOneWidget);
  });

  testWidgets('recent decks and new-learning badge render from highlights', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: const Result<DashboardResumeSessionSummary?>.ok(
        null,
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
          deckHighlights: _deckHighlights(
            newCardCount: 6,
            recentDecks: <DashboardRecentDeck>[
              _recentDeck(
                'deck-1',
                name: 'TOPIK II',
                cardCount: 142,
                dueCount: 23,
              ),
            ],
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    // MxSectionHeader renders the title in all-caps.
    expect(
      find.text(l10n.dashboardRecentDecksTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('TOPIK II'), findsOneWidget);
    expect(find.text(l10n.dashboardDeckDueBadge(23)), findsOneWidget);
    expect(find.text(l10n.dashboardStartNewLearningAction), findsOneWidget);
    expect(find.text(l10n.dashboardNewCardsBadge(6)), findsOneWidget);
  });

  testWidgets('discard confirm cancels the paused session', (
    WidgetTester tester,
  ) async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      resumeSummaryResult: Result<DashboardResumeSessionSummary?>.ok(
        _resumeSummary(),
      ),
      reviewResult: Result<StudySessionReview>.ok(_review()),
      startResult: const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final ({ProviderContainer container, GoRouter router}) harness =
        await _pumpApp(
          tester,
          repository: repository,
          libraryStream: Stream<LibraryOverviewReadModel>.value(
            _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    await tester.tap(
      find.widgetWithText(MxActionButton, l10n.dashboardDiscardAction),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.dashboardDiscardConfirmTitle), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(
          FilledButton,
          l10n.dashboardDiscardAction,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.cancelCalls, 1);
  });
}
