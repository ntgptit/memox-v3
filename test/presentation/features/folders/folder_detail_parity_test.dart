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

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for folder-detail (identity by KEY). The create-deck
/// FAB (decks mode) and new-subfolder FAB (subfolders mode) are mode-specific; the
/// search dock appears only in search — each asserted in the state it renders.
void main() {
  const String id = 'fold1';
  final DateTime t = DateTime.utc(2026);

  Folder folder(ContentMode mode) => Folder(
    id: id,
    parentId: null,
    name: 'Languages',
    contentMode: mode,
    sortOrder: 0,
    createdAt: t,
    updatedAt: t,
  );

  final FolderDetail decksMode = FolderDetail(
    folder: folder(ContentMode.decks),
    breadcrumb: <Folder>[folder(ContentMode.decks)],
    subfolders: const <FolderSummary>[],
    decks: <DeckSummary>[
      DeckSummary(
        deck: Deck(
          id: 'd1',
          folderId: id,
          name: 'Japanese · N5',
          targetLanguage: TargetLanguage.korean,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        cardCount: 10,
        dueCount: 0,
      ),
    ],
    deckCount: 1,
    subtreeDeckCount: 1,
    cardCount: 10,
    dueCount: 0,
  );

  final FolderDetail subfoldersMode = FolderDetail(
    folder: folder(ContentMode.subfolders),
    breadcrumb: <Folder>[folder(ContentMode.subfolders)],
    subfolders: <FolderSummary>[
      FolderSummary(
        folder: Folder(
          id: 's1',
          parentId: id,
          name: 'East Asian',
          contentMode: ContentMode.decks,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        subfolderCount: 0,
        deckCount: 1,
        cardCount: 10,
        dueCount: 0,
      ),
    ],
    decks: const <DeckSummary>[],
    deckCount: 0,
    subtreeDeckCount: 1,
    cardCount: 10,
    dueCount: 0,
  );

  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  Future<void> pump(WidgetTester tester, FolderDetail seed) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          folderDetailStreamProvider(
            id,
          ).overrideWith((ref) => Stream<FolderDetail?>.value(seed)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FolderDetailScreen(folderId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('04-folder-detail decks mode → create-deck FAB', (tester) async {
    await pump(tester, decksMode);
    expectParityContract('04-folder-detail (decks)', <String, Finder>{
      'create-deck FAB': node('04-folder-detail/create-deck-fab'),
      'stat card': node('04-folder-detail/stat-card'),
    });
  });

  testWidgets('04-folder-detail search → search dock', (tester) async {
    await pump(tester, decksMode);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expectParityContract('04-folder-detail (search)', <String, Finder>{
      'search dock': node('04-folder-detail/search-dock'),
    });
  });

  testWidgets('04-folder-detail subfolders mode → new-subfolder FAB', (
    tester,
  ) async {
    await pump(tester, subfoldersMode);
    expectParityContract('04-folder-detail (subfolders)', <String, Finder>{
      'new-subfolder FAB': node('04-folder-detail/new-subfolder-fab'),
    });
  });

  testWidgets(
    '04-folder-detail binding contract (keyed nodes realize kit components)',
    (tester) async {
      // Decks mode renders stat-card → MxCard and create-deck-fab → MxFab;
      // subfolders mode renders new-subfolder-fab → MxFab. The helper skips nodes
      // absent in the pumped state, so covering both modes asserts every keyed
      // component (deck-list is a content container with no kit component → skipped).
      await pump(tester, decksMode);
      expectGeneratedBindingContract('04-folder-detail');
      await pump(tester, subfoldersMode);
      expectGeneratedBindingContract('04-folder-detail');
    },
  );
}
