import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/flashcard_progress.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_tile.dart';

import '../../../support/golden_harness.dart';

// Fixed instant so the `due in {n}d` countdown is deterministic.
final DateTime _now = DateTime.utc(2026, 1, 1, 9);

Flashcard _card() => Flashcard(
  id: 'c1',
  deckId: 'd1',
  front: '日本',
  back: 'Japan',
  sortOrder: 0,
  createdAt: _now,
  updatedAt: _now,
);

FlashcardProgress _progress({required int box, DateTime? dueAt}) =>
    FlashcardProgress(
      flashcardId: 'c1',
      currentBox: box,
      dueAt: dueAt,
      reviewCount: 1,
      lapseCount: 0,
    );

Future<void> _pumpTile(
  WidgetTester tester,
  FlashcardProgress? progress, {
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FlashcardTile(
          card: _card(),
          progress: progress,
          now: _now,
          onTap: () {},
          onActions: () {},
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('FlashcardTile SRS subtitle', () {
    testWidgets('title combines front — back', (tester) async {
      await _pumpTile(tester, null);
      expect(find.text('日本 — Japan'), findsOneWidget);
    });

    testWidgets('no progress → New · not studied', (tester) async {
      await _pumpTile(tester, null);
      expect(find.text('New · not studied'), findsOneWidget);
    });

    testWidgets('unscheduled progress (dueAt null) → New · not studied', (
      tester,
    ) async {
      await _pumpTile(tester, _progress(box: 1));
      expect(find.text('New · not studied'), findsOneWidget);
    });

    testWidgets('scheduled future → Box N · due in Xd', (tester) async {
      await _pumpTile(
        tester,
        _progress(box: 4, dueAt: _now.add(const Duration(days: 3))),
      );
      expect(find.text('Box 4 · due in 3d'), findsOneWidget);
    });

    testWidgets('due now / overdue → Box N · due today', (tester) async {
      await _pumpTile(
        tester,
        _progress(box: 6, dueAt: _now.subtract(const Duration(days: 1))),
      );
      expect(find.text('Box 6 · due today'), findsOneWidget);
    });
  });

  group('FlashcardTile goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('new — ${brightness.name}', (tester) async {
        await _pumpTile(tester, null, brightness: brightness, golden: true);
        await expectLater(
          find.byType(FlashcardTile),
          matchesGoldenFile(
            'goldens/flashcard_tile_new__${brightness.name}.png',
          ),
        );
      });

      testWidgets('due-in — ${brightness.name}', (tester) async {
        await _pumpTile(
          tester,
          _progress(box: 4, dueAt: _now.add(const Duration(days: 3))),
          brightness: brightness,
          golden: true,
        );
        await expectLater(
          find.byType(FlashcardTile),
          matchesGoldenFile(
            'goldens/flashcard_tile_due-in__${brightness.name}.png',
          ),
        );
      });

      testWidgets('due-today — ${brightness.name}', (tester) async {
        await _pumpTile(
          tester,
          _progress(box: 6, dueAt: _now.subtract(const Duration(days: 1))),
          brightness: brightness,
          golden: true,
        );
        await expectLater(
          find.byType(FlashcardTile),
          matchesGoldenFile(
            'goldens/flashcard_tile_due-today__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
