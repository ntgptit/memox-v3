import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_settings_tile.dart';

part 'audio_speech_settings_content_general_part.dart';
part 'audio_speech_settings_content_misc_part.dart';
part 'audio_speech_settings_content_playback_part.dart';
part 'audio_speech_settings_content_profile_part.dart';
part 'audio_speech_settings_content_voice_part.dart';

/// Audio & speech mock/gallery state variants.
enum AudioSpeechSettingsState {
  loaded,
  english,
  loading,
  empty,
  engineErr,
  playing,
  saving,
}

class AudioSpeechSettingsContent extends StatelessWidget {
  const AudioSpeechSettingsContent({required this.state, super.key});

  final AudioSpeechSettingsState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final _AudioSpeechProfile profile = _AudioSpeechProfile.forState(
      state,
      l10n,
    );
    return ListView(
      children: <Widget>[
        if (state == AudioSpeechSettingsState.engineErr) ...<Widget>[
          _AudioSpeechBanner(
            icon: Icons.error_outline,
            title: l10n.settingsAudioSpeechEngineUnavailableTitle,
            body: l10n.settingsAudioSpeechEngineUnavailableBody,
            actionLabel: l10n.settingsAudioSpeechOpenSystemSettings,
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        _AudioSpeechSection(
          title: l10n.settingsAudioSpeechGeneralSectionTitle,
          child: _AudioSpeechGeneralCard(
            l10n: l10n,
            disabled: state == AudioSpeechSettingsState.engineErr,
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        _AudioSpeechSection(
          title: l10n.settingsAudioSpeechLanguageSectionTitle,
          child: _AudioSpeechLanguageTabs(profile: profile),
        ),
        const SizedBox(height: SpacingTokens.lg),
        _AudioSpeechSection(
          title: l10n.settingsAudioSpeechVoiceSectionTitle(
            profile.languageLabel,
          ),
          child: _AudioSpeechVoiceCard(
            l10n: l10n,
            profile: profile,
            engineDisabled: state == AudioSpeechSettingsState.engineErr,
          ),
        ),
        if (!profile.isLoading && !profile.isEmpty) ...<Widget>[
          const SizedBox(height: SpacingTokens.lg),
          _AudioSpeechSection(
            title: l10n.settingsAudioSpeechPreviewSectionTitle,
            hint: l10n.settingsAudioSpeechPreviewHint,
            child: _AudioSpeechPreviewCard(
              l10n: l10n,
              profile: profile,
              playing: state == AudioSpeechSettingsState.playing,
              disabled: state == AudioSpeechSettingsState.engineErr,
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        _AudioSpeechSection(
          title: l10n.settingsAudioSpeechSupportedLanguagesTitle,
          child: _AudioSpeechSupportedLanguagesCard(l10n: l10n),
        ),
        const SizedBox(height: SpacingTokens.xs),
        _AudioSpeechFooter(text: l10n.settingsAudioSpeechChangesSavedText),
      ],
    );
  }
}

class _AudioSpeechSection extends StatelessWidget {
  const _AudioSpeechSection({
    required this.title,
    required this.child,
    this.hint,
  });

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      MxSectionHeader(label: title),
      if (hint != null) ...<Widget>[
        const SizedBox(height: SpacingTokens.xxs),
        MxText(
          hint!,
          role: MxTextRole.labelMedium,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
      const SizedBox(height: SpacingTokens.xs),
      child,
    ],
  );
}
