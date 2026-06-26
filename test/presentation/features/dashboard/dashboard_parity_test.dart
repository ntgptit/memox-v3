import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_engagement.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Parity contract for the engagement dashboard, identity by STABLE KEY, driven
/// by the GENERATED contract (`tool/parity/contracts/contracts.json`).
///
/// The required `mx-node:<id>` keys come from the kit's `data-mx-node` ids via the
/// spec → `gen_contract.mjs` pipeline — no hand-coded list here. Pumped in the
/// full engagement state (a resume session + a recent deck) so every section
/// renders; if the FE drops a tagged node its key is absent →
/// `expectGeneratedParityContract` fails listing it.
final DashboardEngagement _fullEngagement = DashboardEngagement(
  cardsDue: 23,
  decksWithDue: 3,
  totalDecks: 9,
  accuracyPercent: 86,
  currentStreak: 11,
  resume: DashboardResumeSessionSummary(
    sessionId: 'sess-1',
    scope: const StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.srsReview,
    ),
    scopeName: 'Japanese · N5',
    answeredCount: 7,
    totalCount: 20,
    lastActiveAt: DateTime.utc(2026, 6, 19, 12),
  ),
  recentDecks: <DashboardRecentDeck>[
    DashboardRecentDeck(
      deckId: 'deck-1',
      name: 'Japanese · N5',
      cardCount: 142,
      dueCount: 23,
      lastStudiedAt: DateTime.utc(2026, 6, 19, 10),
    ),
  ],
);

Future<void> _pump(WidgetTester tester, DashboardEngagement data) async {
  // The dashboard body is a scrollable ListView; pump a tall phone surface so
  // every keyed section builds (off-screen slivers past the cache extent would
  // otherwise not materialize, failing the identity-by-key parity assertion).
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardEngagementProvider.overrideWith(
          (ref) async => (failure: null, data: data),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MxTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(now: DateTime.utc(2026, 6, 19, 20)),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('02-dashboard parity contract (engagement, all sections)', (
    tester,
  ) async {
    await _pump(tester, _fullEngagement);
    expectGeneratedParityContract('02-dashboard');
  });
}
