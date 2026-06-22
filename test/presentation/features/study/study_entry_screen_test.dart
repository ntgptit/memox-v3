import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_controller.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_outcome.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';

import '../../../support/golden_harness.dart';

const String _deckId = 'd1';
final DateTime _t = DateTime.utc(2026);

const StudyScope _deckScope = StudyScope(
  entryType: EntryType.deck,
  entryRefId: _deckId,
  studyType: StudyType.newCards,
);

/// Deck scope with the `?study_type=srs_review` override applied.
const StudyScope _deckReviewScope = StudyScope(
  entryType: EntryType.deck,
  entryRefId: _deckId,
  studyType: StudyType.srsReview,
);

/// Global `today` scope (no ref id, due review).
const StudyScope _todayScope = StudyScope(
  entryType: EntryType.today,
  entryRefId: null,
  studyType: StudyType.srsReview,
);

StudySession _session() => StudySession(
  id: 's1',
  scope: _deckScope,
  status: SessionStatus.inProgress,
  startedAt: _t,
  updatedAt: _t,
);

/// Overrides the gate controller so the outcome is deterministic — [build]
/// returns whatever the test supplies (or never completes / throws).
class _FakeController extends StudyEntryController {
  _FakeController(this._build, {this.onStartOver});

  final Future<StudyEntryOutcome> Function() _build;
  final VoidCallback? onStartOver;

  @override
  Future<StudyEntryOutcome> build(StudyScope scope) => _build();

