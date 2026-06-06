import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

class MxFolderFormCreateHeader extends StatelessWidget {
  const MxFolderFormCreateHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MxIconTile(icon: icon, color: color, size: 44),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxText(
                title,
                role: MxTextRole.titleMedium,
                fontWeight: FontWeight.w700,
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

class MxFolderFormRenameHeader extends StatelessWidget {
  const MxFolderFormRenameHeader({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxText(
          title,
          role: MxTextRole.titleMedium,
          fontWeight: FontWeight.w700,
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

class MxFolderFormSectionLabel extends StatelessWidget {
  const MxFolderFormSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => MxText(
    StringUtils.uppercased(label),
    role: MxTextRole.labelMedium,
    color: context.colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.w700,
  );
}

class MxFolderFormColorSwatch extends StatelessWidget {
  const MxFolderFormColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.surfaceColor,
    super.key,
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: surfaceColor,
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                  BoxShadow(color: color, blurRadius: 0, spreadRadius: 4),
                ]
              : null,
          border: selected ? Border.all(color: surfaceColor, width: 2) : null,
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : null,
      ),
    ),
  );
}

class MxFolderFormIconChoiceTile extends StatelessWidget {
  const MxFolderFormIconChoiceTile({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.scheme,
    super.key,
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
        width: 38,
        height: 38,
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
          size: SizeTokens.iconSm - 3,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
