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
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
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
    StudyMode? mode,
  }) async {
    startCalls++;
    return startResult;
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
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
      ),
  ],
);

final DateTime _utc = DateTime.utc(2026, 1, 1);

Future<({ProviderContainer container, GoRouter router})> _pumpApp(
  WidgetTester tester, {
  required _FakeStudyRepository repository,
  required Stream<LibraryOverviewReadModel> libraryStream,
  List<Override> extraOverrides = const <Override>[],
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      studyRepositoryProvider.overrideWithValue(repository),
      libraryOverviewQueryProvider.overrideWith((Ref ref) => libraryStream),
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

    expect(find.text(l10n.dashboardNewStudyTitle), findsOneWidget);
    expect(find.text(l10n.dashboardOpenLibraryAction), findsOneWidget);
    expect(find.text(l10n.dashboardStartNewLearningAction), findsNothing);
    expect(find.byType(MxMasteryRing), findsNothing);
    expect(find.byIcon(Icons.search_rounded), findsNothing);
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

    expect(find.text(l10n.dashboardResumeSectionTitle), findsOneWidget);
    expect(find.text(l10n.dashboardContinueSessionAction), findsOneWidget);
    expect(
      find.textContaining(l10n.studySessionProgressLabel(2, 5)),
      findsOneWidget,
    );
    expect(find.text(l10n.dashboardDiscardAction), findsNothing);
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
            _libraryModel(
              folders: <FolderWithCount>[_folderWithCount('root')],
              dueToday: 3,
            ),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final MxActionButton todayButton = tester.widget<MxActionButton>(
      find.widgetWithText(
        MxActionButton,
        AppLocalizations.of(
          tester.element(find.byType(DashboardScreen)),
        ).dashboardStudyTodayAction,
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
            _libraryModel(
              folders: <FolderWithCount>[_folderWithCount('root')],
              dueToday: 0,
            ),
          ),
        );
    harness.router.go(RoutePaths.home);
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(DashboardScreen)),
    );

    expect(find.text(l10n.dashboardNoDueTitle), findsOneWidget);
    expect(find.text(l10n.dashboardNoDueMessage), findsOneWidget);

    final MxActionButton todayButton = tester.widget<MxActionButton>(
      find.widgetWithText(MxActionButton, l10n.dashboardStudyTodayAction),
    );
    expect(todayButton.onPressed, isNull);

    await tester.tap(
      find.widgetWithText(MxActionButton, l10n.dashboardStudyTodayAction),
    );
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      RoutePaths.home,
    );
    expect(repository.startCalls, 0);
    expect(find.byType(StudySessionScreen), findsNothing);
  });

  testWidgets('future engagement controls are not exposed', (
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

    expect(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(DashboardScreen)),
        ).dashboardStartNewLearningAction,
      ),
      findsNothing,
    );
    expect(find.byIcon(Icons.search_rounded), findsNothing);
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    expect(find.byType(MxMasteryRing), findsNothing);
  });
}
