import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/week_activity.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/stats/screens/stats_screen.dart';
import 'package:memox/presentation/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:memox/presentation/features/stats/widgets/deck_mastery_row.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_bar_chart.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

import '../../../support/golden_harness.dart';

const List<int> _weekCounts = <int>[18, 24, 12, 31, 22, 9, 16];

WeekActivity _week(List<int> counts) => WeekActivity(
  days: <DayActivity>[
    for (int i = 0; i < counts.length; i++)
      DayActivity(
        date: DateTime(2026, 6, 22 + i),
        weekday: i + 1,
        count: counts[i],
      ),
  ],
);

StatsOverview _loaded() => StatsOverview(
  weekActivity: _week(_weekCounts),
  deckMastery: const <DeckMastery>[
    DeckMastery(deckId: 'd1', deckName: 'Japanese · N5', masteryFraction: 0.72),
    DeckMastery(
      deckId: 'd2',
      deckName: 'Organic chemistry',
      masteryFraction: 0.38,
    ),
    DeckMastery(
      deckId: 'd3',
      deckName: 'World capitals',
      masteryFraction: 0.91,
    ),
    DeckMastery(
      deckId: 'd4',
      deckName: 'SAT vocabulary',
      masteryFraction: 0.56,
    ),
  ],
);

StatsOverview _emptyDecks() => StatsOverview(
  weekActivity: _week(_weekCounts),
  deckMastery: const <DeckMastery>[],
);

Result<StatsOverview> _ok(StatsOverview o) => (failure: null, data: o);
Result<StatsOverview> _fail() => (
  failure: const Failure.storage(
    operation: StorageOp.read,
    table: 'study_attempts',
    cause: 'boom',
  ),
  data: null,
);
Future<Result<StatsOverview>> _never() =>
    Completer<Result<StatsOverview>>().future;

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<Result<StatsOverview>> Function() overview,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [statsOverviewProvider.overrideWith((ref) => overview())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    ),
  );
}

void main() {
  group('StatsScreen states', () {
    testWidgets('loaded shows the week chart, total, and deck rows', (
      tester,
    ) async {
      await _pump(tester, overview: () => _ok(_loaded()));
      await tester.pumpAndSettle();

      expect(find.byType(MxBarChart), findsOneWidget);
      expect(find.text('132'), findsOneWidget); // weekly total
      expect(find.byType(DeckMasteryRow), findsNWidgets(4));
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('Japanese · N5'), findsOneWidget);
    });

    testWidgets('no decks shows the empty hint but keeps the chart', (
      tester,
    ) async {
      await _pump(tester, overview: () => _ok(_emptyDecks()));
      await tester.pumpAndSettle();

      expect(find.byType(MxBarChart), findsOneWidget);
      expect(find.byType(DeckMasteryRow), findsNothing);
      expect(find.text('No decks to show yet'), findsOneWidget);
    });

    testWidgets('loading shows the loading state', (tester) async {
      await _pump(tester, overview: _never);
      await tester.pump();
      expect(find.byType(MxLoadingState), findsOneWidget);
    });

    testWidgets('failure shows the error state with retry', (tester) async {
      await _pump(tester, overview: _fail);
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('StatsScreen goldens', () {
    final Map<String, FutureOr<Result<StatsOverview>> Function()> cases =
        <String, FutureOr<Result<StatsOverview>> Function()>{
          'default': () => _ok(_loaded()),
        };
    for (final MapEntry<String, FutureOr<Result<StatsOverview>> Function()>
        entry
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            overview: entry.value,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(StatsScreen),
            matchesGoldenFile(
              'goldens/stats_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
