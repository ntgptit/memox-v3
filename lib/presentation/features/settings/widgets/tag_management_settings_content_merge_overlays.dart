// ignore_for_file: flutter.max_build_lines

part of 'tag_management_settings_content.dart';

class _RenameTagDialogOverlay extends StatelessWidget {
  const _RenameTagDialogOverlay({
    required this.l10n,
    required this.tag,
    required this.conflict,
  });

  final AppLocalizations l10n;
  final _TagManagementEntry tag;
  final bool conflict;

  @override
  Widget build(BuildContext context) => _buildSheet(context);

  Widget _buildSheet(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextEditingController controller = TextEditingController(
      text: conflict ? 'noun' : 'verbs',
    );
    return Positioned.fill(
      child: ColoredBox(
        color: scheme.shadow.withValues(alpha: 0.45),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: _RenameDialogCard(
              key: ValueKey<String>(
                conflict
                    ? 'tag-management-rename-merge'
                    : 'tag-management-rename',
              ),
              l10n: l10n,
              scheme: scheme,
              controller: controller,
              tag: tag,
              conflict: conflict,
            ),
          ),
        ),
      ),
    );
  }
}

class _RenameDialogCard extends StatelessWidget {
  const _RenameDialogCard({
    required this.l10n,
    required this.scheme,
    required this.controller,
    required this.tag,
    required this.conflict,
    required super.key,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final TextEditingController controller;
  final _TagManagementEntry tag;
  final bool conflict;

  @override
  Widget build(BuildContext context) => _buildRenameDialogCard(
    context: context,
    l10n: l10n,
    scheme: scheme,
    controller: controller,
    tag: tag,
    conflict: conflict,
  );
}

Widget _buildRenameDialogCard({
  required BuildContext context,
  required AppLocalizations l10n,
  required ColorScheme scheme,
  required TextEditingController controller,
  required _TagManagementEntry tag,
  required bool conflict,
}) => Container(
  constraints: const BoxConstraints(maxWidth: 340),
  decoration: BoxDecoration(
    color: scheme.surface,
    borderRadius: RadiusTokens.brXl,
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.24),
        blurRadius: ShadowTokens.blurDialog,
        offset: const Offset(0, 16),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(SpacingTokens.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxText(
          l10n.settingsTagsRenameTitle,
          role: MxTextRole.titleLarge,
          fontWeight: TypographyTokens.bold,
        ),
        const SizedBox(height: SpacingTokens.xs),
        MxText(
          l10n.settingsTagsRenameHelper(l10n.tagHashLabel(tag.name)),
          role: MxTextRole.bodyMedium,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxTextField(
          controller: controller,
          hintText: l10n.settingsTagsRenameHint,
          prominent: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (conflict) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.18),
              borderRadius: RadiusTokens.brMd,
              border: Border.all(
                color: scheme.tertiary.withValues(alpha: 0.24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.merge_type,
                  size: SizeTokens.iconXs,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: MxText(
                    l10n.settingsTagsRenameConflictMessage(
                      l10n.tagHashLabel('noun'),
                    ),
                    role: MxTextRole.labelMedium,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        MxText(
          conflict
              ? l10n.settingsTagsMergeConfirmAction
              : l10n.settingsTagsRenameConfirm,
          role: MxTextRole.labelSmall,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MxSecondaryButton(
              label: MaterialLocalizations.of(context).cancelButtonLabel,
              variant: MxSecondaryVariant.outlined,
              onPressed: () {},
            ),
            const SizedBox(width: SpacingTokens.sm),
            MxPrimaryButton(
              label: conflict
                  ? l10n.settingsTagsMergeConfirmAction
                  : l10n.settingsTagsRenameConfirm,
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  ),
);

class _MergeTagSheetOverlay extends StatelessWidget {
  const _MergeTagSheetOverlay({
    required this.l10n,
    required this.tag,
    required this.destinations,
  });

  final AppLocalizations l10n;
  final _TagManagementEntry tag;
  final List<_TagManagementEntry> destinations;

  @override
  Widget build(BuildContext context) =>
      _MergeTagSheetContent(l10n: l10n, tag: tag, destinations: destinations);
}

class _MergeTagSheetContent extends StatelessWidget {
  const _MergeTagSheetContent({
    required this.l10n,
    required this.tag,
    required this.destinations,
  });

  final AppLocalizations l10n;
  final _TagManagementEntry tag;
  final List<_TagManagementEntry> destinations;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Positioned.fill(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ColoredBox(color: scheme.shadow.withValues(alpha: 0.45)),
          ),
          DecoratedBox(
            key: const ValueKey<String>('tag-management-merge'),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: RadiusTokens.brXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: SpacingTokens.xs),
                const _MergeTagSheetHandle(),
                _MergeTagSheetTitle(
                  title: l10n.settingsTagsMergeSheetTitle(
                    l10n.tagHashLabel(tag.name),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                _MergeTagSheetHint(message: l10n.settingsTagsMergeSheetHint),
                const SizedBox(height: SpacingTokens.md),
                _MergeTagSheetSearchHint(hint: l10n.settingsTagsSearchHint),
                const SizedBox(height: SpacingTokens.md),
                _MergeTagSheetSectionTitle(
                  label: l10n.settingsTagsMergeSuggestedSectionTitle,
                ),
                const SizedBox(height: SpacingTokens.xs),
                _MergeDestinationList(
                  tags: destinations.take(2).toList(),
                  tag: tag,
                ),
                const SizedBox(height: SpacingTokens.sm),
                _MergeTagSheetSectionTitle(
                  label: l10n.settingsTagsMergeAllTagsSectionTitle,
                ),
                const SizedBox(height: SpacingTokens.xs),
                _MergeDestinationList(
                  tags: destinations.skip(2).toList(),
                  tag: tag,
                ),
                const SizedBox(height: SpacingTokens.sm),
                _MergeTagSheetSummary(
                  summary: l10n.settingsTagsMergeSheetSummary(
                    tag.count,
                    l10n.tagHashLabel(tag.name),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                _MergeTagSheetActions(
                  cancelLabel: MaterialLocalizations.of(
                    context,
                  ).cancelButtonLabel,
                  confirmLabel: l10n.settingsTagsMergeConfirmAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MergeTagSheetHandle extends StatelessWidget {
  const _MergeTagSheetHandle();

  @override
  Widget build(BuildContext context) => Container(
    width: SizeTokens.buttonSm,
    height: SpacingTokens.xs,
    margin: const EdgeInsets.only(bottom: SpacingTokens.md),
    decoration: BoxDecoration(
      color: context.colorScheme.outlineVariant,
      borderRadius: RadiusTokens.brFull,
    ),
  );
}

class _MergeTagSheetTitle extends StatelessWidget {
  const _MergeTagSheetTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: MxText(
      title,
      role: MxTextRole.titleMedium,
      fontWeight: TypographyTokens.bold,
    ),
  );
}

class _MergeTagSheetHint extends StatelessWidget {
  const _MergeTagSheetHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: MxText(
      message,
      role: MxTextRole.bodyMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}

class _MergeTagSheetSearchHint extends StatelessWidget {
  const _MergeTagSheetSearchHint({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: Container(
        height: SizeTokens.avatar,
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
                hint,
                role: MxTextRole.bodyMedium,
                color: scheme.onSurfaceVariant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeTagSheetSectionTitle extends StatelessWidget {
  const _MergeTagSheetSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    child: MxText(
      label,
      role: MxTextRole.labelLarge,
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}

class _MergeTagSheetSummary extends StatelessWidget {
  const _MergeTagSheetSummary({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: RadiusTokens.brMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline,
              size: SizeTokens.iconXs,
              color: scheme.primary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: MxText(
                summary,
                role: MxTextRole.labelMedium,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeTagSheetActions extends StatelessWidget {
  const _MergeTagSheetActions({
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      0,
      SpacingTokens.lg,
      SpacingTokens.lg,
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: MxSecondaryButton(
            label: cancelLabel,
            variant: MxSecondaryVariant.outlined,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: MxPrimaryButton(label: confirmLabel, onPressed: () {}),
        ),
      ],
    ),
  );
}

class _MergeDestinationList extends StatelessWidget {
  const _MergeDestinationList({required this.tags, required this.tag});

  final List<_TagManagementEntry> tags;
  final _TagManagementEntry tag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return Column(
      children: <Widget>[
        for (final _TagManagementEntry destination in tags)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: MxTappable(
              onTap: () {},
              borderRadius: RadiusTokens.brMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      destination.name == tag.name
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: SizeTokens.iconSm,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: MxText(
                        '${l10n.tagHashLabel(destination.name)}  ·  ${l10n.settingsTagsCardCount(destination.count)}',
                        role: MxTextRole.bodyMedium,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
