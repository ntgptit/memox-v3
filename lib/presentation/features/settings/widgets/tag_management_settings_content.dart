import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

part 'tag_management_settings_content_merge_overlays.dart';
part 'tag_management_settings_content_overlays.dart';

enum TagManagementState {
  loaded,
  loading,
  empty,
  searchEmpty,
  sheet,
  rename,
  renameMerge,
  merge,
  del,
  busy,
  opError,
}

class TagManagementSettingsContent extends StatelessWidget {
  const TagManagementSettingsContent({required this.state, super.key});

  final TagManagementState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<_TagManagementEntry> tags = _tagEntries(
      busy: state == TagManagementState.busy,
    );
    final TagManagementState bodyState = state == TagManagementState.opError
        ? TagManagementState.loaded
        : state;
    final bool searchEmpty = state == TagManagementState.searchEmpty;

    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.only(bottom: SpacingTokens.xl),
          children: <Widget>[
            _TagSearchBar(
              query: searchEmpty ? 'phras' : '',
              searchEmpty: searchEmpty,
              hint: l10n.settingsTagsSearchHint,
            ),
            const SizedBox(height: SpacingTokens.sm),
            _TagCountSortRow(
              label: searchEmpty
                  ? l10n.settingsTagsSearchEmptyTitle
                  : state == TagManagementState.empty
                  ? l10n.settingsTagsEmptyTitle
                  : l10n.settingsTagsCount(tags.length),
              sortLabel: l10n.settingsTagsSortMostCards,
            ),
            const SizedBox(height: SpacingTokens.xs),
            _TagManagementBody(state: bodyState, tags: tags, l10n: l10n),
          ],
        ),
        if (state == TagManagementState.sheet)
          _TagContextSheetOverlay(l10n: l10n, tag: _selectedTag),
        if (state == TagManagementState.rename ||
            state == TagManagementState.renameMerge)
          _RenameTagDialogOverlay(
            l10n: l10n,
            tag: _selectedTag,
            conflict: state == TagManagementState.renameMerge,
          ),
        if (state == TagManagementState.merge)
          _MergeTagSheetOverlay(
            l10n: l10n,
            tag: _selectedTag,
            destinations: _mergeCandidates,
          ),
        if (state == TagManagementState.del)
          _DeleteTagDialogOverlay(l10n: l10n, tag: _selectedTag),
        if (state == TagManagementState.opError) TagErrorToast(l10n: l10n),
      ],
    );
  }
}

class _TagManagementEntry {
  const _TagManagementEntry({
    required this.name,
    required this.count,
    this.hot = false,
    this.busy = false,
  });

  final String name;
  final int count;
  final bool hot;
  final bool busy;
}

const _TagManagementEntry _selectedTag =
    _TagManagementEntry(name: 'verb', count: 80, hot: true);

const List<_TagManagementEntry> _mergeCandidates = <_TagManagementEntry>[
  _TagManagementEntry(name: 'verbs', count: 22),
  _TagManagementEntry(name: 'verb-past', count: 15),
  _TagManagementEntry(name: 'adj', count: 30),
  _TagManagementEntry(name: 'greet', count: 42),
];

List<_TagManagementEntry> _tagEntries({required bool busy}) {
  final List<_TagManagementEntry> tags = <_TagManagementEntry>[
    const _TagManagementEntry(name: 'verb', count: 80, hot: true),
    const _TagManagementEntry(name: 'noun', count: 60),
    const _TagManagementEntry(name: 'greet', count: 42),
    const _TagManagementEntry(name: 'adj', count: 30),
    const _TagManagementEntry(name: 'weak', count: 12),
    const _TagManagementEntry(name: 'business', count: 9),
  ];
  if (!busy) {
    return tags;
  }
  return tags
      .map(
        (_TagManagementEntry tag) => tag.name == 'business'
            ? const _TagManagementEntry(
                name: 'business',
                count: 9,
                busy: true,
              )
            : tag,
      )
      .toList(growable: false);
}

class _TagSearchBar extends StatelessWidget {
  const _TagSearchBar({
    required this.query,
    required this.searchEmpty,
    required this.hint,
  });

