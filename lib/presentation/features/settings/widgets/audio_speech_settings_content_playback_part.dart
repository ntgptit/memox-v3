part of 'audio_speech_settings_content.dart';

class _AudioSpeechSlider extends StatelessWidget {
  const _AudioSpeechSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.sublabels,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final List<String> sublabels;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final double progress = ((value - min) / (max - min)).clamp(0, 1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        0,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MxText(label, role: MxTextRole.titleSmall),
                  MxText(
                    valueLabel,
                    role: MxTextRole.titleSmall,
                    color: scheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              SizedBox(
                height: 22,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: RadiusTokens.brFull,
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: RadiusTokens.brFull,
                        ),
                      ),
                    ),
                    Positioned(
                      left: (constraints.maxWidth - 20) * progress,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: RadiusTokens.brFull,
                          border: Border.all(color: scheme.primary, width: 2),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (final String sublabel in sublabels)
                    MxText(
                      sublabel,
                      role: MxTextRole.labelSmall,
                      color: scheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
          ),
      ),
    );
  }
}

class _AudioSpeechPreviewCard extends StatelessWidget {
  const _AudioSpeechPreviewCard({
    required this.l10n,
    required this.profile,
    required this.playing,
    required this.disabled,
  });

  final AppLocalizations l10n;
  final _AudioSpeechProfile profile;
  final bool playing;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Opacity(
      opacity: disabled ? OpacityTokens.fadeOut : 1,
      child: MxCard(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(
              profile.sample,
              role: MxTextRole.titleMedium,
              color: scheme.onSurface,
            ),
            if (profile.sampleHint != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                profile.sampleHint!,
                role: MxTextRole.labelMedium,
                color: scheme.onSurfaceVariant,
              ),
            ],
            const SizedBox(height: SpacingTokens.lg),
            MxTappable(
              onTap: () {},
              borderRadius: RadiusTokens.brLg,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 40),
                decoration: BoxDecoration(
                  color: playing ? context.customColors.mastery : scheme.primary,
                  borderRadius: RadiusTokens.brLg,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (playing) ...<Widget>[
                      const _AudioSpeechVoiceBars(),
                    ] else ...<Widget>[
                      Icon(Icons.play_arrow, color: scheme.onPrimary, size: 16),
                    ],
                    const SizedBox(width: SpacingTokens.sm),
                    Flexible(
                      child: MxText(
                        playing
                            ? l10n.settingsAudioSpeechPlayingLabel
                            : l10n.settingsAudioSpeechPreviewVoiceLabel,
                        role: MxTextRole.labelLarge,
                        color: scheme.onPrimary,
                        textAlign: TextAlign.center,
                      ),
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

class _AudioSpeechVoiceBars extends StatelessWidget {
  const _AudioSpeechVoiceBars();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
      _AudioSpeechBar(height: 6),
      SizedBox(width: SpacingTokens.xxs),
      _AudioSpeechBar(height: 12),
      SizedBox(width: SpacingTokens.xxs),
      _AudioSpeechBar(height: 8),
      SizedBox(width: SpacingTokens.xxs),
      _AudioSpeechBar(height: 14),
    ],
  );
}

class _AudioSpeechBar extends StatelessWidget {
  const _AudioSpeechBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: height,
    decoration: BoxDecoration(
      color: context.colorScheme.onPrimary,
      borderRadius: RadiusTokens.brXs,
    ),
  );
}
