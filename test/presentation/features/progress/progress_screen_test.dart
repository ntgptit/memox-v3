import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/progress/screens/progress_screen.dart';
import 'package:memox/presentation/features/progress/widgets/progress_activity_sections.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:riverpod/misc.dart';

class _FakeProgressRepository implements ProgressRepository {
  _FakeProgressRepository(this.onLoadOverview);

  Future<Result<ProgressOverview>> Function(ProgressRange range) onLoadOverview;
  final List<ProgressRange> requestedRanges = <ProgressRange>[];

  @override
  Future<Result<ProgressOverview>> loadProgressOverview({
    required DateTime now,
    required ProgressRange range,
  }) {
    requestedRanges.add(range);
    return onLoadOverview(range);
  }

  @override
  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  }) => throw UnimplementedError();

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() =>
      throw UnimplementedError();

  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() =>
      throw UnimplementedError();

  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required DateTime now,
  }) => throw UnimplementedError();

  @override
  Future<Result<Map<DateTime, int>>> loadAttemptCountsByDay() =>
      throw UnimplementedError();
}

final DateTime _today = DateTime(2026, 6, 10);

List<ProgressDayActivity> _weekDays(List<({int attempts, int correct})> data) {
  assert(data.length == 7, 'week needs 7 day entries');
  return <ProgressDayActivity>[
    for (int i = 0; i < 7; i++)
      ProgressDayActivity(
        day: _today.subtract(Duration(days: 6 - i)),
        attemptCount: data[i].attempts,
        correctCount: data[i].correct,
      ),
  ];
}

ProgressActivity _weekActivity({
  required List<({int attempts, int correct})> data,
  int previousTotalAttempts = 0,
  int previousCorrectAttempts = 0,
}) {
  final List<ProgressDayActivity> days = _weekDays(data);
  return ProgressActivity(
    range: ProgressRange.week,
    days: days,
    totalAttempts: days.fold(
      0,
      (int sum, ProgressDayActivity day) => sum + day.attemptCount,
    ),
    correctAttempts: days.fold(
      0,
      (int sum, ProgressDayActivity day) => sum + day.correctCount,
    ),
    previousTotalAttempts: previousTotalAttempts,
    previousCorrectAttempts: previousCorrectAttempts,
    distinctStudyDayCount: days
        .where((ProgressDayActivity day) => day.attemptCount > 0)
        .length,
  );
}

BoxDistribution _boxes(List<int> counts) {
  assert(counts.length == 8, 'expects 8 box counts');
  return BoxDistribution(
    boxes: <BoxDistributionItem>[
      for (int box = 1; box <= 8; box++)
        BoxDistributionItem(boxNumber: box, cardCount: counts[box - 1]),
    ],
  );
}

ProgressOverview _overview({
  ProgressActivity? activity,
  BoxDistribution? boxDistribution,
  ProgressStreak streak = const ProgressStreak(currentDays: 3, longestDays: 5),
  ProgressCardStateCounts cardStateCounts = const ProgressCardStateCounts(
    suspendedCount: 2,
    buriedTodayCount: 1,
  ),
}) => ProgressOverview(
  activity:
      activity ??
      _weekActivity(
        data: <({int attempts, int correct})>[
          (attempts: 0, correct: 0),
          (attempts: 4, correct: 3),
          (attempts: 2, correct: 2),
          (attempts: 0, correct: 0),
          (attempts: 5, correct: 4),
          (attempts: 3, correct: 2),
          (attempts: 6, correct: 5),
        ],
        previousTotalAttempts: 10,
        previousCorrectAttempts: 6,
      ),
  boxDistribution: boxDistribution ?? _boxes(<int>[12, 8, 6, 4, 3, 2, 1, 1]),
  streak: streak,
  cardStateCounts: cardStateCounts,
);

ProgressOverview _emptyOverview(ProgressRange range) => ProgressOverview(
  activity: ProgressActivity(
    range: range,
    days: range == ProgressRange.allTime
        ? const <ProgressDayActivity>[]
        : <ProgressDayActivity>[
            for (int i = 0; i < range.dayCount; i++)
              ProgressDayActivity(
                day: _today.subtract(Duration(days: range.dayCount - 1 - i)),
                attemptCount: 0,
                correctCount: 0,
              ),
          ],
    totalAttempts: 0,
    correctAttempts: 0,
    previousTotalAttempts: 0,
    previousCorrectAttempts: 0,
    distinctStudyDayCount: 0,
  ),
  boxDistribution: _boxes(<int>[0, 0, 0, 0, 0, 0, 0, 0]),
  streak: const ProgressStreak(currentDays: 0, longestDays: 0),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 0,
    buriedTodayCount: 0,
  ),
);