  final String query;
  final bool searchEmpty;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: RadiusTokens.brMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            size: SizeTokens.iconSm,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              searchEmpty ? query : hint,
              role: MxTextRole.bodyMedium,
              color: searchEmpty ? scheme.onSurface : scheme.onSurfaceVariant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (searchEmpty)
            MxIconButton(
              icon: Icons.close,
              size: MxIconButtonSize.compact,
              color: scheme.onSurfaceVariant,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class _TagCountSortRow extends StatelessWidget {
  const _TagCountSortRow({required this.label, required this.sortLabel});

  final String label;
  final String sortLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        MxText(
          label,
          role: MxTextRole.labelLarge,
          color: scheme.onSurfaceVariant,
        ),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: RadiusTokens.brFull,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.swap_vert,
                size: SizeTokens.iconXs,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.xs),
              MxText(
                sortLabel,
                role: MxTextRole.labelMedium,
                color: scheme.onSurface,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Icon(
                Icons.keyboard_arrow_down,
                size: SizeTokens.iconXs,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagManagementBody extends StatelessWidget {
  const _TagManagementBody({
    required this.state,
    required this.tags,
    required this.l10n,
  });

  final TagManagementState state;
  final List<_TagManagementEntry> tags;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (state == TagManagementState.loading) {
      return const KeyedSubtree(
        key: ValueKey<String>('tag-management-loading'),
        child: SizedBox(
          height:
              SpacingTokens.xxxl +
              SpacingTokens.xxxl +
              SpacingTokens.xxxl +
              SpacingTokens.xxxl +
              SpacingTokens.xxxl +
              SpacingTokens.xxl,
          child: MxLoadingState(rows: 5),
        ),
      );
    }
    if (state == TagManagementState.empty) {
      return KeyedSubtree(
        key: const ValueKey<String>('tag-management-empty'),
        child: MxEmptyState(
          icon: Icons.sell_outlined,
          title: l10n.settingsTagsEmptyTitle,
          message: l10n.settingsTagsEmptyMessage,
          actionLabel: l10n.settingsTagsEmptyAction,
          onAction: () {},
        ),
      );
    }
    if (state == TagManagementState.searchEmpty) {
      return KeyedSubtree(
        key: const ValueKey<String>('tag-management-search-empty'),
        child: MxEmptyState(
          icon: Icons.search,
          title: l10n.settingsTagsSearchEmptyTitle,
          message: l10n.settingsTagsSearchEmptyMessage,
        ),
      );
    }
    return KeyedSubtree(
      key: const ValueKey<String>('tag-management-loaded'),
      child: _TagListCard(tags: tags, l10n: l10n),
    );
  }
}

class _TagListCard extends StatelessWidget {
  const _TagListCard({required this.tags, required this.l10n});

  final List<_TagManagementEntry> tags;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int index = 0; index < tags.length; index++)
            _TagManagementRow(
              tag: tags[index],
              last: index == tags.length - 1,
              l10n: l10n,
              dividerColor: scheme.outlineVariant,
            ),
        ],
      ),
    );
  }
}

class _TagManagementRow extends StatelessWidget {
  const _TagManagementRow({
    required this.tag,
    required this.last,
    required this.l10n,
    required this.dividerColor,
  });

  final _TagManagementEntry tag;
  final bool last;
  final AppLocalizations l10n;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final String semanticLabel =
        '${l10n.tagHashLabel(tag.name)}, ${l10n.settingsTagsCardCount(tag.count)}';
    return Semantics(
      label: semanticLabel,
      button: true,
      child: MxTappable(
        onTap: () {},
        borderRadius: RadiusTokens.brLg,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: last ? BorderSide.none : BorderSide(color: dividerColor),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: RadiusTokens.brMd,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.sell_outlined,
                  size: SizeTokens.iconXs,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: MxText(
                            l10n.tagHashLabel(tag.name),
                            role: MxTextRole.titleSmall,
                            fontWeight: TypographyTokens.semiBold,
                          ),
                        ),
                        if (tag.hot) ...<Widget>[
                          const SizedBox(width: SpacingTokens.xs),
                          _TagHotBadge(label: l10n.settingsTagsMostUsedBadge),
                        ],
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      l10n.settingsTagsCardCount(tag.count),
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              if (tag.busy)
                const SizedBox(
                  width: 18,
                  child: MxLinearProgress(value: 0.6, height: 3),
                ),
              if (!tag.busy)
                MxIconButton(
                  icon: Icons.more_vert,
                  size: MxIconButtonSize.compact,
                  color: scheme.onSurfaceVariant,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagHotBadge extends StatelessWidget {
  const _TagHotBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.18),
        borderRadius: RadiusTokens.brFull,
      ),
      alignment: Alignment.center,
      child: MxText(
        label,
        role: MxTextRole.labelSmall,
        color: scheme.tertiary,
        fontWeight: TypographyTokens.bold,
      ),
    );
  }
}
