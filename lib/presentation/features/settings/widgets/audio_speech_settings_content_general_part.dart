part of 'audio_speech_settings_content.dart';

class _AudioSpeechGeneralCard extends StatelessWidget {
  const _AudioSpeechGeneralCard({
    required this.l10n,
    required this.disabled,
  });

  final AppLocalizations l10n;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? OpacityTokens.hint : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: MxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              MxSettingsTile.toggle(
                title: l10n.settingsAudioSpeechAutoPlayTitle,
                subtitle: l10n.settingsAudioSpeechAutoPlaySubtitle,
                leadingIcon: Icons.play_arrow_outlined,
                value: false,
                onChanged: (_) {},
              ),
              const _AudioSpeechRowDivider(),
              Opacity(
                opacity: 0.5,
                child: IgnorePointer(
                  child: MxSettingsTile(
                    title: l10n.settingsAudioSpeechPlayAfterGradingTitle,
                    subtitle: l10n.settingsAudioSpeechPlayAfterGradingSubtitle,
                    leadingIcon: Icons.workspace_premium_outlined,
                    onTap: null,
                    trailing: _AudioSpeechSoonChip(
                      label: l10n.settingsSoonChip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioSpeechLanguageTabs extends StatelessWidget {
  const _AudioSpeechLanguageTabs({required this.profile});

  final _AudioSpeechProfile profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      padding: const EdgeInsets.all(SpacingTokens.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _AudioSpeechLanguageTab(
              active: profile.language == _AudioSpeechLanguage.korean,
              label: l10n.settingsAudioSpeechKoreanTabLabel,
              flagLabel: l10n.settingsAudioSpeechKoreanTabFlag,
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: _AudioSpeechLanguageTab(
              active: profile.language == _AudioSpeechLanguage.english,
              label: l10n.settingsAudioSpeechEnglishTabLabel,
              flagLabel: l10n.settingsAudioSpeechEnglishTabFlag,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSpeechLanguageTab extends StatelessWidget {
  const _AudioSpeechLanguageTab({
    required this.active,
    required this.label,
    required this.flagLabel,
  });

  final bool active;
  final String label;
  final String flagLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: () {},
      borderRadius: RadiusTokens.brMd,
      child: AnimatedContainer(
        duration: Durations.short2,
        curve: Curves.easeOut,
        height: 40,
        decoration: BoxDecoration(
          color: active ? scheme.primary : scheme.surfaceContainerLowest,
          borderRadius: RadiusTokens.brMd,
          border: active ? null : Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: active
                    ? scheme.onPrimary.withValues(alpha: 0.18)
                    : scheme.primary.withValues(alpha: 0.10),
                borderRadius: RadiusTokens.brSm,
              ),
              alignment: Alignment.center,
              child: MxText(
                flagLabel,
                role: MxTextRole.labelSmall,
                color: active ? scheme.onPrimary : scheme.primary,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Flexible(
              child: MxText(
                label,
                role: MxTextRole.labelLarge,
                color: active ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
