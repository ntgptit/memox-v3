import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_controller.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';

import '../../../support/golden_harness.dart';

const String _sid = 's1';
final DateTime _t = DateTime.utc(2026);

StudySessionReviewItem _item({
  String front = '먹다',
  String back = 'to eat',
  String? example,
  bool answered = false,
  int sortOrder = 0,
}) => StudySessionReviewItem(
  sessionItemId: 'i$sortOrder',
  flashcardId: 'c$sortOrder',
  front: front,
  back: back,
  exampleSentence: example,
  pronunciation: null,
  hint: null,
  sortOrder: sortOrder,
  answeredAt: answered ? _t : null,
);

StudySessionReview _review({required List<StudySessionReviewItem> items}) =>
    StudySessionReview(
      session: StudySession(
        id: _sid,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'd1',
          studyType: StudyType.newCards,
        ),
        status: SessionStatus.inProgress,
        startedAt: _t,
        updatedAt: _t,
      ),
      items: items,
    );

/// Fakes the session controller so swipe/grade/finish are deterministic without
/// touching the record use case / DB: [build] returns [_initial]; [grade] records
/// the result via [onGrade] and advances (mirroring the real advance).
class _FakeSessionController extends StudySessionController {
  _FakeSessionController(this._initial, {this.onGrade, this.onCardAction});

  final StudySessionView _initial;
  final void Function(AttemptResult result)? onGrade;
  final void Function(String action)? onCardAction;

  @override
  Future<StudySessionView> build(SessionId sessionId) async => _initial;

  @override
  Future<void> grade(AttemptResult result) async {
    onGrade?.call(result);
    final StudySessionView? v = state.asData?.value;
    if (v == null || v.isFinished) return;
    state = AsyncData<StudySessionView>(
      v.copyWith(currentIndex: v.currentIndex + 1),
    );
  }

  @override
  Future<void> buryCurrent() async => onCardAction?.call('bury');

  @override
  Future<void> suspendCurrent() async => onCardAction?.call('suspend');
}

