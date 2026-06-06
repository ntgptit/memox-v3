import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_deck_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_summary.dart';
import 'package:memox/presentation/features/folders/widgets/folder_subfolder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_unlocked_empty.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Renders a loaded [FolderDetail] — the subfolders or decks list, the
/// unlocked mode-choice, the empty-locked state, or search-no-results
/// (`docs/wireframes/05-folder-detail.md` §States). A folder holds **either**
/// subfolders **or** decks, gated by `content_mode`.
class FolderDetailBody extends StatelessWidget {
  const FolderDetailBody({
    required this.detail,
    required this.isSearching,
    required this.onNewSubfolder,
    required this.onNewDeck,
    required this.onClearSearch,
    required this.onShowSubfolderActions,
    required this.onShowDeckActions,
    super.key,
  });

  final FolderDetail detail;
  final bool isSearching;
  final VoidCallback onNewSubfolder;
  final VoidCallback onNewDeck;
  final VoidCallback onClearSearch;
  final void Function(FolderWithCount item) onShowSubfolderActions;
  final void Function(DeckWithCount item) onShowDeckActions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Unlocked folders are always empty; offer the mode-choice flow.
    if (detail.folder.contentMode == ContentMode.unlocked) {
      return FolderUnlockedEmpty(
        onNewSubfolder: onNewSubfolder,
        onNewDeck: onNewDeck,
      );
    }

    final bool isSubfolderMode =
        detail.folder.contentMode == ContentMode.subfolders;
    final bool isEmpty = isSubfolderMode
        ? detail.subfolders.isEmpty
        : detail.decks.isEmpty;

    if (isEmpty) {
      if (isSearching) {
        return MxEmptyState(
          key: const ValueKey<String>('folder_search_no_results'),
          icon: Icons.search_off_outlined,
          title: l10n.librarySearchNoResultsTitle,
          message: l10n.librarySearchNoResultsMessage,
          actionLabel: l10n.commonClear,
          onAction: onClearSearch,
        );
      }
      return MxEmptyState(
        icon: Icons.folder_open_outlined,
        title: l10n.folderEmptyLockedTitle,
        message: l10n.folderEmptyLockedMessage,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: <Widget>[
        isSubfolderMode
            ? FolderSubfoldersSummary(subfolders: detail.subfolders)
            : FolderDecksSummary(decks: detail.decks),
        const SizedBox(height: SpacingTokens.md),
        MxSectionHeader(
          label: isSubfolderMode
              ? l10n.libraryFolderSubfoldersCount(detail.subfolders.length)
              : l10n.libraryFolderDecksCount(detail.decks.length),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (isSubfolderMode)
          for (final FolderWithCount item in detail.subfolders) ...<Widget>[
            FolderSubfolderTile(
              item: item,
              onTap: () => context.pushFolderDetail(item.folder.id),
              onShowActions: () => onShowSubfolderActions(item),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
        if (!isSubfolderMode)
          for (final DeckWithCount item in detail.decks) ...<Widget>[
            FolderDeckTile(
              item: item,
              onTap: () => context.pushFlashcardList(item.deck.id),
              onShowActions: () => onShowDeckActions(item),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
      ],
    );
  }
}
