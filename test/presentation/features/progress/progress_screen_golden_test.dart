// Golden renders of every Progress screen state for visual parity checks
// against the kit mocks (`docs/system-design/MemoX Design System/ui_kits/
// mobile/shots/19-progress--*.png`). Goldens use the test-default Ahem font,
// so they verify layout, spacing, and color — not glyph shapes.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/progress/screens/progress_screen.dart';
import 'package:riverpod/misc.dart';

class _FakeProgressRepository implements ProgressRepository {
  _FakeProgressRepository(this.onLoadOverview);

  final Future<Result<ProgressOverview>> Function(ProgressRange range)
  onLoadOverview;

  @override
  Future<Result<ProgressOverview>> loadProgressOverview({
    required DateTime now,
    required ProgressRange range,
  }) => onLoadOverview(range);

  @override
  Future<Result<DashboardDeckHighlights>> loadDashboardDeckHighlights({
    required DateTime now,
    int limit = 3,
  }) async {
    throw UnimplementedError();
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

/// Wednesday, so a week range ends mid-week like the mock.
final DateTime _today = DateTime(2026, 6, 10);

ProgressActivity _activity({
  required ProgressRange range,
  required List<({int attempts, int correct})> data,
  int previousTotalAttempts = 0,
  int previousCorrectAttempts = 0,
}) {
  final List<ProgressDayActivity> days = <ProgressDayActivity>[
    for (int i = 0; i < data.length; i++)
      ProgressDayActivity(
        day: _today.subtract(Duration(days: data.length - 1 - i)),
        attemptCount: data[i].attempts,
        correctCount: data[i].correct,
      ),
  ];
  return ProgressActivity(
    range: range,
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

/// Mirrors the week mock: 92 cards, 73% accuracy, +4% vs previous week.
ProgressActivity _weekMockActivity() => _activity(
  range: ProgressRange.week,
  data: <({int attempts, int correct})>[
    (attempts: 12, correct: 9),
    (attempts: 16, correct: 12),
    (attempts: 0, correct: 0),
    (attempts: 20, correct: 15),
    (attempts: 14, correct: 10),
    (attempts: 10, correct: 7),
    (attempts: 20, correct: 14),
  ],
  previousTotalAttempts: 80,
  previousCorrectAttempts: 55,
);

/// Mirrors the box-distribution mock: 414 cards, B1 24 … B8 ramp.
BoxDistribution _mockBoxes() => const BoxDistribution(
  boxes: <BoxDistributionItem>[
    BoxDistributionItem(boxNumber: 1, cardCount: 24),
    BoxDistributionItem(boxNumber: 2, cardCount: 38),
    BoxDistributionItem(boxNumber: 3, cardCount: 54),
    BoxDistributionItem(boxNumber: 4, cardCount: 71),
    BoxDistributionItem(boxNumber: 5, cardCount: 86),
    BoxDistributionItem(boxNumber: 6, cardCount: 62),
    BoxDistributionItem(boxNumber: 7, cardCount: 49),
    BoxDistributionItem(boxNumber: 8, cardCount: 30),
  ],
);

ProgressOverview _weekOverview() => ProgressOverview(
  activity: _weekMockActivity(),
  boxDistribution: _mockBoxes(),
  streak: const ProgressStreak(currentDays: 6, longestDays: 14),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 12,
    buriedTodayCount: 3,
  ),
);

ProgressOverview _monthOverview() => ProgressOverview(
  activity: _activity(
    range: ProgressRange.month,
    data: <({int attempts, int correct})>[
      for (int i = 0; i < 28; i++)
        i % 4 == 3
            ? (attempts: 0, correct: 0)
            : (attempts: 6 + (i * 5) % 14, correct: 4 + (i * 3) % 9),
    ],
    previousTotalAttempts: 260,
    previousCorrectAttempts: 170,
  ),
  boxDistribution: _mockBoxes(),
  streak: const ProgressStreak(currentDays: 6, longestDays: 14),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 12,
    buriedTodayCount: 3,
  ),
);

ProgressOverview _emptyOverview() => ProgressOverview(
  activity: _activity(
    range: ProgressRange.week,
    data: <({int attempts, int correct})>[
      for (int i = 0; i < 7; i++) (attempts: 0, correct: 0),
    ],
  ),
  boxDistribution: BoxDistribution(
    boxes: <BoxDistributionItem>[
      for (int box = 1; box <= 8; box++)
        BoxDistributionItem(boxNumber: box, cardCount: 0),
    ],
  ),
  streak: const ProgressStreak(currentDays: 0, longestDays: 0),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 0,
    buriedTodayCount: 0,
  ),
);

/// One study day: the chart swaps for the insufficient hint + trend banner.
ProgressOverview _insufficientOverview() => ProgressOverview(
  activity: _activity(
    range: ProgressRange.week,
    data: <({int attempts, int correct})>[
      for (int i = 0; i < 6; i++) (attempts: 0, correct: 0),
      (attempts: 11, correct: 8),
    ],
  ),
  boxDistribution: _mockBoxes(),
  streak: const ProgressStreak(currentDays: 1, longestDays: 14),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 12,
    buriedTodayCount: 3,
  ),
);