  @override
  Future<void> startOver(StudySession session) async {
    onStartOver?.call();
    state = const AsyncValue<StudyEntryOutcome>.loading();
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Future<StudyEntryOutcome> Function() outcome,
  String entryType = 'deck',
  String? entryRefId = _deckId,
  String? studyTypeRaw,
  StudyScope overrideScope = _deckScope,
  Brightness brightness = Brightness.light,
  bool golden = false,
  VoidCallback? onStartOver,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studyEntryControllerProvider(overrideScope).overrideWith(
          () => _FakeController(outcome, onStartOver: onStartOver),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyEntryScreen(
          entryType: entryType,
          entryRefId: entryRefId,
          studyTypeRaw: studyTypeRaw,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('StudyEntryScreen', () {
    testWidgets('blocked scope renders the empty surface, not a session', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.deckNoCards),
      );
      // The per-reason matrix (WP-SR1b-2a) renders the deck-no-cards copy.
      expect(find.text('No cards in this deck'), findsOneWidget);
      expect(find.text('Add flashcards to start studying.'), findsOneWidget);
    });

    // Each empty reason renders its own tailored title (WP-SR1b-2a matrix). A
    // separate test per reason so each gets a fresh tree (AppAsyncBuilder keeps
    // prior data across a re-pump in one test).
    const Map<StudyScopeEmptyReason, String> reasonTitles =
        <StudyScopeEmptyReason, String>{
          StudyScopeEmptyReason.deckNoDueCards: 'All caught up!',
          StudyScopeEmptyReason.folderNoCards: 'No cards in this folder',
          StudyScopeEmptyReason.folderNoDueCards: 'All caught up!',
          StudyScopeEmptyReason.todayAllDone: 'All done for today!',
          StudyScopeEmptyReason.todayNoContent: 'No flashcards yet',
          StudyScopeEmptyReason.allBuried: 'All cards buried for today',
          StudyScopeEmptyReason.allSuspended: 'All cards are suspended',
        };
    for (final MapEntry<StudyScopeEmptyReason, String> e
        in reasonTitles.entries) {
      testWidgets('empty reason ${e.key.name} renders its title', (
        tester,
      ) async {
        await _pumpScreen(
          tester,
          outcome: () async => StudyEntryOutcome.blocked(e.key),
        );
        expect(find.text(e.value), findsOneWidget);
      });
    }

    testWidgets(
      'resumable scope offers Resume + Start over (no silent resume)',
      (tester) async {
        await _pumpScreen(
          tester,
          outcome: () async => StudyEntryOutcome.resumeRequired(_session()),
        );
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('Start over'), findsOneWidget);
      },
    );

    testWidgets('Start over confirms before invoking startOver (S87)', (
      tester,
    ) async {
      bool started = false;
      await _pumpScreen(
        tester,
        outcome: () async => StudyEntryOutcome.resumeRequired(_session()),
        onStartOver: () => started = true,
      );
      // Tapping the button opens the confirm dialog, NOT startOver directly.
      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();
      expect(find.text('Start over?'), findsOneWidget);
      expect(started, isFalse);
      // Confirm — the dialog's confirm action also reads "Start over" (the last
      // one on screen); tapping it runs startOver.
      await tester.tap(find.text('Start over').last);
      await tester.pumpAndSettle();
      expect(started, isTrue);
    });

    testWidgets('Start over can be cancelled (startOver not invoked)', (
      tester,
    ) async {
      bool started = false;
      await _pumpScreen(
        tester,
        outcome: () async => StudyEntryOutcome.resumeRequired(_session()),
        onStartOver: () => started = true,
      );
      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(started, isFalse);
    });

    testWidgets('caught-up reasons offer a Study new instead CTA', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        outcome: () async => const StudyEntryOutcome.blocked(
          StudyScopeEmptyReason.deckNoDueCards,
        ),
      );
      expect(find.text('Study new instead'), findsOneWidget);
    });

    testWidgets('all-buried offers both Study new instead and Done', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.allBuried),
      );
      expect(find.text('Study new instead'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('today-all-done offers a Done action', (tester) async {
      await _pumpScreen(
        tester,
        entryType: 'today',
        entryRefId: null,
        overrideScope: _todayScope,
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.todayAllDone),
      );
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('preparing shows a loading indicator', (tester) async {
      await _pumpScreen(
        tester,
        outcome: () => Completer<StudyEntryOutcome>().future, // never resolves
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a resolve failure shows the error surface', (tester) async {
      await _pumpScreen(tester, outcome: () async => throw Exception('boom'));
      await tester.pump();
      expect(find.text("Couldn't start study"), findsOneWidget);
    });

    testWidgets('the today route resolves a today scope', (tester) async {
      // entryType `today`, no ref id → `_todayScope`; the gate renders its
      // outcome (here blocked) rather than erroring.
      await _pumpScreen(
        tester,
        entryType: 'today',
        entryRefId: null,
        overrideScope: _todayScope,
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.todayAllDone),
      );
      expect(find.text('All done for today!'), findsOneWidget);
    });

    testWidgets('a study_type=srs_review query overrides the deck default', (
      tester,
    ) async {
      // The override changes the resolved scope to `_deckReviewScope`; pumping
      // with that scope overridden proves the screen built the review scope.
      await _pumpScreen(
        tester,
        studyTypeRaw: 'srs_review',
        overrideScope: _deckReviewScope,
        outcome: () async => const StudyEntryOutcome.blocked(
          StudyScopeEmptyReason.deckNoDueCards,
        ),
      );
      expect(find.text('All caught up!'), findsOneWidget);
    });

    testWidgets('an unrecognized study_type shows the error surface', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        studyTypeRaw: 'bogus',
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.deckNoCards),
      );
      expect(find.text("Couldn't start study"), findsOneWidget);
    });

    testWidgets('an unparseable entryType shows the error surface', (
      tester,
    ) async {
      // Scope cannot resolve → error without touching the controller.
      await _pumpScreen(
        tester,
        entryType: 'bogus',
        outcome: () async =>
            const StudyEntryOutcome.blocked(StudyScopeEmptyReason.deckNoCards),
      );
      expect(find.text("Couldn't start study"), findsOneWidget);
    });

    testWidgets('a ready session navigates to the session route', (
      tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/library/study/deck/$_deckId',
        routes: studyRoutes(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyEntryControllerProvider(_deckScope).overrideWith(
              () => _FakeController(
                () async => const StudyEntryOutcome.ready('s1'),
              ),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // The gate pushReplacement'd to the session placeholder shell.
      expect(
        find.byKey(const ValueKey<String>('study_session_placeholder')),
        findsOneWidget,
      );
      expect(find.text('s1'), findsOneWidget);
    });

    testWidgets('Study new instead re-enters the gate with study_type=new_cards', (
      tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/library/study/deck/$_deckId?study_type=srs_review',
        routes: studyRoutes(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Initial (review) scope is caught-up → shows "Study new instead".
            studyEntryControllerProvider(_deckReviewScope).overrideWith(
              () => _FakeController(
                () async => const StudyEntryOutcome.blocked(
                  StudyScopeEmptyReason.deckNoDueCards,
                ),
              ),
            ),
            // After re-entry the scope is the new-cards deck scope.
            studyEntryControllerProvider(_deckScope).overrideWith(
              () => _FakeController(
                () async => const StudyEntryOutcome.blocked(
                  StudyScopeEmptyReason.deckNoCards,
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('All caught up!'), findsOneWidget);
      // Tapping it re-enters the gate with the new-cards scope (deckNoCards copy).
      await tester.tap(find.text('Study new instead'));
      await tester.pumpAndSettle();
      expect(find.text('No cards in this deck'), findsOneWidget);
    });
  });

  group('StudyEntryScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      // Representative empty-matrix variants (different icon + copy + layout);
      // the other reasons share the same `MxEmptyState` structure.
      for (final (String name, StudyScopeEmptyReason reason) variant
          in <(String, StudyScopeEmptyReason)>[
            ('deck-no-cards', StudyScopeEmptyReason.deckNoCards),
            ('deck-no-due', StudyScopeEmptyReason.deckNoDueCards),
            ('today-all-done', StudyScopeEmptyReason.todayAllDone),
            ('all-buried', StudyScopeEmptyReason.allBuried),
            ('all-suspended', StudyScopeEmptyReason.allSuspended),
          ]) {
        testWidgets('empty ${variant.$1} — ${brightness.name}', (tester) async {
          await _pumpScreen(
            tester,
            brightness: brightness,
            golden: true,
            outcome: () async => StudyEntryOutcome.blocked(variant.$2),
          );
          await expectLater(
            find.byType(StudyEntryScreen),
            matchesGoldenFile(
              'goldens/study_entry_empty_${variant.$1}__${brightness.name}.png',
            ),
          );
        });
      }

      testWidgets('resume — ${brightness.name}', (tester) async {
        await _pumpScreen(
          tester,
          brightness: brightness,
          golden: true,
          outcome: () async => StudyEntryOutcome.resumeRequired(_session()),
        );
        await expectLater(
          find.byType(StudyEntryScreen),
          matchesGoldenFile(
            'goldens/study_entry_resume__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
