import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

import '../../../support/golden_harness.dart';

Folder _folder(
  String id,
  String name,
  ContentMode mode, {
  String? color,
  String? icon,
}) {
  final DateTime t = DateTime.utc(2026);
  return Folder(
    id: id,
    parentId: null,
    name: name,
    contentMode: mode,
    sortOrder: 0,
    createdAt: t,
    updatedAt: t,
    color: color,
    icon: icon,
  );
}

FolderSummary _summary(
  String id,
  String name, {
  ContentMode mode = ContentMode.decks,
  int decks = 3,
  int cards = 42,
  int due = 0,
  String? color,
  String? icon,
}) => FolderSummary(
  folder: _folder(id, name, mode, color: color, icon: icon),
  subfolderCount: mode == ContentMode.subfolders ? 2 : 0,
  deckCount: decks,
  cardCount: cards,
  dueCount: due,
);

// Behavioral seed: includes a due badge to exercise that branch.
final LibraryOverview _loaded = LibraryOverview(
  folders: <FolderSummary>[
    _summary(
      'a',
      'Korean',
      decks: 5,
      cards: 412,
      due: 12,
      color: 'blue',
      icon: 'translate',
    ),
    _summary(
      'b',
      'English',
      decks: 3,
      cards: 286,
      color: 'amber',
      icon: 'menu_book',
    ),
    _summary('c', 'Misc', mode: ContentMode.subfolders, color: 'teal'),
  ],
);

// Golden seed: due-free, mirroring the kit mock (no due badge on loaded rows).
final LibraryOverview _loadedGolden = LibraryOverview(
  folders: <FolderSummary>[
    _summary(
      'a',
      'Languages',
      decks: 4,
      cards: 412,
      color: 'blue',
      icon: 'translate',
    ),
    _summary(
      'b',
      'Sciences',
      decks: 3,
      cards: 286,
      color: 'amber',
      icon: 'science',
    ),
    _summary(
      'c',
      'History & Geography',
      decks: 2,
      cards: 195,
      color: 'teal',
      icon: 'account_balance',
    ),
    _summary('d', 'Work', decks: 5, cards: 320, color: 'green', icon: 'work'),
    _summary(
      'e',
      'Literature',
      decks: 1,
      cards: 64,
      color: 'violet',
      icon: 'menu_book',
    ),
  ],
);

/// Overrides the overview stream with [stream] and pumps the screen.
Future<void> _pump(
  WidgetTester tester,
  Stream<LibraryOverview> stream, {
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
      overrides: [libraryOverviewStreamProvider.overrideWith((ref) => stream)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LibraryOverviewScreen(),
      ),
    ),
  );
}

Stream<LibraryOverview> _value(LibraryOverview v) =>
    Stream<LibraryOverview>.value(v);
Stream<LibraryOverview> _never() =>
    Stream<LibraryOverview>.fromFuture(Completer<LibraryOverview>().future);
Stream<LibraryOverview> _error() =>
    Stream<LibraryOverview>.error(Exception('boom'));

/// Enters search mode via the app-bar search icon, then types [term].
Future<void> _search(WidgetTester tester, String term) async {
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(MxSearchField), term);
  await tester.pumpAndSettle();
}

void main() {
  group('LibraryOverviewScreen states', () {
    testWidgets('loaded renders folder rows + due badge', (tester) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      expect(find.text('Korean'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      // Loaded shows no count overline (mock 03a).
      expect(find.text('3 FOLDERS'), findsNothing);
      // Due badge only on the folder with dueCount > 0.
      expect(find.text('12 due'), findsOneWidget);
      // FAB present in the loaded (non-search) state.
      expect(find.byType(MxFab), findsOneWidget);
    });

    testWidgets('true-empty renders the empty state + create CTA', (
      tester,
    ) async {
      await _pump(tester, _value(const LibraryOverview(folders: [])));
      await tester.pumpAndSettle();

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text('Create folder'), findsOneWidget);
    });

    testWidgets('error renders the error state', (tester) async {
      await _pump(tester, _error());
      await tester.pumpAndSettle();

      expect(find.byType(MxErrorState), findsOneWidget);
    });

    testWidgets('search mode shows overline, filters, and no-results', (
      tester,
    ) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      await _search(tester, 'kor');
      expect(find.text('Korean'), findsOneWidget);
      expect(find.text('English'), findsNothing);
      expect(find.text('1 FOLDERS'), findsOneWidget);
      // FAB hidden while searching.
      expect(find.byType(MxFab), findsNothing);

      await tester.enterText(find.byType(MxSearchField), 'zzz');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('library_search_no_results')),
        findsOneWidget,
      );
    });

    testWidgets('row tap opens the folder action sheet', (tester) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
    });

    testWidgets('row long-press opens the folder action sheet', (tester) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
    });

    testWidgets('FAB shows only in loaded-with-folders, not empty/loading', (
      tester,
    ) async {
      await _pump(tester, _value(const LibraryOverview(folders: [])));
      await tester.pumpAndSettle();
      expect(find.byType(MxFab), findsNothing);

      await _pump(tester, _never());
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(MxFab), findsNothing);
    });

    testWidgets('no-results is distinct from true-empty', (tester) async {
      await _pump(tester, _value(_loaded));
      await tester.pumpAndSettle();
      await _search(tester, 'zzz');
      expect(find.byType(MxNoResultsState), findsOneWidget);
      expect(find.byType(MxEmptyState), findsNothing);
    });
  });

  group('LibraryOverviewScreen goldens', () {
    final Map<String, Stream<LibraryOverview> Function()> cases =
        <String, Stream<LibraryOverview> Function()>{
          'loaded': () => _value(_loadedGolden),
          'empty': () => _value(const LibraryOverview(folders: [])),
          'loading': _never,
          'error': _error,
        };

    for (final MapEntry<String, Stream<LibraryOverview> Function()> c
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await _pump(tester, c.value(), brightness: brightness, golden: true);
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(LibraryOverviewScreen),
            matchesGoldenFile(
              'goldens/library_overview_${c.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }

    // Search-with-results state (mock 03e): the search app bar + count overline.
    for (final Brightness brightness in Brightness.values) {
      testWidgets('search — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          _value(_loadedGolden),
          brightness: brightness,
          golden: true,
        );
        await tester.pumpAndSettle();
        await _search(tester, 'lang');
        await expectLater(
          find.byType(LibraryOverviewScreen),
          matchesGoldenFile(
            'goldens/library_overview_search__${brightness.name}.png',
          ),
        );
      });
    }

    // The search-no-results derived state is distinct from true-empty.
    for (final Brightness brightness in Brightness.values) {
      testWidgets('search-no-results — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          _value(_loadedGolden),
          brightness: brightness,
          golden: true,
        );
        await tester.pumpAndSettle();
        await _search(tester, 'zzz');
        await expectLater(
          find.byType(LibraryOverviewScreen),
          matchesGoldenFile(
            'goldens/library_overview_search-no-results__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
