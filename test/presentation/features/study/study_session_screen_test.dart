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
      await tester.pump();
      expect(find.text("Couldn't load the session"), findsOneWidget);
    });

    testWidgets('an empty session shows the empty state', (tester) async {
      await _pump(
        tester,
        review: () async => _review(items: const <StudySessionReviewItem>[]),
      );
      expect(find.text('Nothing to review'), findsOneWidget);
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
