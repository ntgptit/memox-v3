import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_result_provider.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';

import '../../../support/golden_harness.dart';

const String _sid = 's1';
final DateTime _t = DateTime.utc(2026);

StudySessionResultItem _item(AttemptResult? result, int sortOrder) =>
    StudySessionResultItem(
      sessionItemId: 'i$sortOrder',
      flashcardId: 'c$sortOrder',
      front: 'front$sortOrder',
      back: 'back$sortOrder',
      sortOrder: sortOrder,
      result: result,
    );

StudySessionResult _result({
  required List<StudySessionResultItem> items,
  SessionStatus status = SessionStatus.completed,
}) => StudySessionResult(
  session: StudySession(
    id: _sid,
    scope: const StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'd1',
      studyType: StudyType.srsReview,
    ),
    status: status,
    startedAt: _t,
    updatedAt: _t,
  ),
  items: items,
);

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionResult> Function() result,
  GoRouter? router,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  final ThemeData theme = brightness == Brightness.light
      ? MxTheme.light
      : MxTheme.dark;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studySessionResultProvider(_sid).overrideWith((ref) => result()),
      ],
      child: router == null
          ? MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const StudyResultScreen(sessionId: _sid),
            )
          : MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
    ),
  );
  await tester.pump();
}

void main() {
  group('StudyResultScreen', () {
    testWidgets('loaded: shows the hero + Correct/Wrong/Answered counts', (
      tester,
    ) async {
      await _pump(
        tester,
        result: () async => _result(
          items: <StudySessionResultItem>[
            _item(AttemptResult.perfect, 0),
            _item(AttemptResult.perfect, 1),
            _item(AttemptResult.forgot, 2),
          ],
        ),
      );
      expect(find.text('Nice work!'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // passed
      expect(find.text('Wrong'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // forgot
      expect(find.text('3 / 3'), findsOneWidget); // answered / total
    });

    testWidgets('save-failed: shows the banner + Retry (Done stays)', (
      tester,
    ) async {
      await _pump(
        tester,
        result: () async => _result(
          status: SessionStatus.failedToFinalize,
          items: <StudySessionResultItem>[
            _item(AttemptResult.perfect, 0),
            _item(AttemptResult.forgot, 1),
          ],
        ),
      );
      expect(find.textContaining("Couldn't save your results"), findsOneWidget);
      expect(find.text('Retry save'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget); // still leaveable
      expect(find.text('Correct'), findsOneWidget); // counts still shown
    });

    testWidgets('defensive: zero answered shows the no-answers notice', (
      tester,
    ) async {
      await _pump(
        tester,
        result: () async => _result(
          items: <StudySessionResultItem>[_item(null, 0), _item(null, 1)],
        ),
      );
      expect(find.text('No cards answered'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(
        find.text('Correct'),
        findsNothing,
      ); // no counts in the defensive state
    });

    testWidgets('loading shows a spinner', (tester) async {
      await _pump(tester, result: () => Completer<StudySessionResult>().future);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a load failure shows the error surface', (tester) async {
      await _pump(tester, result: () async => throw Exception('boom'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load your results"), findsOneWidget);
    });

    testWidgets('Done goes to the deck origin (deck scope)', (tester) async {
      final GoRouter router = GoRouter(
        initialLocation: '/r',
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (_, _) => const Scaffold(body: Text('HOME')),
          ),
          GoRoute(
            path: '/deck/:deckId',
            name: RouteNames.deckFlashcards,
            builder: (_, _) => const Scaffold(body: Text('DECK')),
          ),
          GoRoute(
            path: '/r',
            builder: (_, _) => const StudyResultScreen(sessionId: _sid),
          ),
        ],
      );
      await _pump(
        tester,
        router: router,
        result: () async => _result(
          items: <StudySessionResultItem>[_item(AttemptResult.perfect, 0)],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('DECK'), findsOneWidget); // go to deck origin, not pop
    });
  });

  group('StudyResultScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('result-loaded — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          result: () async => _result(
            items: <StudySessionResultItem>[
              _item(AttemptResult.perfect, 0),
              _item(AttemptResult.perfect, 1),
              _item(AttemptResult.forgot, 2),
            ],
          ),
        );
        await expectLater(
          find.byType(StudyResultScreen),
          matchesGoldenFile(
            'goldens/study_result_loaded__${brightness.name}.png',
          ),
        );
      });

      testWidgets('result-save-failed — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          result: () async => _result(
            status: SessionStatus.failedToFinalize,
            items: <StudySessionResultItem>[
              _item(AttemptResult.perfect, 0),
              _item(AttemptResult.perfect, 1),
              _item(AttemptResult.forgot, 2),
            ],
          ),
        );
        await expectLater(
          find.byType(StudyResultScreen),
          matchesGoldenFile(
            'goldens/study_result_save-failed__${brightness.name}.png',
          ),
        );
      });

      testWidgets('result-defensive — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          result: () async => _result(
            items: <StudySessionResultItem>[_item(null, 0), _item(null, 1)],
          ),
        );
        await expectLater(
          find.byType(StudyResultScreen),
          matchesGoldenFile(
            'goldens/study_result_defensive__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