Future<void> _pumpProgress(
  WidgetTester tester,
  _FakeProgressRepository repository,
) async {
  // The sections live in a lazy ListView; a tall surface keeps the streak,
  // card-states, and footer sections built so they can be asserted on.
  await tester.binding.setSurfaceSize(const Size(800, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        progressRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: const ProgressScreen(),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(ProgressScreen)));

void main() {
  testWidgets('loaded week state renders every section from the overview', (
    WidgetTester tester,
  ) async {
    final _FakeProgressRepository repository = _FakeProgressRepository(
      (ProgressRange range) async => Result<ProgressOverview>.ok(_overview()),
    );
    await _pumpProgress(tester, repository);
    await tester.pumpAndSettle();
    final AppLocalizations l10n = _l10n(tester);

    expect(repository.requestedRanges, <ProgressRange>[ProgressRange.week]);
    expect(
      find.text(StringUtils.uppercased(l10n.progressCardsStudiedTitle)),
      findsOneWidget,
    );
    expect(find.text('20'), findsOneWidget); // total attempts
    expect(find.byType(ProgressBarChart), findsOneWidget);
    expect(find.text('80%'), findsOneWidget); // 16 / 20 accuracy
    expect(find.text('+20%'), findsOneWidget); // vs previous 60%
    expect(find.text(l10n.progressVsPreviousWeek), findsOneWidget);
    expect(find.byType(ProgressSparkline), findsOneWidget);
    expect(find.text('37'), findsOneWidget); // box distribution total
    expect(find.text(l10n.progressStreakDays(3)), findsOneWidget);
    expect(find.text(l10n.progressStreakDays(5)), findsOneWidget);
    expect(find.text(l10n.progressSuspendedTitle), findsOneWidget);
    expect(find.text(l10n.progressBuriedTitle), findsOneWidget);
    expect(find.text(l10n.progressFooterWeek), findsOneWidget);
    expect(find.byType(ProgressHintBox), findsNothing);
  });

  testWidgets('month tab reloads the overview for the month range', (
    WidgetTester tester,
  ) async {
    final _FakeProgressRepository repository = _FakeProgressRepository(
      (ProgressRange range) async => Result<ProgressOverview>.ok(
        range == ProgressRange.week ? _overview() : _emptyOverview(range),
      ),
    );
    await _pumpProgress(tester, repository);
    await tester.pumpAndSettle();
    final AppLocalizations l10n = _l10n(tester);

    await tester.tap(find.text(l10n.progressRangeMonth));
    await tester.pumpAndSettle();

    expect(repository.requestedRanges, <ProgressRange>[
      ProgressRange.week,
      ProgressRange.month,
    ]);
    expect(find.text(l10n.progressFooterMonth), findsOneWidget);
    expect(find.text(l10n.progressFooterWeek), findsNothing);
  });

  testWidgets('all-time hides the chart, delta, and sparkline', (
    WidgetTester tester,
  ) async {
    final _FakeProgressRepository repository = _FakeProgressRepository(
      (ProgressRange range) async => Result<ProgressOverview>.ok(
        _overview(
          activity: const ProgressActivity(
            range: ProgressRange.allTime,
            days: <ProgressDayActivity>[],
            totalAttempts: 120,
            correctAttempts: 90,
            previousTotalAttempts: 0,
            previousCorrectAttempts: 0,
            distinctStudyDayCount: 14,
          ),
        ),
      ),
    );
    await _pumpProgress(tester, repository);
    await tester.pumpAndSettle();
    final AppLocalizations l10n = _l10n(tester);

    await tester.tap(find.text(l10n.progressRangeAllTime));
    await tester.pumpAndSettle();

    expect(find.text('120'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.byType(ProgressBarChart), findsNothing);
    expect(find.byType(ProgressSparkline), findsNothing);
    expect(find.text(l10n.progressVsPreviousWeek), findsNothing);
    expect(find.text(l10n.progressVsPreviousMonth), findsNothing);
    expect(find.text(l10n.progressFooterAllTime), findsOneWidget);
  });

  testWidgets('loading keeps the tabs visible over skeleton cards', (
    WidgetTester tester,
  ) async {
    final Completer<Result<ProgressOverview>> pending =
        Completer<Result<ProgressOverview>>();
    final _FakeProgressRepository repository = _FakeProgressRepository(
      (ProgressRange range) => pending.future,
    );
    await _pumpProgress(tester, repository);
    final AppLocalizations l10n = _l10n(tester);

    expect(find.byType(MxSkeleton), findsWidgets);
    expect(find.text(l10n.progressRangeWeek), findsOneWidget);
    expect(find.byType(ProgressBarChart), findsNothing);

    pending.complete(Result<ProgressOverview>.ok(_overview()));
    await tester.pumpAndSettle();
    expect(find.byType(MxSkeleton), findsNothing);
  });

  testWidgets('empty overview shows a hint box per section', (
    WidgetTester tester,
  ) async {
    final _FakeProgressRepository repository = _FakeProgressRepository(
      (ProgressRange range) async =>
          Result<ProgressOverview>.ok(_emptyOverview(range)),
    );
    await _pumpProgress(tester, repository);
    await tester.pumpAndSettle();
    final AppLocalizations l10n = _l10n(tester);

    expect(find.text(l10n.progressChartEmptyHint), findsOneWidget);
    expect(find.text(l10n.progressAccuracyEmptyHint), findsOneWidget);
    expect(find.text(l10n.progressBoxEmptyHint), findsOneWidget);
    expect(find.text(l10n.progressStreakEmptyHint), findsOneWidget);
    expect(find.byType(ProgressBarChart), findsNothing);
    expect(find.text('0'), findsNWidgets(2)); // suspended + buried counts
  });

  testWidgets(
    'insufficient data swaps the chart for a hint and the trend banner',
    (WidgetTester tester) async {
      final _FakeProgressRepository repository = _FakeProgressRepository(
        (ProgressRange range) async => Result<ProgressOverview>.ok(
          _overview(
            activity: _weekActivity(
              data: <({int attempts, int correct})>[
                (attempts: 0, correct: 0),
                (attempts: 0, correct: 0),
                (attempts: 0, correct: 0),
                (attempts: 0, correct: 0),
                (attempts: 0, correct: 0),
                (attempts: 0, correct: 0),
                (attempts: 4, correct: 3),
              ],
            ),
          ),
        ),
      );
      await _pumpProgress(tester, repository);
      await tester.pumpAndSettle();
      final AppLocalizations l10n = _l10n(tester);

      expect(find.text(l10n.progressChartInsufficientHint(1)), findsOneWidget);
      expect(
        find.text(l10n.progressTrendBanner(kProgressTrendMinDays)),
        findsOneWidget,
      );
      expect(find.byType(ProgressBarChart), findsNothing);
      // Accuracy still renders fully from the single study day.
      expect(find.text('75%'), findsOneWidget);
    },
  );

  testWidgets(
    'partial overview keeps populated sections while empty ones show hints',
    (WidgetTester tester) async {
      final _FakeProgressRepository repository = _FakeProgressRepository(
        (ProgressRange range) async => Result<ProgressOverview>.ok(
          _overview(
            boxDistribution: _boxes(<int>[0, 0, 0, 0, 0, 0, 0, 0]),
            streak: const ProgressStreak(currentDays: 0, longestDays: 0),
          ),
        ),
      );
      await _pumpProgress(tester, repository);
      await tester.pumpAndSettle();
      final AppLocalizations l10n = _l10n(tester);

      expect(find.byType(ProgressBarChart), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text(l10n.progressBoxEmptyHint), findsOneWidget);
      expect(find.text(l10n.progressStreakEmptyHint), findsOneWidget);
      expect(find.text(l10n.progressChartEmptyHint), findsNothing);
    },
  );

  testWidgets('error state offers retry and recovers on success', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    final _FakeProgressRepository repository = _FakeProgressRepository((
      ProgressRange range,
    ) async {
      calls += 1;
      if (calls == 1) {
        return const Result<ProgressOverview>.err(
          Failure.storage(
            operation: StorageOp.read,
            cause: 'boom',
            table: 'study_attempts',
          ),
        );
      }
      return Result<ProgressOverview>.ok(_overview());
    });
    await _pumpProgress(tester, repository);
    await tester.pumpAndSettle();
    final AppLocalizations l10n = _l10n(tester);

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.text(l10n.progressErrorTitle), findsOneWidget);
    expect(find.text(l10n.progressErrorMessage), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(MxErrorState), findsNothing);
    expect(find.byType(ProgressBarChart), findsOneWidget);
  });

  testWidgets(
    'the /progress route renders ProgressScreen, not the placeholder',
    (WidgetTester tester) async {
      final _FakeProgressRepository repository = _FakeProgressRepository(
        (ProgressRange range) async => Result<ProgressOverview>.ok(_overview()),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          progressRepositoryProvider.overrideWithValue(repository),
          libraryOverviewQueryProvider.overrideWith(
            (Ref ref) => Stream<LibraryOverviewReadModel>.value(
              LibraryOverviewReadModel(
                folders: <FolderWithCount>[
                  FolderWithCount(
                    folder: Folder(
                      id: 'folder-1',
                      parentId: null,
                      name: 'Folder',
                      contentMode: ContentMode.decks,
                      sortOrder: 0,
                      createdAt: DateTime.utc(2026, 1, 1),
                      updatedAt: DateTime.utc(2026, 1, 1),
                    ),
                    subfolderCount: 0,
                    deckCount: 1,
                    cardCount: 10,
                    dueCount: 0,
                  ),
                ],
                dueToday: 0,
                totalFolderCount: 1,
              ),
            ),
          ),
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

      router.go(RoutePaths.progress);
      await tester.pumpAndSettle();

      expect(find.byType(ProgressScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      // "Progress" appears in both the app bar and the bottom-nav label.
      final AppLocalizations l10n = _l10n(tester);
      expect(find.text(l10n.progressTitle), findsWidgets);
    },
  );
}
