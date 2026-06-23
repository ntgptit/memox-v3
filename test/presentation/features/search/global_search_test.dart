import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';
import 'package:memox/presentation/features/search/viewmodels/global_search_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_dock.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

import '../../../support/golden_harness.dart';
import '../../../support/structural_dump.dart';

final DateTime _t = DateTime.utc(2026);

final SearchResults _results = SearchResults(
  folders: <Folder>[
    Folder(
      id: 'f1',
      parentId: null,
      name: 'Languages',
      contentMode: ContentMode.decks,
      sortOrder: 0,
      createdAt: _t,
      updatedAt: _t,
    ),
  ],
  decks: <Deck>[
    Deck(
      id: 'd1',
      folderId: 'f1',
      name: 'Japanese · N5',
      targetLanguage: TargetLanguage.korean,
      sortOrder: 0,
      createdAt: _t,
      updatedAt: _t,
    ),
  ],
  flashcards: <Flashcard>[
    Flashcard(
      id: 'c1',
      deckId: 'd1',
      front: '日本 — Japan',
      back: 'Japan',
      sortOrder: 0,
      createdAt: _t,
      updatedAt: _t,
    ),
  ],
  folderTotal: 1,
  deckTotal: 3,
  flashcardTotal: 1,
);

Result<SearchResults> _ok(SearchResults r) => (failure: null, data: r);
Result<SearchResults> _fail() =>
    (failure: const Failure.conflict(message: 'boom'), data: null);

/// Seeds the query notifier (so the no-results message can echo it).
class _SeededQuery extends GlobalSearchQuery {
  _SeededQuery(this._seed);
  final String _seed;
  @override
  String build() => _seed;
}

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<Result<SearchResults>?> Function() result,
  String query = '',
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
        globalSearchQueryProvider.overrideWith(() => _SeededQuery(query)),
        globalSearchResultsProvider.overrideWith((ref) => result()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const GlobalSearchScreen(),
      ),
    ),
  );
}

Future<Result<SearchResults>?> _never() =>
    Completer<Result<SearchResults>?>().future;

void main() {
  group('GlobalSearchScreen states', () {
    testWidgets('idle prompt + the search dock', (tester) async {
      await _pump(tester, result: () => null);
      await tester.pumpAndSettle();
      expect(find.byType(MxSearchDock), findsOneWidget);
      expect(find.byType(MxEmptyState), findsOneWidget);
    });

    testWidgets('results render grouped sections', (tester) async {
      await _pump(tester, result: () => _ok(_results), query: 'japan');
      await tester.pumpAndSettle();
      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('Japanese · N5'), findsOneWidget);
      expect(find.text('日本 — Japan'), findsOneWidget);
      // Decks section has 3 total but 1 shown → "+2 more".
      expect(find.text('+2 more'), findsOneWidget);
    });

    testWidgets('no results shows the no-match state', (tester) async {
      await _pump(
        tester,
        result: () => _ok(const SearchResults()),
        query: 'zxqv',
      );
      await tester.pumpAndSettle();
      expect(find.byType(MxNoResultsState), findsOneWidget);
    });

    testWidgets('failure shows the error state', (tester) async {
      await _pump(tester, result: _fail);
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
    });
  });

  group('GlobalSearchScreen goldens', () {
    final Map<
      String,
      ({FutureOr<Result<SearchResults>?> Function() result, String query})
    >
    cases =
        <
          String,
          ({FutureOr<Result<SearchResults>?> Function() result, String query})
        >{
          'results': (result: () => _ok(_results), query: 'japan'),
          'empty': (result: () => null, query: ''),
          'loading': (result: _never, query: 'japan'),
          'no-results': (
            result: () => _ok(const SearchResults()),
            query: 'zxqv',
          ),
          'error': (result: _fail, query: 'japan'),
        };
    for (final entry in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            result: entry.value.result,
            query: entry.value.query,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(GlobalSearchScreen),
            matchesGoldenFile(
              'goldens/global_search_${entry.key}__${brightness.name}.png',
            ),
          );
          await dumpStructure(
            tester,
            'global_search_${entry.key}__${brightness.name}',
          );
        });
      }
    }
  });
}
