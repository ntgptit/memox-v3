import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/types/tts_front_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_controller.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_view.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';

import '../../../support/parity_contract.dart';

class _FakeController extends TtsAudioController {
  _FakeController(this._view);
  final TtsAudioView _view;
  @override
  Future<TtsAudioView> build() async => _view;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  testWidgets('23-audio-speech: loaded nodes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsAudioControllerProvider.overrideWith(
            () => _FakeController(
              const TtsAudioView(
                settings: TtsSettings(frontLanguage: TtsFrontLanguage.korean),
                voices: <TtsVoice>[TtsVoice(name: 'Yuna', localeTag: 'ko-KR')],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AudioSpeechSettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expectParityContract('23-audio-speech', <String, Finder>{
      'language row': _node('23-audio-speech/language-row'),
      'voice list': _node('23-audio-speech/voice-list'),
      'preview card': _node('23-audio-speech/preview-card'),
      'preview button': _node('23-audio-speech/preview-button'),
    });
  });
}
