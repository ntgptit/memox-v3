part of 'audio_speech_settings_content.dart';

class _AudioSpeechBanner extends StatelessWidget {
  const _AudioSpeechBanner({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.06),
        border: Border.all(color: scheme.error.withValues(alpha: 0.22)),
        borderRadius: RadiusTokens.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: SizeTokens.iconSm, color: scheme.error),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(title, role: MxTextRole.titleSmall),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  body,
                  role: MxTextRole.labelMedium,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: SpacingTokens.sm),
                MxActionButton(
                  intent: MxActionIntent.cardPrimary,
                  label: actionLabel,
                  icon: Icons.open_in_new_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSpeechSupportedLanguagesCard extends StatelessWidget {
  const _AudioSpeechSupportedLanguagesCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.05),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
        borderRadius: RadiusTokens.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: SizeTokens.iconSm, color: scheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              l10n.settingsAudioSpeechSupportedLanguagesBody,
              role: MxTextRole.labelMedium,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSpeechFooter extends StatelessWidget {
  const _AudioSpeechFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
    child: Center(
      child: MxText(
        text,
        role: MxTextRole.labelSmall,
        color: context.colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _AudioSpeechSoonChip extends StatelessWidget {
  const _AudioSpeechSoonChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: SizeTokens.iconBadge,
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainer,
      borderRadius: RadiusTokens.brFull,
    ),
    alignment: Alignment.center,
    child: MxText(
      label,
      role: MxTextRole.labelSmall,
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}

class AudioSpeechSavedChip extends StatelessWidget {
  const AudioSpeechSavedChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => _AudioSpeechSavedChip(label: label);
}

class _AudioSpeechSavedChip extends StatelessWidget {
  const _AudioSpeechSavedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.sm,
      vertical: SpacingTokens.xs,
    ),
    decoration: BoxDecoration(
      color: context.customColors.mastery.withValues(alpha: 0.10),
      borderRadius: RadiusTokens.brFull,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.check,
          size: SizeTokens.iconTiny,
          color: context.customColors.mastery,
        ),
        const SizedBox(width: SpacingTokens.xs),
        MxText(
          label,
          role: MxTextRole.labelSmall,
          color: context.customColors.mastery,
        ),
      ],
    ),
  );
}

class _AudioSpeechRowDivider extends StatelessWidget {
  const _AudioSpeechRowDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: SizeTokens.avatar,
      end: SpacingTokens.md,
    ),
    child: Container(
      height: BorderTokens.width,
      color: context.colorScheme.outlineVariant.withValues(
        alpha: OpacityTokens.divider,
      ),
    ),
  );
}
