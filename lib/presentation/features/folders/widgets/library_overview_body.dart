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
    super.key,
  });

  final LibraryOverviewReadModel model;
  final bool isSearching;
  final VoidCallback onCreateFolder;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    if (model.folders.isEmpty) {
      // Distinguish a genuinely empty library from a search that matched none.
      if (isSearching && model.totalFolderCount > 0) {
        return LibrarySearchNoResultsSection(onClear: onClearSearch);
      }
      return LibraryEmptyStateSection(onCreateFolder: onCreateFolder);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: <Widget>[
        if (model.dueToday > 0) ...<Widget>[
          LibraryDueSummaryCard(dueToday: model.dueToday),
          const SizedBox(height: SpacingTokens.lg),
        ],
        LibraryFolderCountHeader(count: model.folders.length),
        const SizedBox(height: SpacingTokens.sm),
        for (final FolderWithCount item in model.folders) ...<Widget>[
          LibraryFolderTile(
            item: item,
            onTap: () => context.pushFolderDetail(item.folder.id),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }
}
