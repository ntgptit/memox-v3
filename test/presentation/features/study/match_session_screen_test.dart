import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/features/study/screens/match_session_screen.dart';

import '../../../support/golden_harness.dart';

const String _sid = 's1';
final DateTime _t = DateTime.utc(2026);

StudySessionReviewItem _item(String front, String back, int i) =>
    StudySessionReviewItem(
      sessionItemId: 'i$i',
      flashcardId: 'c$i',
      front: front,
      back: back,
      exampleSentence: null,
      pronunciation: null,
      hint: null,
      sortOrder: i,
      answeredAt: null,
    );

StudySessionReview _review(List<StudySessionReviewItem> items) =>
    StudySessionReview(
      session: StudySession(
        id: _sid,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'd1',
          studyType: StudyType.srsReview,
        ),
        status: SessionStatus.inProgress,
        startedAt: _t,
        updatedAt: _t,
      ),
      items: items,
    );

List<StudySessionReviewItem> _fiveCards() => <StudySessionReviewItem>[
  _item('공부하다', 'to study', 0),
  _item('먹다', 'to eat', 1),
  _item('하늘', 'sky', 2),
  _item('도서관', 'library', 3),
  _item('책', 'book', 4),
];

Future<void> _pump(
  WidgetTester tester, {
  required Future<StudySessionReview> Function() review,
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
        studySessionReviewProvider(_sid).overrideWith((ref) => review()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MatchSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('MatchSessionScreen', () {
    testWidgets('board shell: title + board cells + progress line + count', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      expect(find.text('Match the pairs'), findsOneWidget);
      expect(find.textContaining('Tap a term'), findsOneWidget);
      expect(find.text('공부하다'), findsOneWidget); // a front cell
      expect(find.text('to study'), findsOneWidget); // a back cell
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget); // matched / total
    });

    testWidgets('first board: 7 cards → only the first 5 cards render', (
      tester,
    ) async {
      final List<StudySessionReviewItem> items = <StudySessionReviewItem>[
        ..._fiveCards(),
        _item('의자', 'chair', 5),
        _item('문', 'door', 6),
      ];
      await _pump(tester, review: () async => _review(items));
      expect(find.textContaining('0 matched · 5 left'), findsOneWidget);
      expect(find.text('0 / 7'), findsOneWidget);
      expect(find.text('의자'), findsNothing); // card 6 is on board 2
    });

    testWidgets('loading shows a spinner', (tester) async {
      await _pump(tester, review: () => Completer<StudySessionReview>().future);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a load failure shows the error surface', (tester) async {
      await _pump(tester, review: () async => throw Exception('boom'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load the session"), findsOneWidget);
    });

    testWidgets('an empty session shows the empty state', (tester) async {
      await _pump(
        tester,
        review: () async => _review(const <StudySessionReviewItem>[]),
      );
      expect(find.text('Nothing to review'), findsOneWidget);
    });
  });

  group('MatchSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('match-board-fresh — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          review: () async => _review(_fiveCards()),
        );
        await expectLater(
          find.byType(MatchSessionScreen),
          matchesGoldenFile(
            'goldens/match_session_board-fresh__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
