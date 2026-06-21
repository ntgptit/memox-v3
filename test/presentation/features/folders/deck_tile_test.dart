import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/deck_tile.dart';

import '../../../support/golden_harness.dart';

final DateTime _now = DateTime.utc(2026, 6, 21, 12);

DeckSummary _deck({DateTime? lastStudied, int due = 0}) => DeckSummary(
  deck: Deck(
    id: 'd1',
    folderId: 'f1',
    name: 'Japanese · N5',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  ),
  cardCount: 142,
  dueCount: due,
  lastStudiedAt: lastStudied,
);

Future<void> _pump(
  WidgetTester tester,
  DeckSummary summary, {
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = kGoldenSurface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DeckTile(
          summary: summary,
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
  testWidgets('shows "{n} cards · last {time} ago" when studied', (
    tester,
  ) async {
    await _pump(
      tester,
      _deck(lastStudied: _now.subtract(const Duration(hours: 2)), due: 23),
    );
    expect(find.text('142 cards · last 2h ago'), findsOneWidget);
    expect(find.text('23 due'), findsOneWidget);
  });

  testWidgets('shows only "{n} cards" when never studied', (tester) async {
    await _pump(tester, _deck());
    expect(find.text('142 cards'), findsOneWidget);
  });

  testWidgets('sub-minute gap reads "{n} cards · just now"', (tester) async {
    await _pump(
      tester,
      _deck(lastStudied: _now.subtract(const Duration(seconds: 20))),
    );
    expect(find.text('142 cards · just now'), findsOneWidget);
  });

  testWidgets('deck tile golden — studied (light)', (tester) async {
    await _pump(
      tester,
      _deck(lastStudied: _now.subtract(const Duration(days: 1)), due: 8),
    );
    await expectLater(
      find.byType(DeckTile),
      matchesGoldenFile('goldens/deck_tile_studied__light.png'),
    );
  });

  testWidgets('deck tile golden — studied (dark)', (tester) async {
    await _pump(
      tester,
      _deck(lastStudied: _now.subtract(const Duration(days: 1)), due: 8),
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(DeckTile),
      matchesGoldenFile('goldens/deck_tile_studied__dark.png'),
    );
  });
}
