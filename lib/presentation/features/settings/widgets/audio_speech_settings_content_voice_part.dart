part of 'audio_speech_settings_content.dart';

class _AudioSpeechVoiceCard extends StatelessWidget {
  const _AudioSpeechVoiceCard({
    required this.l10n,
    required this.profile,
    required this.engineDisabled,
  });

  final AppLocalizations l10n;
  final _AudioSpeechProfile profile;
  final bool engineDisabled;

  @override
  Widget build(BuildContext context) {
    if (profile.isEmpty) {
      return _AudioSpeechVoiceEmptyState(
        l10n: l10n,
        profile: profile,
      );
    }

    if (profile.isLoading) {
      return _AudioSpeechVoiceLoadingState();
    }

    return _AudioSpeechVoiceLoadedState(
      l10n: l10n,
      profile: profile,
      engineDisabled: engineDisabled,
    );
  }
}

class _AudioSpeechVoiceEmptyState extends StatelessWidget {
  const _AudioSpeechVoiceEmptyState({
    required this.l10n,
    required this.profile,
  });

  final AppLocalizations l10n;
  final _AudioSpeechProfile profile;

  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.xxl,
    ),
    child: Column(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer,
            borderRadius: RadiusTokens.brMd,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.mic_off_outlined,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        MxText(
          l10n.settingsAudioSpeechNoVoicesTitle(profile.languageLabel),
          role: MxTextRole.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.xxs),
        MxText(
          l10n.settingsAudioSpeechNoVoicesBody(profile.languageLabel),
          role: MxTextRole.labelMedium,
          color: context.colorScheme.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxActionButton(
          intent: MxActionIntent.emptyState,
          label: l10n.settingsAudioSpeechOpenSystemSpeech,
          icon: Icons.open_in_new_outlined,
          onPressed: () {},
        ),
      ],
    ),
  );
}

class _AudioSpeechVoiceLoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
    child: Column(
      children: List<Widget>.generate(4, (int index) => _AudioSpeechVoiceSkeletonRow(
          showDivider: index < 3,
          wideTop: index == 0,
        )),
    ),
  );
}

class _AudioSpeechVoiceLoadedState extends StatelessWidget {
  const _AudioSpeechVoiceLoadedState({
    required this.l10n,
    required this.profile,
    required this.engineDisabled,
  });

  final AppLocalizations l10n;
  final _AudioSpeechProfile profile;
  final bool engineDisabled;

  @override
  Widget build(BuildContext context) => Opacity(
      opacity: engineDisabled ? OpacityTokens.fadeOut : 1,
      child: IgnorePointer(
        ignoring: engineDisabled,
        child: MxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int index = 0; index < profile.voices.length; index += 1) ...<Widget>[
                _AudioSpeechVoiceRow(
                  l10n: l10n,
                  voice: profile.voices[index],
                  selected: profile.voices[index].id == profile.selectedVoiceId,
                  showDivider: index < profile.voices.length - 1,
                ),
              ],
              _AudioSpeechSlider(
                label: l10n.settingsAudioSpeechSpeechRateLabel,
                valueLabel: l10n.settingsAudioSpeechRateValueLabel(
                  profile.rate.toStringAsFixed(2),
                ),
                value: profile.rate,
                min: 0.3,
                max: 0.7,
                sublabels: <String>[
                  l10n.settingsAudioSpeechSpeechRateMinLabel,
                  l10n.settingsAudioSpeechSpeechRateDefaultLabel,
                  l10n.settingsAudioSpeechSpeechRateMaxLabel,
                ],
              ),
              _AudioSpeechSlider(
                label: l10n.settingsAudioSpeechPitchLabel,
                valueLabel: profile.pitch.toStringAsFixed(2),
                value: profile.pitch,
                min: 0.7,
                max: 1.5,
                sublabels: <String>[
                  l10n.settingsAudioSpeechPitchMinLabel,
                  l10n.settingsAudioSpeechPitchDefaultLabel,
                  l10n.settingsAudioSpeechPitchMaxLabel,
                ],
              ),
              _AudioSpeechSlider(
                label: l10n.settingsAudioSpeechVolumeLabel,
                valueLabel: l10n.settingsAudioSpeechVolumeValueLabel(
                  (profile.volume * 100).round().toString(),
                ),
                value: profile.volume,
                min: 0,
                max: 1,
                sublabels: <String>[
                  l10n.settingsAudioSpeechVolumeMinLabel,
                  l10n.settingsAudioSpeechVolumeMidLabel,
                  l10n.settingsAudioSpeechVolumeMaxLabel,
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: MxText(
                        l10n.settingsAudioSpeechResetVoiceSettings(
                          profile.languageLabel,
                        ),
                        role: MxTextRole.labelMedium,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    MxSecondaryButton(
                      label: l10n.settingsAudioSpeechResetAction,
                      onPressed: () {},
                      icon: Icons.rotate_left_outlined,
                      variant: MxSecondaryVariant.outlined,
                      size: MxButtonSize.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

class _AudioSpeechVoiceRow extends StatelessWidget {
  const _AudioSpeechVoiceRow({
    required this.l10n,
    required this.voice,
    required this.selected,
    required this.showDivider,
  });

  final AppLocalizations l10n;
  final _AudioSpeechVoice voice;
  final bool selected;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      children: <Widget>[
        MxTappable(
          onTap: () {},
          borderRadius: RadiusTokens.brMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.md,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: selected ? 5 : 2,
                    ),
                    color: scheme.surface.withValues(alpha: 0),
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
                              voice.name,
                              role: MxTextRole.titleSmall,
                              color: selected ? scheme.onSurface : null,
                            ),
                          ),
                          if (voice.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.xs,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.10),
                                borderRadius: RadiusTokens.brFull,
                              ),
                              child: MxText(
                                l10n.settingsAudioSpeechDefaultVoiceBadge,
                                role: MxTextRole.labelSmall,
                                color: scheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.xxs),
                      MxText(
                        voice.meta,
                        role: MxTextRole.labelMedium,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                MxIconButton(
                  icon: Icons.volume_up_outlined,
                  size: MxIconButtonSize.compact,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const _AudioSpeechRowDivider(),
      ],
    );
  }
}

class _AudioSpeechVoiceSkeletonRow extends StatelessWidget {
  const _AudioSpeechVoiceSkeletonRow({
    required this.showDivider,
    required this.wideTop,
  });

  final bool showDivider;
  final bool wideTop;

  @override
  Widget build(BuildContext context) => Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
          child: Row(
            children: <Widget>[
              const MxSkeleton.circle(size: 18),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxSkeleton(width: wideTop ? 116 : 92, height: 11),
                    const SizedBox(height: 6),
                    MxSkeleton(width: wideTop ? 68 : 84, height: 9),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              const MxSkeleton.circle(size: 30),
            ],
          ),
        ),
        if (showDivider) const _AudioSpeechRowDivider(),
      ],
    );
}
