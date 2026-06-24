import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/audio_speech_settings_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Audio & speech settings (kit screen 23): the TTS voice/language picker +
/// sample preview + speed/pitch tuning, over the persisted `TtsSettings` and the
/// `flutter_tts` engine. A top-level immersive route (`/settings/audio-speech`,
/// shell hidden), reached from the Settings hub. The body owns the data watch;
/// the shell stays watch-free. WBS 8.4.2.
class AudioSpeechSettingsScreen extends StatelessWidget {
  const AudioSpeechSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(title: l10n.audioSpeechTitle),
      useShell: false,
      body: const AudioSpeechSettingsBody(),
    );
  }
}
