import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Grouped global-search results: Folders, Decks, Flashcards. Each non-empty
/// section renders an [MxSectionHeader] (with a "+N more" trailing caption when
/// the match total exceeds the visible cap) and its capped rows. Tapping a row
/// navigates into the matched entity (`docs/wireframes/11-library-search.md`).
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({required this.results, super.key});

  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: <Widget>[
        if (results.folders.isNotEmpty)
          _Section(
            label: l10n.searchSectionFolders,
            total: results.folderTotal,
            shown: results.folders.length,
            rows: <Widget>[
              for (final FolderSearchHit hit in results.folders)
                MxListTile(
                  leading: MxIconTile(
                    icon: Icons.folder_outlined,
                    color: scheme.tertiary,
                  ),
                  title: hit.name,
                  subtitle: l10n.searchResultFolderSubtitle,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushFolderDetail(hit.id),
                ),
            ],
          ),
        if (results.decks.isNotEmpty)
          _Section(
            label: l10n.searchSectionDecks,
            total: results.deckTotal,
            shown: results.decks.length,
            rows: <Widget>[
              for (final DeckSearchHit hit in results.decks)
                MxListTile(
                  leading: const MxIconTile(icon: Icons.style_outlined),
                  title: hit.name,
                  subtitle: l10n.searchResultDeckSubtitle,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushFlashcardList(hit.id),
                ),
            ],
          ),
        if (results.flashcards.isNotEmpty)
          _Section(
            label: l10n.searchSectionFlashcards,
            total: results.flashcardTotal,
            shown: results.flashcards.length,
            rows: <Widget>[
              for (final FlashcardSearchHit hit in results.flashcards)
                MxListTile(
                  leading: const MxIconTile(icon: Icons.notes_outlined),
                  title: hit.front,
                  subtitle: hit.back,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushFlashcardList(hit.deckId),
                ),
            ],
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.total,
    required this.shown,
    required this.rows,
  });

  final String label;
  final int total;
  final int shown;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int overflow = total - shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.xs,
          ),
          child: MxSectionHeader(
            label: label,
            trailing: overflow > 0
                ? MxText(
                    l10n.searchMoreCount(overflow),
                    role: MxTextRole.labelMedium,
                    color: scheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        ...rows,
        const SizedBox(height: SpacingTokens.sm),
      ],
    );
  }
}
