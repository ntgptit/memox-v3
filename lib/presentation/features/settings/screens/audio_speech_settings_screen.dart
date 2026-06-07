import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/audio_speech_settings_content.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

export 'package:memox/presentation/features/settings/widgets/audio_speech_settings_content.dart'
    show AudioSpeechSettingsState;

/// Audio & speech settings screen.
///
/// The screen renders the mobile UI kit mock as a static preview with state
/// variants for Korean, English, loading, empty, engine error, playing, and
/// saving.
class AudioSpeechSettingsScreen extends StatelessWidget {
  const AudioSpeechSettingsScreen({
    this.state = AudioSpeechSettingsState.loaded,
    super.key,
  });

  final AudioSpeechSettingsState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.settingsAudioSpeechTitle,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        actions: <Widget>[
          AnimatedOpacity(
            opacity: state == AudioSpeechSettingsState.saving ? 1 : 0,
            duration: Durations.short2,
            child: AudioSpeechSavedChip(label: l10n.settingsAudioSpeechSaved),
          ),
        ],
      ),
      body: AudioSpeechSettingsContent(state: state),
    );
  }
}
