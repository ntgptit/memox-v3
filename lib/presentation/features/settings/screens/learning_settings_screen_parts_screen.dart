part of 'learning_settings_screen.dart';

class _LearningTagsCard extends StatelessWidget {
  const _LearningTagsCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => _LearningNavigationRow(
    key: const ValueKey<String>('learning-tags-row'),
    leadingIcon: Icons.sell_outlined,
    title: l10n.settingsManageTagsTitle,
    subtitle: l10n.settingsLearningTagsSubtitle(14),
    enabled: true,
    onTap: () => context.pushSettingsLearningTags(),
  );
}

class _LearningStudyDefaultsCard extends StatelessWidget {
  const _LearningStudyDefaultsCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _LearningFutureRow(
        leadingIcon: Icons.shuffle_outlined,
        title: l10n.settingsLearningFutureDefaultShuffleTitle,
        subtitle: l10n.settingsLearningFutureDefaultShuffleSubtitle,
      ),
      const _LearningRowDivider(),
      _LearningFutureRow(
        leadingIcon: Icons.layers_outlined,
        title: l10n.settingsLearningFutureDefaultStudyModeTitle,
        subtitle: l10n.settingsLearningFutureDefaultStudyModeSubtitle,
      ),
      const _LearningRowDivider(),
      _LearningFutureRow(
        leadingIcon: Icons.visibility_outlined,
        title: l10n.settingsLearningFutureExampleSentenceTitle,
        subtitle: l10n.settingsLearningFutureExampleSentenceSubtitle,
      ),
    ],
  );
}

class _LearningFutureRow extends StatelessWidget {
  const _LearningFutureRow({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => _LearningSettingsRow(
    leadingIcon: leadingIcon,
    title: title,
    subtitle: subtitle,
    trailing: const _LearningSoonChip(),
    enabled: false,
  );
}

class _LearningSettingsRow extends StatelessWidget {
  const _LearningSettingsRow({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.enabled,
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
          vertical: 13,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: RadiusTokens.brMd,
              ),
              alignment: Alignment.center,
              child: Icon(leadingIcon, size: 15, color: scheme.primary),
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
                  const SizedBox(height: 2),
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

class _LearningSoonChip extends StatelessWidget {
  const _LearningSoonChip();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      height: 22,
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

class _LearningSavedChip extends StatelessWidget {
  const _LearningSavedChip({required this.label, required this.visible});

  final String label;
  bool visib=> Opacity(
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          height: 22,
          margin: const EdgeInsets.only(right: SpacingTokens.xs),
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
          decoration: BoxDecoration(
            color: context.customColors.mastery.withValues(alpha: 0.10),
            borderRadius: RadiusTokens.brFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check, size: 11, color: context.customColors.mastery),
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
    );        ],
          ),
        ),
      ),
    );
  }
}

class _LearningRowDivider extends StatelessWidget {
  const _LearningRowDivider();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colorScheme.outlineVariant.withValues(
      alpha: OpacityTokens.divider,
    ),
    child: const SizedBox(height: 1, width: double.infinity),
  );
}

const int _dailyGoalValue = 20;
const int _goalMin = 5;
const int _goalMax = 200;
