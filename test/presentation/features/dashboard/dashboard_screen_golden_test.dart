// Golden renders of the Dashboard screen states for visual parity against the
// kit mock (`docs/system-design/MemoX Design System/ui_kits/mobile/shots/
// 02-dashboard--*.png`). Goldens use the test-default Ahem font, so they
// verify layout, spacing, and color - not glyph shapes.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_paths.dart';
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
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
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

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = 20,
    StudyMode? mode,
  }) async => startResult;

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
  }) async => cancelResult;

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
    StudyFlow? studyFlow,
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
    studyFlow: StudyFlow.newFullCycle,
    currentMode: StudyMode.review,
    startedAt: _utc,
    updatedAt: _utc,
  ),
  answeredCount: answeredCount,
  totalCount: totalCount,
  scopeLabel: scopeLabel,
);

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

final DateTime _utc = DateTime.utc(2026, 1, 1);

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
  tester.view.physicalSize = const Size(390, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

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
  final Map<String, FutureOr<Result<DashboardResumeSessionSummary?>> Function()>
  states =
      <String, FutureOr<Result<DashboardResumeSessionSummary?>> Function()>{
        'loaded': () =>
            Result<DashboardResumeSessionSummary?>.ok(_resumeSummary()),
        'onboarding': () =>
            const Result<DashboardResumeSessionSummary?>.ok(null),
        'goal-off': () => const Result<DashboardResumeSessionSummary?>.ok(null),
        'resume-only': () => Result<DashboardResumeSessionSummary?>.ok(
          _resumeSummary(answeredCount: 1, totalCount: 3),
        ),
        'offline': () =>
            Result<DashboardResumeSessionSummary?>.ok(_resumeSummary()),
        'streak-broken': () =>
            Result<DashboardResumeSessionSummary?>.ok(_resumeSummary()),
        'multi-resume': () =>
            Result<DashboardResumeSessionSummary?>.ok(_resumeSummary()),
      };

  for (final Brightness brightness in <Brightness>[
    Brightness.light,
    Brightness.dark,
  ]) {
    final String theme = brightness == Brightness.dark ? 'dark' : 'light';

    for (final MapEntry<
          String,
          FutureOr<Result<DashboardResumeSessionSummary?>> Function()
        >
        state
        in states.entries) {
      testWidgets('golden: ${state.key} ($theme)', (WidgetTester tester) async {
        final _FakeStudyRepository repository = _FakeStudyRepository(
          resumeSummaryResult: state.value(),
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
              libraryStream: state.key == 'onboarding'
                  ? Stream<LibraryOverviewReadModel>.value(_libraryModel())
                  : Stream<LibraryOverviewReadModel>.value(
                      _libraryModel(
                        folders: <FolderWithCount>[_folderWithCount('root')],
                      ),
                    ),
              progressSummary: switch (state.key) {
                'goal-off' => _progressSummary(
                  streak: const DashboardStreakSummary.known(currentStreak: 0),
                  goal: DashboardGoalSummary.disabled(
                    dailyGoal: 20,
                    disabledSince: _utc,
                    todayAttemptCount: 0,
                  ),
                ),
                'resume-only' => _progressSummary(
                  streak: const DashboardStreakSummary.known(currentStreak: 8),
                ),
                _ => _progressSummary(
                  dueTodayCount: 18,
                  streak: const DashboardStreakSummary.known(currentStreak: 11),
                  goal: const DashboardGoalSummary.enabled(
                    dailyGoal: 20,
                    todayAttemptCount: 12,
                  ),
                ),
              },
              dueSummary: switch (state.key) {
                'resume-only' => _dueSummary(),
                'goal-off' => _dueSummary(
                  totalDueCount: 0,
                  decks: <DeckDueSummary>[],
                ),
                _ => _dueSummary(
                  totalDueCount: 18,
                  decks: <DeckDueSummary>[
                    _deckDue('a', dueCount: 9),
                    _deckDue('b', dueCount: 6),
                    _deckDue('c', dueCount: 3),
                  ],
                ),
              },
              deckHighlights: _deckHighlights(
                newCardCount: 6,
                recentDecks: <DashboardRecentDeck>[
                  _recentDeck(
                    'deck-1',
                    name: 'TOPIK II',
                    cardCount: 142,
                    dueCount: 23,
                    lastStudiedAt: _utc.subtract(const Duration(hours: 2)),
                  ),
                  _recentDeck(
                    'deck-2',
                    name: 'Korean Honorifics',
                    cardCount: 68,
                    dueCount: 0,
                    lastStudiedAt: _utc.subtract(const Duration(days: 1)),
                  ),
                  _recentDeck(
                    'deck-3',
                    name: 'English Idioms',
                    cardCount: 33,
                    dueCount: 11,
                    lastStudiedAt: _utc.subtract(const Duration(days: 3)),
                  ),
                ],
              ),
              visualChrome: switch (state.key) {
                'offline' => const DashboardVisualChrome(
                  showOfflineBanner: true,
                ),
                'streak-broken' => const DashboardVisualChrome(
                  showStreakBrokenBanner: true,
                  streakBrokenDays: 11,
                ),
                'multi-resume' => const DashboardVisualChrome(
                  pausedSessionCount: 4,
                ),
                _ => const DashboardVisualChrome(),
              },
            );
        harness.router.go(RoutePaths.home);
        await tester.pumpAndSettle();

        if (state.key == 'onboarding') {
          expect(find.text('Welcome to MemoX'), findsOneWidget);
        }
        await expectLater(
          find.byType(DashboardScreen),
          matchesGoldenFile('goldens/02-dashboard--${state.key}--$theme.png'),
        );
      });
    }

    testWidgets('golden: loading ($theme)', (WidgetTester tester) async {
      final Completer<LibraryOverviewReadModel> pending =
          Completer<LibraryOverviewReadModel>();
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
            libraryStream: Stream<LibraryOverviewReadModel>.fromFuture(
              pending.future,
            ),
          );
      harness.router.go(RoutePaths.home);
      await tester.pump();
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/02-dashboard--loading--$theme.png'),
      );
      pending.complete(
        _libraryModel(folders: <FolderWithCount>[_folderWithCount('root')]),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('golden: error ($theme)', (WidgetTester tester) async {
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
              Exception('golden'),
            ),
          );
      harness.router.go(RoutePaths.home);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/02-dashboard--error--$theme.png'),
      );
    });
  }
}

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
    studyFlow: StudyFlow.newFullCycle,
    currentMode: StudyMode.review,
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
