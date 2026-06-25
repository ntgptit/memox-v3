import 'dart:async';

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

import '../../../support/golden_harness.dart';

/// Fixed clock so the greeting + relative "last studied" labels are deterministic
/// across golden runs.
final DateTime _now = DateTime.utc(2026, 6, 19, 20);

Result<DashboardEngagement> _ok(DashboardEngagement d) =>
    (failure: null, data: d);

Result<DashboardEngagement> _fail() => (
  failure: const Failure.storage(
    operation: StorageOp.read,
    table: 'flashcard_progress',
    cause: 'boom',
  ),
  data: null,
);

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
    answeredCount: 7,
    totalCount: 20,
    lastActiveAt: DateTime.utc(2026, 6, 19, 18),
  ),
  recentDecks: <DashboardRecentDeck>[
    DashboardRecentDeck(
      deckId: 'deck-1',
      name: 'Japanese · N5',
      cardCount: 142,
      dueCount: 23,
      lastStudiedAt: DateTime.utc(2026, 6, 19, 18),
    ),
    DashboardRecentDeck(
      deckId: 'deck-2',
      name: 'Organic chemistry',
      cardCount: 120,
      dueCount: 8,
      lastStudiedAt: DateTime.utc(2026, 6, 18, 20),
    ),
  ],
);

Future<Result<DashboardEngagement>> _never() =>
    Completer<Result<DashboardEngagement>>().future;

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<Result<DashboardEngagement>> Function() data,
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
      overrides: [dashboardEngagementProvider.overrideWith((ref) => data())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DashboardScreen(now: _now),
      ),
    ),
  );
}

void main() {
  group('DashboardScreen goldens', () {
    final Map<String, FutureOr<Result<DashboardEngagement>> Function()> cases =
        <String, FutureOr<Result<DashboardEngagement>> Function()>{
          'loaded': () => _ok(_loaded()),
          'caught-up': () => _ok(
            const DashboardEngagement(
              cardsDue: 0,
              decksWithDue: 0,
              totalDecks: 9,
              accuracyPercent: 86,
              currentStreak: 11,
            ),
          ),
          'loading': _never,
          'error': _fail,
        };
    for (final entry in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            data: entry.value,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(DashboardScreen),
            matchesGoldenFile(
              'goldens/dashboard_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
