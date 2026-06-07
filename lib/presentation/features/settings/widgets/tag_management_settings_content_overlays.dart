part of 'tag_management_settings_content.dart';

class _TagContextSheetOverlay extends StatelessWidget {
  const _TagContextSheetOverlay({required this.l10n, required this.tag});

  final AppLocalizations l10n;
  final _TagManagementEntry tag;

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
            key: const ValueKey<String>('tag-management-sheet'),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: RadiusTokens.brXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: SpacingTokens.xs),
                Container(
                  width: SizeTokens.buttonSm,
                  height: SpacingTokens.xs,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: RadiusTokens.brFull,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    SpacingTokens.md,
                    SpacingTokens.lg,
                    SpacingTokens.xs,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _TagManagementPill(
                      label: l10n.tagHashLabel(tag.name),
                      count: tag.count,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    0,
                    SpacingTokens.lg,
                    SpacingTokens.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MxText(
                      l10n.settingsTagsContextSheetTitle,
                      role: MxTextRole.labelSmall,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                _SheetActionRow(
                  icon: Icons.edit_outlined,
                  title: l10n.settingsTagsActionRename,
                ),
                _SheetActionRow(
                  icon: Icons.merge_type,
                  title: l10n.settingsTagsActionMerge,
                ),
                _SheetActionRow(
                  icon: Icons.delete_outline,
                  title: l10n.settingsTagsActionDelete,
                  destructive: true,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    SpacingTokens.sm,
                    SpacingTokens.lg,
                    SpacingTokens.lg,
                  ),
                  child: MxSecondaryButton(
                    label: MaterialLocalizations.of(context).cancelButtonLabel,
                    variant: MxSecondaryVariant.text,
                    fullWidth: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.title,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color iconColor = destructive ? scheme.error : scheme.primary;
    return MxTappable(
      onTap: () {},
      borderRadius: RadiusTokens.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: SizeTokens.iconTile,
              height: SizeTokens.iconTile,
              decoration: BoxDecoration(
                color: destructive
                    ? scheme.error.withValues(alpha: 0.1)
                    : scheme.primary.withValues(alpha: 0.08),
                borderRadius: RadiusTokens.brMd,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: SizeTokens.iconXs, color: iconColor),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: MxText(
                title,
                role: MxTextRole.titleSmall,
                fontWeight: TypographyTokens.semiBold,
                color: destructive ? scheme.error : scheme.onSurface,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: SizeTokens.iconSm,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagManagementPill extends StatelessWidget {
  const _TagManagementPill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: SizeTokens.surfaceBadge,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.sell_outlined, size: SizeTokens.iconTiny, color: scheme.primary),
          const SizedBox(width: SpacingTokens.xs),
          MxText(
            label,
            role: MxTextRole.labelMedium,
            color: scheme.primary,
            fontWeight: TypographyTokens.semiBold,
          ),
          const SizedBox(width: SpacingTokens.xs),
          MxText(
            '· $count',
            role: MxTextRole.labelSmall,
            color: scheme.primary.withValues(alpha: 0.72),
            fontWeight: TypographyTokens.bold,
          ),
        ],
      ),
    );
  }
}

class _DeleteTagDialogOverlay extends StatelessWidget {
  const _DeleteTagDialogOverlay({required this.l10n, required this.tag});

  final AppLocalizations l10n;
  final _TagManagementEntry tag;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Positioned.fill(
      child: ColoredBox(
        color: scheme.shadow.withValues(alpha: 0.45),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Container(
              key: const ValueKey<String>('tag-management-delete'),
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
                      l10n.settingsTagsDeleteTitle,
                      role: MxTextRole.titleLarge,
                      fontWeight: TypographyTokens.bold,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    MxText(
                      l10n.settingsTagsDeleteMessage(
                        l10n.tagHashLabel(tag.name),
                        tag.count,
                      ),
                      role: MxTextRole.bodyMedium,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        MxSecondaryButton(
                          label: MaterialLocalizations.of(
                            context,
                          ).cancelButtonLabel,
                          variant: MxSecondaryVariant.outlined,
                          onPressed: () {},
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        MxPrimaryButton(
                          label: l10n.settingsTagsDeleteConfirm,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TagErrorToast extends StatelessWidget {
  const TagErrorToast({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Positioned(
      left: SpacingTokens.md,
      right: SpacingTokens.md,
      bottom: SpacingTokens.lg,
      child: Container(
        key: const ValueKey<String>('tag-management-op-error'),
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: RadiusTokens.brMd,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.28),
              blurRadius: ShadowTokens.blurPopover,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: SizeTokens.iconSm,
              color: scheme.error,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MxText(
                    l10n.settingsTagsOpErrorTitle,
                    role: MxTextRole.bodyMedium,
                    color: scheme.onErrorContainer,
                    fontWeight: TypographyTokens.bold,
                  ),
                  const SizedBox(height: SpacingTokens.xxs),
                  MxText(
                    l10n.settingsTagsOpErrorBody,
                    role: MxTextRole.labelMedium,
                    color: scheme.onErrorContainer.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            MxSecondaryButton(
              label: l10n.settingsTagsRetry,
              variant: MxSecondaryVariant.text,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
