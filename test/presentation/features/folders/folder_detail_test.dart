import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/folder_detail_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_deck_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_body.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_summary.dart';
import 'package:memox/presentation/features/folders/widgets/folder_subfolder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_unlocked_empty.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';

Folder _folder(String name, {ContentMode mode = ContentMode.decks}) => Folder(
  id: name,
  parentId: null,
  name: name,
  contentMode: mode,
  sortOrder: 0,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

DeckWithCount _deck(
  String name, {
  int cardCount = 40,
  int dueCount = 0,
  DateTime? lastStudiedAt,
}) => DeckWithCount(
  deck: Deck(
    id: name,
    folderId: 'parent',
    name: name,
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  ),
  cardCount: cardCount,
  dueCount: dueCount,
  lastStudiedAt: lastStudiedAt,
);

FolderWithCount _subfolder(
  String name, {
  int deckCount = 3,
  int cardCount = 40,
  int dueCount = 0,
}) => FolderWithCount(
  folder: _folder(name, mode: ContentMode.decks),
  subfolderCount: 0,
  deckCount: deckCount,
  cardCount: cardCount,
  dueCount: dueCount,
);

FolderDetail _detail({
  ContentMode mode = ContentMode.decks,
  List<DeckWithCount> decks = const <DeckWithCount>[],
  List<FolderWithCount> subfolders = const <FolderWithCount>[],
}) => FolderDetail(
  folder: _folder('TOPIK II', mode: mode),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'k', name: 'Korean'),
  ],
  subfolders: subfolders,
  decks: decks,
);

Widget _wrapBody(FolderDetail detail, {bool isSearching = false}) =>
    MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FolderDetailBody(
          detail: detail,
          isSearching: isSearching,
          searchTerm: 'grammar',
          sort: ContentSortMode.manual,
          onStartStudy: () {},
          onNewSubfolder: () {},
          onNewDeck: () {},
          onClearSearch: () {},
          onShowSubfolderActions: (FolderWithCount _) {},
          onShowDeckActions: (DeckWithCount _) {},
          onSearchTap: () {},
          onSortTap: () {},
        ),
      ),
    );

Widget _wrapScreen(Stream<FolderDetail> stream) => ProviderScope(
  overrides: [
    folderDetailQueryProvider('f1').overrideWith((Ref ref) => stream),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const FolderDetailScreen(folderId: 'f1'),
  ),
);

Widget _wrapScreenWithSortLauncher(Stream<FolderDetail> stream) =>
    ProviderScope(
      overrides: [
        folderDetailQueryProvider('f1').overrideWith((Ref ref) => stream),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Stack(
          children: <Widget>[
            const FolderDetailScreen(folderId: 'f1'),
            Align(
              alignment: Alignment.bottomLeft,
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) =>
                    TextButton(
                      onPressed: () =>
                          showFolderDetailSortSheet(context, ref, 'f1'),
                      child: const Text('open sort sheet'),
                    ),
              ),
            ),
          ],
        ),
      ),
    );

Widget _wrapDeckTile(FolderDeckTile tile) => MaterialApp(
  locale: const Locale('en'),
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: tile)),
);

