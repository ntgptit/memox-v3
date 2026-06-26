import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
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
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

/// Widget-state tests for the engagement dashboard body: which sections render in
/// the loaded / caught-up / error states. Section presence is asserted by the kit
/// `mx-node` keys (the same identities the parity contract checks).

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

DashboardEngagement _loaded() => DashboardEngagement(
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

Future<void> _pump(
  WidgetTester tester,
  Result<DashboardEngagement> result,
) async {
  // Scrollable ListView body — pump a tall phone surface so every keyed section
  // (incl. the trailing shortcut) materializes for the by-key assertions.
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardEngagementProvider.overrideWith((ref) async => result),
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
  testWidgets('loaded: stat strip + resume + due + recent + shortcut render', (
    tester,
  ) async {
    await _pump(tester, (failure: null, data: _loaded()));

    expect(_node('02-dashboard/stat-summary'), findsOneWidget);
    expect(_node('02-dashboard/continue-studying'), findsOneWidget);
    expect(_node('02-dashboard/due-summary'), findsOneWidget);
    expect(_node('02-dashboard/recent-decks'), findsOneWidget);
    expect(_node('02-dashboard/shortcut-progress'), findsOneWidget);
    // The resume card renders the session scope's resolved deck name.
    expect(find.text('Japanese · N5'), findsWidgets);
  });

  testWidgets('resume with a global today scope shows the today label', (
    tester,
  ) async {
    await _pump(tester, (
      failure: null,
      data: DashboardEngagement(
        cardsDue: 23,
        decksWithDue: 3,
        totalDecks: 9,
        resume: DashboardResumeSessionSummary(
          sessionId: 'sess-today',
          scope: const StudyScope(
            entryType: EntryType.today,
            entryRefId: null,
            studyType: StudyType.srsReview,
          ),
          // No deck/folder name for the global scope → localized fallback.
          answeredCount: 4,
          totalCount: 12,
          lastActiveAt: DateTime.utc(2026, 6, 19, 12),
        ),
      ),
    ));

    expect(_node('02-dashboard/continue-studying'), findsOneWidget);
    expect(find.text("Today's review"), findsOneWidget);
  });

  testWidgets('caught-up + no session: hides resume and recent-decks', (
    tester,
  ) async {
    await _pump(tester, (
      failure: null,
      data: const DashboardEngagement(
        cardsDue: 0,
        decksWithDue: 0,
        totalDecks: 9,
        accuracyPercent: 86,
        currentStreak: 11,
      ),
    ));

    // The strip + due snapshot stay; the optional sections are gone.
    expect(_node('02-dashboard/stat-summary'), findsOneWidget);
    expect(_node('02-dashboard/due-summary'), findsOneWidget);
    expect(_node('02-dashboard/continue-studying'), findsNothing);
    expect(_node('02-dashboard/recent-decks'), findsNothing);
  });

  testWidgets('error: shows the error state with a retry action', (
    tester,
  ) async {
    await _pump(tester, (
      failure: const Failure.storage(
        operation: StorageOp.read,
        table: 'flashcard_progress',
        cause: 'boom',
      ),
      data: null,
    ));

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(_node('02-dashboard/stat-summary'), findsNothing);
  });
}
