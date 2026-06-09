import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/screens/global_search_screen.dart';
import 'package:memox/presentation/features/search/viewmodels/search_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:riverpod/misc.dart';

SearchResults _results({
  List<FolderSearchHit> folders = const <FolderSearchHit>[],
  List<DeckSearchHit> decks = const <DeckSearchHit>[],
  List<FlashcardSearchHit> flashcards = const <FlashcardSearchHit>[],
  int folderTotal = 0,
  int deckTotal = 0,
  int flashcardTotal = 0,
}) => SearchResults(
  folders: folders,
  decks: decks,
  flashcards: flashcards,
  folderTotal: folderTotal,
  deckTotal: deckTotal,
  flashcardTotal: flashcardTotal,
);

Widget _wrap(Override searchOverride) => ProviderScope(
  overrides: <Override>[searchOverride],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const GlobalSearchScreen(),
  ),
);

void main() {
  testWidgets('empty/hint state when the query is below the minimum', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(searchResultsProvider.overrideWith((Ref ref) async => null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search your library'), findsOneWidget);
    expect(
      find.text(
        'Type at least 2 characters to find folders, decks, and cards.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'loading state renders the skeleton while the query is in flight',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          searchResultsProvider.overrideWith(
            (Ref ref) => Completer<SearchResults?>().future,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets('results state renders grouped sections and "+N more"', (
    WidgetTester tester,
  ) async {
    final SearchResults populated = _results(
      folders: <FolderSearchHit>[
        for (int i = 0; i < 5; i++)
          FolderSearchHit(id: 'f$i', name: 'Korean $i'),
      ],
      folderTotal: 7,
      decks: const <DeckSearchHit>[DeckSearchHit(id: 'd1', name: 'Verbs')],
      deckTotal: 1,
      flashcards: const <FlashcardSearchHit>[
        FlashcardSearchHit(
          id: 'c1',
          deckId: 'd1',
          front: 'eat',
          back: 'meokda',
        ),
      ],
      flashcardTotal: 1,
    );

    await tester.pumpWidget(
      _wrap(searchResultsProvider.overrideWith((Ref ref) async => populated)),
    );
    await tester.pumpAndSettle();

    // Section headers (uppercased by MxSectionHeader).
    expect(find.text('FOLDERS'), findsOneWidget);
    expect(find.text('DECKS'), findsOneWidget);
    expect(find.text('FLASHCARDS'), findsOneWidget);
    // A capped section reports its overflow.
    expect(find.text('+2 more'), findsOneWidget);
    // Representative rows.
    expect(find.text('Korean 0'), findsOneWidget);
    expect(find.text('Verbs'), findsOneWidget);
    expect(find.text('eat'), findsOneWidget);
  });

  testWidgets('no-results state when the query matched nothing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(searchResultsProvider.overrideWith((Ref ref) async => _results())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No results'), findsOneWidget);
    expect(
      find.text('Nothing in your library matches that search.'),
      findsOneWidget,
    );
  });

  testWidgets('error state renders the localized failure UI with retry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        searchResultsProvider.overrideWith(
          // Failures are values, not Errors — surfaced as AsyncError on purpose.
          // ignore: only_throw_errors
          (Ref ref) async => throw const StorageFailure(
            operation: StorageOp.read,
            cause: 'boom',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    // No raw failure detail leaks into the UI.
    expect(find.textContaining('boom'), findsNothing);
  });
}