void main() {
  group('FolderDetailBody — Decks state (1/8)', () {
    testWidgets('summary card shows decks · cards line and the due total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(
            decks: <DeckWithCount>[
              _deck('Vocab 1', cardCount: 62, dueCount: 4),
              _deck('Vocab 2', cardCount: 58, dueCount: 4),
            ],
          ),
        ),
      );

      expect(find.byType(FolderDecksSummary), findsOneWidget);
      expect(find.text('Mastery unavailable'), findsOneWidget);
      expect(find.text('2 decks · 120 cards'), findsOneWidget);
      // Folder-scope total (4 + 4) is distinct from each deck's "4 due" badge.
      expect(find.text('8 due'), findsOneWidget);
      expect(find.textContaining('new'), findsNothing);
      expect(find.text('4 due'), findsNWidgets(2));
      expect(find.text('Start study'), findsOneWidget);
      expect(find.byType(FolderDeckTile), findsNWidgets(2));
    });

    testWidgets('zero folder-scope due shows the all-caught-up line', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(decks: <DeckWithCount>[_deck('Verb conj', cardCount: 148)]),
        ),
      );

      expect(find.text('All caught up'), findsOneWidget);
      expect(find.textContaining('due'), findsNothing);
    });
  });

  group('FolderDetailBody — Subfolders state (2/8)', () {
    testWidgets('summary strip shows subfolders, cards, and due totals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(
            mode: ContentMode.subfolders,
            subfolders: <FolderWithCount>[
              _subfolder('TOPIK I', cardCount: 124, dueCount: 8),
              _subfolder('Hangul', cardCount: 74, dueCount: 4),
            ],
          ),
        ),
      );

      expect(find.byType(FolderSubfoldersSummary), findsOneWidget);
      expect(find.text('subfolders'), findsOneWidget);
      expect(find.text('cards'), findsOneWidget);
      expect(find.text('due total'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      // 2 subfolders, 198 cards, 12 due.
      expect(find.text('198'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byType(FolderSubfolderTile), findsNWidgets(2));
      expect(find.byType(LibraryFolderTile), findsNothing);
    });
  });

  group('FolderDetailBody — Unlocked state (3/8)', () {
    testWidgets('renders the dual-CTA mode-choice, no summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapBody(_detail(mode: ContentMode.unlocked)));

      expect(find.byType(FolderUnlockedEmpty), findsOneWidget);
      expect(find.text('EMPTY FOLDER'), findsOneWidget);
      expect(find.text('What goes in here?'), findsOneWidget);
      expect(find.text('New deck'), findsOneWidget);
      expect(find.text('New subfolder'), findsOneWidget);
      expect(find.byType(FolderDecksSummary), findsNothing);
      expect(find.byType(FolderSubfoldersSummary), findsNothing);
    });
  });

  group('FolderDetailBody — Search empty (4/8)', () {
    testWidgets('active search with no matches shows the no-results state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(_detail(decks: const <DeckWithCount>[]), isSearching: true),
      );

      expect(
        find.byKey(const ValueKey<String>('folder_search_no_results')),
        findsOneWidget,
      );
      expect(find.textContaining('No items match'), findsOneWidget);
      // The mock keeps the summary shell visible even while search returns no hits.
      expect(find.byType(FolderDecksSummary), findsOneWidget);
    });

    testWidgets('empty-but-locked (not searching) shows locked empty, not '
        'no-results', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapBody(_detail(decks: const <DeckWithCount>[])),
      );

      expect(
        find.byKey(const ValueKey<String>('folder_search_no_results')),
        findsNothing,
      );
      expect(find.byType(FolderDecksSummary), findsNothing);
    });
  });

  group('FolderDetailScreen — Row actions (5/8)', () {
    Future<void> pumpLoaded(
      WidgetTester tester, {
      ContentMode mode = ContentMode.decks,
      List<DeckWithCount> decks = const <DeckWithCount>[],
      List<FolderWithCount> subfolders = const <FolderWithCount>[],
    }) async {
      await tester.pumpWidget(
        _wrapScreen(
          Stream<FolderDetail>.value(
            _detail(mode: mode, decks: decks, subfolders: subfolders),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('subfolder long-press opens the shared folder action sheet', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(
        tester,
        mode: ContentMode.subfolders,
        subfolders: <FolderWithCount>[_subfolder('TOPIK I', dueCount: 8)],
      );

      await tester.longPress(find.byType(FolderSubfolderTile));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
    });

    testWidgets('deck long-press opens the shared deck action sheet', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(
        tester,
        decks: <DeckWithCount>[
          _deck(
            'Vocab — chapter 1',
            cardCount: 62,
            dueCount: 8,
            lastStudiedAt: DateTime.utc(2026, 6, 6, 10),
          ),
        ],
      );

      await tester.longPress(find.byType(FolderDeckTile));
      await tester.pumpAndSettle();

      expect(find.text('Import flashcards'), findsOneWidget);
      expect(find.text('Reorder cards'), findsOneWidget);
      expect(find.text('Delete deck'), findsOneWidget);
    });
  });

  group('FolderDetailScreen — Search / Sort (6/8)', () {
    Future<void> pumpLoaded(WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapScreenWithSortLauncher(
          Stream<FolderDetail>.value(
            _detail(
              decks: <DeckWithCount>[
                _deck('Vocab 1', cardCount: 40, dueCount: 4),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('search icon opens a controlled search sheet and updates the '
        'toolbar state', (WidgetTester tester) async {
      await pumpLoaded(tester);

      final BuildContext scaffoldContext = tester.element(
        find.byType(Scaffold),
      );
      final AppLocalizations l10n = AppLocalizations.of(scaffoldContext);
      final ProviderContainer container = ProviderScope.containerOf(
        scaffoldContext,
      );

      await tester.tap(find.byTooltip(l10n.folderDetailSearchHint).first);
      await tester.pumpAndSettle();

      expect(find.text(l10n.folderDetailSearchSheetTitle), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'grammar');
      await tester.pumpAndSettle();

      expect(
        container.read(folderDetailToolbarProvider('f1')).searchTerm,
        'grammar',
      );

      await tester.tap(find.byTooltip(l10n.librarySearchClearTooltip));
      await tester.pumpAndSettle();

      expect(container.read(folderDetailToolbarProvider('f1')).searchTerm, '');
    });

    testWidgets('sort pill opens a controlled sort sheet and updates the '
        'toolbar state', (WidgetTester tester) async {
      await pumpLoaded(tester);

      final BuildContext scaffoldContext = tester.element(
        find.byType(Scaffold),
      );
      final ProviderContainer container = ProviderScope.containerOf(
        scaffoldContext,
      );

      await tester.tap(find.text('open sort sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      await tester.tap(find.text('Name').last);
      await tester.pumpAndSettle();

      expect(
        container.read(folderDetailToolbarProvider('f1')).sort,
        ContentSortMode.name,
      );
    });
  });

  group('FolderDetailScreen — Loading (6/8) & Error (7/8)', () {
    testWidgets('loading renders the skeleton and no content rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapScreen(const Stream<FolderDetail>.empty()));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('library_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(FolderDeckTile), findsNothing);
    });

    testWidgets('error state renders the localized failure UI with retry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(Stream<FolderDetail>.error(Exception('boom'))),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
    });
  });

  group('FolderDetailScreen — Overflow (Delete 8/8 · Move 9/8)', () {
    Future<void> pumpLoaded(
      WidgetTester tester, {
      ContentMode mode = ContentMode.decks,
    }) async {
      await tester.pumpWidget(
        _wrapScreen(
          Stream<FolderDetail>.value(
            _detail(mode: mode, decks: <DeckWithCount>[_deck('Vocab 1')]),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder appBarKebab() => find.descendant(
      of: find.byType(AppBar),
      matching: find.byIcon(Icons.more_vert),
    );

    testWidgets('app-bar kebab opens the action sheet with mock-approved '
        'actions only', (WidgetTester tester) async {
      await pumpLoaded(tester);

      await tester.tap(appBarKebab());
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
      // Import targets a specific deck, not the folder — hidden here.
      expect(find.text('Import flashcards'), findsNothing);
    });

    testWidgets('Delete opens the destructive subtree-warning confirm dialog', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester);

      await tester.tap(appBarKebab());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete folder'));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(Scaffold)),
      );

      expect(find.text(l10n.folderDeleteDialogTitle), findsOneWidget);
      expect(
        find.text('TOPIK II and its 1 deck will be removed from your library.'),
        findsOneWidget,
      );
      expect(find.text(l10n.folderDeleteDialogReassurance), findsOneWidget);
    });
  });

  group('FolderDeckTile — loaded display (9/10)', () {
    testWidgets(
      'DT1 onDisplay: renders the due badge, last studied metadata, progress '
      'bar, and chevron when study metadata exists',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapDeckTile(
            FolderDeckTile(
              item: _deck(
                'Vocab — chapter 1',
                cardCount: 62,
                dueCount: 8,
                lastStudiedAt: DateTime.utc(2026, 6, 6, 10),
              ),
              onTap: () {},
              referenceNow: DateTime.utc(2026, 6, 6, 12),
            ),
          ),
        );

        expect(find.text('Vocab — chapter 1'), findsOneWidget);
        expect(find.text('62 cards · last 2 hours ago'), findsOneWidget);
        expect(find.text('8 due'), findsOneWidget);
        expect(
          tester.getSize(
            find.byKey(const ValueKey<String>('folder_deck_leading_tile')),
          ),
          const Size(36, 36),
        );
        expect(
          tester
              .getSize(
                find.byKey(const ValueKey<String>('folder_deck_due_badge')),
              )
              .height,
          18,
        );
        expect(find.byIcon(Icons.style_outlined), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'DT2 onDisplay: collapses to cards-only metadata when last studied '
      'metadata is missing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapDeckTile(
            FolderDeckTile(
              item: _deck('Verb conjugation', cardCount: 40, dueCount: 0),
              onTap: () {},
              referenceNow: DateTime.utc(2026, 6, 6, 12),
            ),
          ),
        );

        expect(find.text('40 cards'), findsOneWidget);
        expect(find.textContaining('ago'), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.textContaining('due'), findsNothing);
      },
    );
  });

  group('FolderSubfolderTile — loaded display (10/10)', () {
    Widget wrapFolderTile(FolderSubfolderTile tile) => MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: tile)),
    );

    testWidgets(
      'DT3 onDisplay: renders the due badge, decks + cards metadata, progress '
      'bar, and chevron when subtree due exists',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapFolderTile(
            FolderSubfolderTile(
              item: _subfolder(
                'TOPIK I',
                deckCount: 3,
                cardCount: 124,
                dueCount: 8,
              ),
              onTap: () {},
            ),
          ),
        );

        expect(find.text('TOPIK I'), findsOneWidget);
        expect(find.text('3 decks · 124 cards'), findsOneWidget);
        expect(find.text('8 due'), findsOneWidget);
        expect(
          tester.getSize(
            find.byKey(const ValueKey<String>('folder_subfolder_leading_tile')),
          ),
          const Size(36, 36),
        );
        expect(
          tester
              .getSize(
                find.byKey(
                  const ValueKey<String>('folder_subfolder_due_badge'),
                ),
              )
              .height,
          18,
        );
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(FolderSubfolderTile),
            matching: find.byIcon(Icons.more_vert),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'DT4 onDisplay: collapses to decks + cards metadata when subtree due '
      'is missing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapFolderTile(
            FolderSubfolderTile(
              item: _subfolder(
                'Grammar',
                deckCount: 4,
                cardCount: 138,
                dueCount: 0,
              ),
              onTap: () {},
            ),
          ),
        );

        expect(find.text('Grammar'), findsOneWidget);
        expect(find.text('4 decks · 138 cards'), findsOneWidget);
        expect(find.textContaining('due'), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );
  });
}
