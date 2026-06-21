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
        studyEntryControllerProvider(_deckScope).overrideWith(
          () => _FakeController(outcome, onStartOver: onStartOver),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyEntryScreen(entryType: entryType, entryRefId: entryRefId),
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
      expect(find.text('Nothing to study right now'), findsOneWidget);
    });

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

    testWidgets('tapping Start over invokes the controller startOver', (
      tester,
    ) async {
      bool started = false;
      await _pumpScreen(
        tester,
        outcome: () async => StudyEntryOutcome.resumeRequired(_session()),
        onStartOver: () => started = true,
      );
      await tester.tap(find.text('Start over'));
      await tester.pump();
      expect(started, isTrue);
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
  });

  group('StudyEntryScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('blocked — ${brightness.name}', (tester) async {
        await _pumpScreen(
          tester,
          brightness: brightness,
          golden: true,
          outcome: () async => const StudyEntryOutcome.blocked(
            StudyScopeEmptyReason.deckNoCards,
          ),
        );
        await expectLater(
          find.byType(StudyEntryScreen),
          matchesGoldenFile(
            'goldens/study_entry_blocked__${brightness.name}.png',
          ),
        );
      });

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
