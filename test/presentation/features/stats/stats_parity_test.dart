import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/week_activity.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/stats/screens/stats_screen.dart';
import 'package:memox/presentation/features/stats/viewmodels/stats_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for the Stats screen (18), identity by STABLE
/// KEY. The required keys mirror the `data-mx-node` ids in
/// `tool/parity/contracts/contracts.json` → if the FE drops one, its key is
/// absent and this fails listing it.
Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

StatsOverview _sample() => StatsOverview(
  weekActivity: WeekActivity(
    days: <DayActivity>[
      for (int i = 0; i < 7; i++)
        DayActivity(date: DateTime(2026, 6, 22 + i), weekday: i + 1, count: 10),
    ],
  ),
  deckMastery: const <DeckMastery>[
    DeckMastery(deckId: 'd1', deckName: 'Japanese · N5', masteryFraction: 0.72),
  ],
);

void main() {
  testWidgets('18-stats parity contract (default)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsOverviewProvider.overrideWith(
            (ref) => (failure: null, data: _sample()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StatsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expectParityContract('18-stats', <String, Finder>{
      'cards-this-week card': _node('18-stats/week-card'),
      'weekly activity chart': _node('18-stats/week-chart'),
      'per-deck mastery section header': _node('18-stats/mastery-section'),
      'per-deck mastery list card': _node('18-stats/mastery-list'),
    });
  });
}
