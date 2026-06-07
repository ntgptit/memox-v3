import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

class LearningTagsCard extends StatelessWidget {
  const LearningTagsCard({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => LearningNavigationRow(
    rowKey: const ValueKey<String>('learning-tags-row'),
    leadingIcon: Icons.sell_outlined,
    title: l10n.settingsManageTagsTitle,
    subtitle: l10n.settingsLearningTagsSubtitle(14),
    enabled: true,
    onTap: () => context.pushSettingsLearningTags(),
  );
}

class LearningStudyDefaultsCard extends StatelessWidget {
  const LearningStudyDefaultsCard({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      LearningFutureRow(
        leadingIcon: Icons.shuffle_outlined,
        title: l10n.settingsLearningFutureDefaultShuffleTitle,
        subtitle: l10n.settingsLearningFutureDefaultShuffleSubtitle,
      ),
      const LearningRowDivider(),
      LearningFutureRow(
        leadingIcon: Icons.layers_outlined,
        title: l10n.settingsLearningFutureDefaultStudyModeTitle,
        subtitle: l10n.settingsLearningFutureDefaultStudyModeSubtitle,
      ),
      const LearningRowDivider(),
      LearningFutureRow(
        leadingIcon: Icons.visibility_outlined,
        title: l10n.settingsLearningFutureExampleSentenceTitle,
        subtitle: l10n.settingsLearningFutureExampleSentenceSubtitle,
      ),
    ],
  );
}

class LearningNavigationRow extends StatelessWidget {
  const LearningNavigationRow({
    required this.title,
    required this.enabled,
    required this.onTap,
    this.rowKey,
    this.subtitle,
    this.value,
    this.leadingIcon,
    super.key,
  });

  final Key? rowKey;
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: MxTappable(
        key: rowKey,
        onTap: enabled ? onTap : null,
        borderRadius: RadiusTokens.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: SizeTokens.iconTile,
                  height: SizeTokens.iconTile,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: RadiusTokens.brMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: SizeTokens.iconXs, color: scheme.primary),
                ),
                const SizedBox(width: SpacingTokens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      title,
                      role: MxTextRole.titleSmall,
                      color: scheme.onSurface,
                      fontWeight: TypographyTokens.semiBold,
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: SpacingTokens.xxs),
                      MxText(
                        subtitle!,
                        role: MxTextRole.labelMedium,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              if (value != null) ...<Widget>[
                MxText(
                  value!,
                  role: MxTextRole.labelLarge,
                  color: scheme.onSurfaceVariant,
                  fontWeight: TypographyTokens.semiBold,
                ),
                const SizedBox(width: SpacingTokens.xs),
              ],
              Icon(
                Icons.chevron_right,
                size: SizeTokens.iconMinor,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningFutureRow extends StatelessWidget {
  const LearningFutureRow({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => LearningSettingsRow(
    leadingIcon: leadingIcon,
    title: title,
    subtitle: subtitle,
    trailing: const LearningSoonChip(),
    enabled: false,
  );
}

class LearningToggleRow extends StatelessWidget {
  const LearningToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
    super.key,
  });

  final IconData? leadingIcon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: MxTappable(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: RadiusTokens.brLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
          child: Row(
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Container(
                  width: SizeTokens.iconTile,
                  height: SizeTokens.iconTile,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: RadiusTokens.brMd,
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: SizeTokens.iconXs, color: scheme.primary),
                ),
                const SizedBox(width: SpacingTokens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      title,
                      role: MxTextRole.titleSmall,
                      color: scheme.onSurface,
                      fontWeight: TypographyTokens.semiBold,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      subtitle,
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              LearningSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningSettingsRow extends StatelessWidget {
  const LearningSettingsRow({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.enabled,
    super.key,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: SizeTokens.iconTile,
              height: SizeTokens.iconTile,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: RadiusTokens.brMd,
              ),
              alignment: Alignment.center,
              child: Icon(leadingIcon, size: SizeTokens.iconXs, color: scheme.primary),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    title,
                    role: MxTextRole.titleSmall,
                    color: scheme.onSurface,
                    fontWeight: TypographyTokens.semiBold,
                  ),
                  const SizedBox(height: SpacingTokens.xxs),
                  MxText(
                    subtitle,
                    role: MxTextRole.labelMedium,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            trailing,
          ],
        ),
      ),
    );
  }
}

class LearningSwitch extends StatelessWidget {
  const LearningSwitch({required this.value, super.key});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Semantics(
      toggled: value,
      child: Container(
      width: SizeTokens.avatar,
      height: SizeTokens.surfaceBadge,
        decoration: BoxDecoration(
          color: value ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: RadiusTokens.brFull,
        ),
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: DurationTokens.fast,
              curve: EasingTokens.standard,
              left: value ? 21 : 3,
              top: 3,
              child: Container(
                width: SizeTokens.iconSm,
                height: SizeTokens.iconSm,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: RadiusTokens.brFull,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.18),
                      blurRadius: ShadowTokens.blurTiny,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningSoonChip extends StatelessWidget {
  const LearningSoonChip({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: SizeTokens.iconBadge,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: RadiusTokens.brFull,
      ),
      child: Center(
        child: MxText(
          AppLocalizations.of(context).settingsSoonChip,
          role: MxTextRole.labelSmall,
          color: scheme.onSurfaceVariant,
          fontWeight: TypographyTokens.bold,
        ),
      ),
    );
  }
}

class LearningSavedChip extends StatelessWidget {
  const LearningSavedChip({
    required this.label,
    required this.visible,
    super.key,
  });

  final String label;
  final bool visible;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: visible ? 1 : 0,
    child: IgnorePointer(
      ignoring: !visible,
      child: Container(
        height: SizeTokens.iconBadge,
        margin: const EdgeInsets.only(right: SpacingTokens.xs),
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: context.customColors.mastery.withValues(alpha: 0.10),
          borderRadius: RadiusTokens.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.check, size: SizeTokens.iconTiny, color: context.customColors.mastery),
            const SizedBox(width: SpacingTokens.xxs),
            MxText(
              label,
              role: MxTextRole.labelSmall,
              color: context.customColors.mastery,
              fontWeight: TypographyTokens.semiBold,
            ),
          ],
        ),
      ),
    ),
  );
}

class LearningRowDivider extends StatelessWidget {
  const LearningRowDivider({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colorScheme.outlineVariant.withValues(
      alpha: OpacityTokens.divider,
    ),
    child: const SizedBox(height: SpacingTokens.xxs, width: double.infinity),
  );
}
