part of 'mx_folder_form_dialog.dart';

class _MxFolderFormCreateHeader extends StatelessWidget {
  const _MxFolderFormCreateHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.lg,
      SpacingTokens.lg,
      SpacingTokens.tight,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MxIconTile(icon: icon, color: color, size: SizeTokens.avatar),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxText(
                title,
                role: MxTextRole.titleMedium,
                fontWeight: TypographyTokens.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                description,
                role: MxTextRole.labelSmall,
                color: context.colorScheme.onSurfaceVariant,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MxFolderFormRenameHeader extends StatelessWidget {
  const _MxFolderFormRenameHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.lg,
      SpacingTokens.lg,
      SpacingTokens.tight,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxText(
          title,
          role: MxTextRole.titleMedium,
          fontWeight: TypographyTokens.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: SpacingTokens.xs),
        MxText(
          description,
          role: MxTextRole.labelSmall,
          color: context.colorScheme.onSurfaceVariant,
          maxLines: 2,
        ),
      ],
    ),
  );
}

class _MxFolderFormSectionLabel extends StatelessWidget {
  const _MxFolderFormSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => MxText(
    StringUtils.uppercased(label),
    role: MxTextRole.labelMedium,
    color: context.colorScheme.onSurfaceVariant,
    fontWeight: TypographyTokens.bold,
  );
}

class _MxFolderFormColorSwatch extends StatelessWidget {
  const _MxFolderFormColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.surfaceColor,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: MxTappable(
      onTap: onTap,
      borderRadius: RadiusTokens.brFull,
      child: Container(
        width: SizeTokens.surfaceBadgeSm,
        height: SizeTokens.surfaceBadgeSm,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: surfaceColor,
                    blurRadius: 0,
                    spreadRadius: ShadowTokens.spreadHalo,
                  ),
                  BoxShadow(
                    color: color,
                    blurRadius: 0,
                    spreadRadius: ShadowTokens.spreadOutline,
                  ),
                ]
              : null,
          border: selected
              ? Border.all(color: surfaceColor, width: BorderTokens.focusWidth)
              : null,
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: SizeTokens.iconXs,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : null,
      ),
    ),
  );
}

class _MxFolderFormIconChoiceTile extends StatelessWidget {
  const _MxFolderFormIconChoiceTile({
    super.key,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.scheme,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: MxTappable(
      onTap: onTap,
      borderRadius: RadiusTokens.brMd,
      child: Container(
        width: SizeTokens.surfaceTileSm,
        height: SizeTokens.surfaceTileSm,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: OpacityTokens.focus)
              : scheme.surfaceContainerLowest,
          borderRadius: RadiusTokens.brMd,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: SizeTokens.iconXs,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
