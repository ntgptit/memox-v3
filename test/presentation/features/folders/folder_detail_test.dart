import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

const String _id = 'f1';
final DateTime _t = DateTime.utc(2026);

Folder _folder(String id, String name, ContentMode mode) => Folder(
  id: id,
  parentId: null,
  name: name,
  contentMode: mode,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

DeckSummary _deck(String id, String name, {int cards = 42, int due = 0}) =>
    DeckSummary(
      deck: Deck(
        id: id,
        folderId: _id,
        name: name,
        targetLanguage: TargetLanguage.korean,
        sortOrder: 0,
        createdAt: _t,
        updatedAt: _t,
      ),
      cardCount: cards,
      dueCount: due,
    );

FolderSummary _sub(String id, String name) => FolderSummary(
  folder: _folder(id, name, ContentMode.decks),
  subfolderCount: 0,
  deckCount: 3,
  cardCount: 120,
  dueCount: 0,
);

final FolderDetail _decksMode = FolderDetail(
  folder: _folder(_id, 'Languages', ContentMode.decks),
  breadcrumb: <Folder>[_folder(_id, 'Languages', ContentMode.decks)],
  subfolders: const <FolderSummary>[],
  decks: <DeckSummary>[
    _deck('d1', 'Japanese · N5', cards: 142, due: 23),
    _deck('d2', 'Spanish verbs', cards: 96, due: 8),
    _deck('d3', 'French basics', cards: 74),
  ],
  deckCount: 3,
  subtreeDeckCount: 3,
  cardCount: 312,
  dueCount: 31,
);

final FolderDetail _subfoldersMode = FolderDetail(
  folder: _folder(_id, 'Languages', ContentMode.subfolders),
  breadcrumb: <Folder>[_folder(_id, 'Languages', ContentMode.subfolders)],
  subfolders: <FolderSummary>[_sub('s1', 'East Asian'), _sub('s2', 'Romance')],
  decks: const <DeckSummary>[],
  deckCount: 0,
  subtreeDeckCount: 5,
  cardCount: 412,
  dueCount: 31,
);

final FolderDetail _empty = FolderDetail(
  folder: _folder(_id, 'Languages', ContentMode.unlocked),
  breadcrumb: <Folder>[_folder(_id, 'Languages', ContentMode.unlocked)],
  subfolders: const <FolderSummary>[],
  decks: const <DeckSummary>[],
  deckCount: 0,
  subtreeDeckCount: 0,
  cardCount: 0,
  dueCount: 0,
);

Future<void> _pump(
  WidgetTester tester,
  Stream<FolderDetail?> stream, {
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
        folderDetailStreamProvider(_id).overrideWith((ref) => stream),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FolderDetailScreen(folderId: _id),
      ),
    ),
  );
}

Stream<FolderDetail?> _value(FolderDetail v) => Stream<FolderDetail?>.value(v);
Stream<FolderDetail?> _never() =>
    Stream<FolderDetail?>.fromFuture(Completer<FolderDetail?>().future);
Stream<FolderDetail?> _error() =>
    Stream<FolderDetail?>.error(Exception('boom'));

void main() {
  group('FolderDetailScreen states', () {
    testWidgets('decks mode lists decks + create-deck FAB', (tester) async {
      await _pump(tester, _value(_decksMode));
      await tester.pumpAndSettle();
      expect(find.text('Japanese · N5'), findsOneWidget);
      expect(find.text('Languages'), findsWidgets); // app-bar title
      expect(find.byType(MxFab), findsOneWidget);
    });

    testWidgets('subfolders mode lists subfolders', (tester) async {
      await _pump(tester, _value(_subfoldersMode));
      await tester.pumpAndSettle();
      expect(find.text('East Asian'), findsOneWidget);
      expect(find.text('Romance'), findsOneWidget);
    });

    testWidgets('empty unlocked shows both create CTAs', (tester) async {
      await _pump(tester, _value(_empty));
      await tester.pumpAndSettle();
      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text('Create deck'), findsOneWidget);
      expect(find.text('Create subfolder'), findsOneWidget);
      // No FAB in the unlocked/empty state.
      expect(find.byType(MxFab), findsNothing);
    });

    testWidgets('error renders the error state', (tester) async {
      await _pump(tester, _error());
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
    });
  });

  group('FolderDetailScreen goldens', () {
    final Map<String, Stream<FolderDetail?> Function()> cases =
        <String, Stream<FolderDetail?> Function()>{
          'decks': () => _value(_decksMode),
          'subfolders': () => _value(_subfoldersMode),
          'empty': () => _value(_empty),
          'loading': _never,
          'error': _error,
        };
    for (final MapEntry<String, Stream<FolderDetail?> Function()> c
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await _pump(tester, c.value(), brightness: brightness, golden: true);
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(FolderDetailScreen),
            matchesGoldenFile(
              'goldens/folder_detail_${c.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }

    for (final Brightness brightness in Brightness.values) {
      testWidgets('search-no-results — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          _value(_decksMode),
          brightness: brightness,
          golden: true,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FolderDetailScreen),
          matchesGoldenFile(
            'goldens/folder_detail_search-no-results__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