Future<void> _pump(
  WidgetTester tester, {
  Future<StudySessionReview> Function()? review,
  StudySessionController Function()? controller,
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
      overrides: [
        if (review != null)
          studySessionReviewProvider(_sid).overrideWith((ref) => review()),
        if (controller != null)
          studySessionControllerProvider(_sid).overrideWith(controller),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StudySessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('StudySessionScreen', () {
    testWidgets('loaded: shows both sides + example + progress count', (
      tester,
    ) async {
      await _pump(
        tester,
        review: () async => _review(
          items: <StudySessionReviewItem>[
            _item(example: '아침을 먹었어요.'),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
      );
      expect(find.text('먹다'), findsOneWidget); // front
      expect(find.text('to eat'), findsOneWidget); // back
      expect(find.text('아침을 먹었어요.'), findsOneWidget); // example pill
      expect(find.text('0 / 2'), findsOneWidget); // progress count
      // mx-node parity: the shared study chrome (kit StudyShell → exit + progress).
      expect(
        find.byKey(const ValueKey<String>('mx-node:study-session/exit')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('mx-node:study-session/progress')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('mx-node:study-session/content-card'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no example → no example pill', (tester) async {
      await _pump(
        tester,
        review: () async => _review(items: <StudySessionReviewItem>[_item()]),
      );
      expect(find.text('먹다'), findsOneWidget);
      expect(find.text('아침을 먹었어요.'), findsNothing);
    });

    testWidgets('progress reflects answered items', (tester) async {
      await _pump(
        tester,
        review: () async => _review(
          items: <StudySessionReviewItem>[
            _item(answered: true),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
      );
      // One of two answered → "1 / 2"; the first unanswered card is shown.
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('water'), findsOneWidget);
    });

    testWidgets('loading shows a spinner', (tester) async {
      await _pump(tester, review: () => Completer<StudySessionReview>().future);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a load failure shows the error surface', (tester) async {
      await _pump(tester, review: () async => throw Exception('boom'));
      // The controller awaits the review provider, so the error needs the
      // chained async to settle.
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load the session"), findsOneWidget);
    });

    testWidgets('an empty session shows the empty state', (tester) async {
      await _pump(
        tester,
        review: () async => _review(items: const <StudySessionReviewItem>[]),
      );
      expect(find.text('Nothing to review'), findsOneWidget);
    });

    testWidgets('the swipe hint shows on the first card', (tester) async {
      await _pump(
        tester,
        review: () async => _review(items: <StudySessionReviewItem>[_item()]),
      );
      expect(find.textContaining('Swipe right'), findsOneWidget);
    });

    testWidgets('the swipe hint is hidden after the first few cards', (
      tester,
    ) async {
      final StudySessionView view = StudySessionView(
        review: _review(
          items: List<StudySessionReviewItem>.generate(
            5,
            (int i) => _item(sortOrder: i),
          ),
        ),
        currentIndex: 3, // past the hint window
      );
      await _pump(tester, controller: () => _FakeSessionController(view));
      expect(find.textContaining('Swipe right'), findsNothing);
    });

    testWidgets('swipe right grades perfect and advances to the next card', (
      tester,
    ) async {
      AttemptResult? graded;
      final StudySessionView view = StudySessionView(
        review: _review(
          items: <StudySessionReviewItem>[
            _item(),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
        currentIndex: 0,
      );
      await _pump(
        tester,
        controller: () =>
            _FakeSessionController(view, onGrade: (r) => graded = r),
      );
      expect(find.text('먹다'), findsOneWidget);
      await tester.drag(find.byType(Dismissible), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(graded, AttemptResult.perfect);
      expect(find.text('water'), findsOneWidget); // advanced
    });

    testWidgets('swipe left grades forgot', (tester) async {
      AttemptResult? graded;
      final StudySessionView view = StudySessionView(
        review: _review(
          items: <StudySessionReviewItem>[
            _item(),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
        currentIndex: 0,
      );
      await _pump(
        tester,
        controller: () =>
            _FakeSessionController(view, onGrade: (r) => graded = r),
      );
      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(graded, AttemptResult.forgot);
    });

    testWidgets('grading the last card shows the finish surface', (
      tester,
    ) async {
      final StudySessionView view = StudySessionView(
        review: _review(items: <StudySessionReviewItem>[_item()]),
        currentIndex: 0,
      );
      await _pump(tester, controller: () => _FakeSessionController(view));
      await tester.drag(find.byType(Dismissible), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Review complete'), findsOneWidget);
      expect(find.text('Finish session'), findsOneWidget);
    });

    testWidgets('long-press opens the card-actions sheet', (tester) async {
      final StudySessionView view = StudySessionView(
        review: _review(items: <StudySessionReviewItem>[_item()]),
        currentIndex: 0,
      );
      await _pump(tester, controller: () => _FakeSessionController(view));
      await tester.longPress(find.text('먹다'));
      await tester.pumpAndSettle();
      expect(find.text('Bury until tomorrow'), findsOneWidget);
      expect(find.text('Suspend card'), findsOneWidget);
    });

    testWidgets('card-actions Bury invokes buryCurrent', (tester) async {
      String? action;
      final StudySessionView view = StudySessionView(
        review: _review(items: <StudySessionReviewItem>[_item()]),
        currentIndex: 0,
      );
      await _pump(
        tester,
        controller: () =>
            _FakeSessionController(view, onCardAction: (a) => action = a),
      );
      await tester.longPress(find.text('먹다'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bury until tomorrow'));
      await tester.pumpAndSettle();
      expect(action, 'bury');
    });

    testWidgets('card-actions Suspend invokes suspendCurrent', (tester) async {
      String? action;
      final StudySessionView view = StudySessionView(
        review: _review(items: <StudySessionReviewItem>[_item()]),
        currentIndex: 0,
      );
      await _pump(
        tester,
        controller: () =>
            _FakeSessionController(view, onCardAction: (a) => action = a),
      );
      await tester.longPress(find.text('먹다'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suspend card'));
      await tester.pumpAndSettle();
      expect(action, 'suspend');
    });

    testWidgets('exit mid-session (answered > 0) confirms before leaving', (
      tester,
    ) async {
      // currentIndex 1 of 2 → one card answered.
      final StudySessionView view = StudySessionView(
        review: _review(
          items: <StudySessionReviewItem>[
            _item(answered: true),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
        currentIndex: 1,
      );
      await _pump(tester, controller: () => _FakeSessionController(view));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Exit study session?'), findsOneWidget);
    });

    testWidgets('exit cancel keeps the session', (tester) async {
      final StudySessionView view = StudySessionView(
        review: _review(
          items: <StudySessionReviewItem>[
            _item(answered: true),
            _item(front: '물', back: 'water', sortOrder: 1),
          ],
        ),
        currentIndex: 1,
      );
      await _pump(tester, controller: () => _FakeSessionController(view));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep studying'));
      await tester.pumpAndSettle();
      expect(find.text('Exit study session?'), findsNothing);
      expect(find.text('water'), findsOneWidget); // still on the card
    });

    testWidgets('exit with nothing answered pops without a confirm', (
      tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('HOME')),
          ),
          GoRoute(
            path: '/s',
            builder: (_, _) => const StudySessionScreen(sessionId: _sid),
          ),
        ],
      );
      final StudySessionView view = StudySessionView(
        review: _review(items: <StudySessionReviewItem>[_item()]),
        currentIndex: 0, // nothing answered
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionControllerProvider(
              _sid,
            ).overrideWith(() => _FakeSessionController(view)),
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
      // Push the session over home so the exit pop has a caller to return to.
      unawaited(router.push('/s'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Exit study session?'), findsNothing);
      expect(find.text('HOME'), findsOneWidget); // popped to caller
    });
  });

  group('StudySessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('review-card — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          review: () async => _review(
            items: <StudySessionReviewItem>[
              _item(example: '아침을 먹었어요.'),
              _item(front: '물', back: 'water', sortOrder: 1),
            ],
          ),
        );
        await expectLater(
          find.byType(StudySessionScreen),
          matchesGoldenFile(
            'goldens/study_session_review-card__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