/// Populated activity while box distribution and streak stay empty.
ProgressOverview _partialOverview() => ProgressOverview(
  activity: _weekMockActivity(),
  boxDistribution: BoxDistribution(
    boxes: <BoxDistributionItem>[
      for (int box = 1; box <= 8; box++)
        BoxDistributionItem(boxNumber: box, cardCount: 0),
    ],
  ),
  streak: const ProgressStreak(currentDays: 0, longestDays: 0),
  cardStateCounts: const ProgressCardStateCounts(
    suspendedCount: 0,
    buriedTodayCount: 0,
  ),
);

Future<void> _pumpState(
  WidgetTester tester, {
  required Future<Result<ProgressOverview>> Function(ProgressRange range) load,
  required Brightness brightness,
}) async {
  tester.view.physicalSize = const Size(390, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        progressRepositoryProvider.overrideWithValue(
          _FakeProgressRepository(load),
        ),
      ],
      child: MaterialApp(
        home: const ProgressScreen(),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  final Map<String, Future<Result<ProgressOverview>> Function(ProgressRange)>
  loadedStates =
      <String, Future<Result<ProgressOverview>> Function(ProgressRange)>{
        'week': (ProgressRange range) async =>
            Result<ProgressOverview>.ok(_weekOverview()),
        'month': (ProgressRange range) async => Result<ProgressOverview>.ok(
          range == ProgressRange.month ? _monthOverview() : _weekOverview(),
        ),
        'empty': (ProgressRange range) async =>
            Result<ProgressOverview>.ok(_emptyOverview()),
        'insufficient': (ProgressRange range) async =>
            Result<ProgressOverview>.ok(_insufficientOverview()),
        'partial': (ProgressRange range) async =>
            Result<ProgressOverview>.ok(_partialOverview()),
      };

  for (final Brightness brightness in <Brightness>[
    Brightness.light,
    Brightness.dark,
  ]) {
    final String theme = brightness == Brightness.dark ? 'dark' : 'light';

    for (final MapEntry<
          String,
          Future<Result<ProgressOverview>> Function(ProgressRange)
        >
        state
        in loadedStates.entries) {
      testWidgets('golden: ${state.key} ($theme)', (WidgetTester tester) async {
        await _pumpState(tester, load: state.value, brightness: brightness);
        if (state.key == 'month') {
          final AppLocalizations l10n = AppLocalizations.of(
            tester.element(find.byType(ProgressScreen)),
          );
          await tester.tap(find.text(l10n.progressRangeMonth));
        }
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ProgressScreen),
          matchesGoldenFile('goldens/19-progress--${state.key}--$theme.png'),
        );
      });
    }

    testWidgets('golden: loading ($theme)', (WidgetTester tester) async {
      final Completer<Result<ProgressOverview>> pending =
          Completer<Result<ProgressOverview>>();
      await _pumpState(
        tester,
        load: (ProgressRange range) => pending.future,
        brightness: brightness,
      );
      await expectLater(
        find.byType(ProgressScreen),
        matchesGoldenFile('goldens/19-progress--loading--$theme.png'),
      );
      pending.complete(Result<ProgressOverview>.ok(_weekOverview()));
      await tester.pumpAndSettle();
    });

    testWidgets('golden: error ($theme)', (WidgetTester tester) async {
      await _pumpState(
        tester,
        load: (ProgressRange range) async => const Result<ProgressOverview>.err(
          Failure.storage(
            operation: StorageOp.read,
            cause: 'golden',
            table: 'study_attempts',
          ),
        ),
        brightness: brightness,
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ProgressScreen),
        matchesGoldenFile('goldens/19-progress--error--$theme.png'),
      );
    });
  }
}
