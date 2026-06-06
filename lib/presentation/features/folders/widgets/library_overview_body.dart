import 'package:flutter/material.dart';

import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_sections.dart';

/// Renders the loaded read model — choosing between the folder list, the
/// true-empty state, and the search-no-results state
/// (`docs/wireframes/02-library.md` §States).
class LibraryOverviewBody extends StatelessWidget {
  const LibraryOverviewBody({
    required this.model,
    required this.isSearching,
    required this.onCreateFolder,
    required this.onClearSearch,
    required this.onShowFolderActions,
    super.key,
  });

  final LibraryOverviewReadModel model;
  final bool isSearching;
  final VoidCallback onCreateFolder;
  final VoidCallback onClearSearch;

  /// Opens the folder action sheet for one row (kebab tap / long-press).
  final void Function(FolderWithCount item) onShowFolderActions;

  @override
  Widget build(BuildContext context) {
    if (model.folders.isEmpty) {
      // Distinguish a genuinely empty library from a search that matched none.
      if (isSearching && model.totalFolderCount > 0) {
        return LibrarySearchNoResults(onClear: onClearSearch);
      }
      return LibraryEmptyStateSection(onCreateFolder: onCreateFolder);
    }

    final int dueFolderCount = model.folders
        .where((FolderWithCount item) => item.dueCount > 0)
        .length;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: <Widget>[
        if (model.dueToday > 0) ...<Widget>[
          LibraryDueSummary(
            dueToday: model.dueToday,
            dueFolderCount: dueFolderCount,
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        LibraryFolderHeader(count: model.folders.length),
        const SizedBox(height: SpacingTokens.sm + SpacingTokens.xxs),
        for (final FolderWithCount item in model.folders) ...<Widget>[
          LibraryFolderTile(
            item: item,
            onTap: () => context.pushFolderDetail(item.folder.id),
            // Kebab tap and row long-press both open the folder action sheet
            // (Rename / Move / Import flashcards / Delete) per
            // `docs/wireframes/02-library.md` §Overflow sheet.
            onShowActions: () => onShowFolderActions(item),
          ),
          const SizedBox(height: SpacingTokens.sm + SpacingTokens.xxs),
        ],
      ],
    );
  }
}
