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

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for library-overview (identity by KEY). The FAB is
/// a loaded-state node; the search dock appears only after toggling search — each
/// is asserted in the state where the design renders it.
void main() {
  final DateTime t = DateTime.utc(2026);
  final LibraryOverview overview = LibraryOverview(
    folders: <FolderSummary>[
      FolderSummary(
        folder: Folder(
          id: 'f1',
          parentId: null,
          name: 'Languages',
          contentMode: ContentMode.decks,
          sortOrder: 0,
          createdAt: t,
          updatedAt: t,
        ),
        subfolderCount: 0,
        deckCount: 3,
        cardCount: 42,
        dueCount: 0,
      ),
    ],
  );

  Finder node(String i) => find.byKey(ValueKey<String>('mx-node:$i'));

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryOverviewStreamProvider.overrideWith(
            (ref) => Stream<LibraryOverview>.value(overview),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LibraryOverviewScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('03-library parity contract (loaded + search)', (tester) async {
    await pump(tester);
    expectParityContract('03-library (loaded)', <String, Finder>{
      'new-folder FAB': node('03-library/new-folder-fab'),
      'sort button': node('03-library/sort-btn'),
    });

    // Enter search via the app-bar icon → the dock mounts (and the FAB hides).
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expectParityContract('03-library (search)', <String, Finder>{
      'search dock': node('03-library/search-dock'),
    });
  });

  testWidgets(
    '03-library binding contract (keyed nodes realize kit components)',
    (tester) async {
      await pump(tester);
      // Loaded state: sort-btn → MxIconButton, new-folder-fab → MxFab realize the
      // kit's component choice (folder-list is a content container with no kit
      // component → skipped by the helper). Catches a design-system bypass the
      // presence contract cannot (right key, wrong widget).
      expectGeneratedBindingContract('03-library-overview');
    },
  );
}
