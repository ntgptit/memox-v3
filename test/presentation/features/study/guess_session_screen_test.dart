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
import 'package:memox/presentation/features/study/screens/guess_session_screen.dart';

import '../../../support/golden_harness.dart';

const String _sid = 's1';
final DateTime _t = DateTime.utc(2026);

StudySessionReviewItem _item(
  String front,
  String back,
  int i, {
  String? pronunciation,
}) => StudySessionReviewItem(
  sessionItemId: 'i$i',
  flashcardId: 'c$i',
  front: front,
  back: back,
  exampleSentence: null,
  pronunciation: pronunciation,
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
  _item('먹다', 'to eat', 0, pronunciation: 'meokda'),
  _item('물', 'water', 1),
  _item('하늘', 'sky', 2),
  _item('책', 'book', 3),
  _item('문', 'door', 4),
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
        home: const GuessSessionScreen(sessionId: _sid),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('GuessSessionScreen', () {
    testWidgets('shell: prompt + reading + option set + count', (tester) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      expect(find.text('WHAT DOES THIS MEAN?'), findsOneWidget); // overline
      expect(find.text('먹다'), findsOneWidget); // the front (prompt)
      expect(find.text('meokda'), findsOneWidget); // the reading
      expect(find.text('to eat'), findsOneWidget); // the correct option
      expect(find.text('water'), findsOneWidget); // a distractor
      expect(find.text('0 / 5'), findsOneWidget);
    });

    testWidgets('a full option set has 5 options (correct + 4 distractors)', (
      tester,
    ) async {
      await _pump(tester, review: () async => _review(_fiveCards()));
      // The 4 other cards' backs are all distractors here.
      for (final String back in <String>['water', 'sky', 'book', 'door']) {
        expect(find.text(back), findsOneWidget);
      }
      expect(find.text('A'), findsOneWidget); // lettered badges
      expect(find.text('E'), findsOneWidget);
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

  group('GuessSessionScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('guess-question — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          brightness: brightness,
          golden: true,
          review: () async => _review(_fiveCards()),
        );
        await expectLater(
          find.byType(GuessSessionScreen),
          matchesGoldenFile(
            'goldens/guess_session_question__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
