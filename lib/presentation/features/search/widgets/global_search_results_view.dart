import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/folder_visual_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// The loaded global-search results: grouped Folders / Decks / Flashcards
/// sections, each a header (label + count) over one `MxCard` of tappable rows
/// (`docs/wireframes/11-library-search.md`). Tapping a result navigates to it:
/// folder → folder detail, deck → its flashcard list, flashcard → its owning
/// deck's list (per-card scroll/select is Future). A section shows a "+N more"
/// line when its un-capped total exceeds the shown rows. WBS 3.5.2.
class GlobalSearchResultsView extends ConsumerWidget {
  const GlobalSearchResultsView({required this.results, super.key});

  final SearchResults results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space4,
        MxSpacing.screen,
        MxSpacing.space10,
      ),
      children: <Widget>[
        if (results.folders.isNotEmpty)
          _Section(
            title: l10n.searchSectionFolders,
            shown: results.folders.length,
            total: results.folderTotal,
            rows: <Widget>[
              for (final Folder folder in results.folders)
                MxListTile(
                  leading: MxIconTile(
                    color: folderTint(colors, folder.color),
                    icon: folderGlyph(folder.icon),
                  ),
                  title: folder.name,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.textTertiary,
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.searchFolderDetail,
                    pathParameters: <String, String>{RouteParams.id: folder.id},
                  ),
                ),
            ],
          ),
        if (results.decks.isNotEmpty)
          _Section(
            title: l10n.searchSectionDecks,
            shown: results.decks.length,
            total: results.deckTotal,
            rows: <Widget>[
              for (final Deck deck in results.decks)
                MxListTile(
                  leading: MxIconTile(
                    color: colors.accent,
                    icon: Icons.style_outlined,
                  ),
                  title: deck.name,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.textTertiary,
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.searchDeckFlashcards,
                    pathParameters: <String, String>{
                      RouteParams.deckId: deck.id,
                    },
                  ),
                ),
            ],
          ),
        if (results.flashcards.isNotEmpty)
          _Section(
            title: l10n.searchSectionFlashcards,
            shown: results.flashcards.length,
            total: results.flashcardTotal,
            rows: <Widget>[
              for (final Flashcard card in results.flashcards)
                MxListTile(
                  leading: MxIconTile(
                    color: colors.statusLearning,
                    icon: Icons.layers_outlined,
                  ),
                  title: card.front,
                  subtitle: card.back,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.textTertiary,
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.deckFlashcards,
                    pathParameters: <String, String>{
                      RouteParams.deckId: card.deckId,
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// One results section: a header (label + shown count) over a single card of
/// rows separated by inset hairlines, with an optional "+N more" footer.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.shown,
    required this.total,
    required this.rows,
  });

  final String title;
  final int shown;
  final int total;
  final List<Widget> rows;

  /// Row-separator inset: aligns the hairline under the row text, past the
  /// leading icon tile (`MxIconTile` 40px) + its gap (`space3`).
  static const double _rowDividerInset = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int more = total - shown;
    return Padding(
      padding: const EdgeInsets.only(bottom: MxSpacing.gapSection),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: MxSpacing.space2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MxText(title, role: MxTextRole.titleSmall),
                MxText(
                  '$shown',
                  role: MxTextRole.labelMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          MxCard(
            padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < rows.length; i++) ...<Widget>[
                  if (i > 0) const MxDivider(indent: _rowDividerInset),
                  rows[i],
                ],
                if (more > 0) ...<Widget>[
                  const MxDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: MxSpacing.space3,
                    ),
                    child: MxText(
                      l10n.searchMoreCount(more),
                      role: MxTextRole.labelMedium,
                      color: colors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
