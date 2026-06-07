part of 'audio_speech_settings_content.dart';

enum _AudioSpeechLanguage { korean, english }

class _AudioSpeechProfile {
  const _AudioSpeechProfile({
    required this.language,
    required this.languageLabel,
    required this.sample,
    required this.sampleHint,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.selectedVoiceId,
    required this.voices,
    this.isLoading = false,
    this.isEmpty = false,
  });

  factory _AudioSpeechProfile.forState(
    AudioSpeechSettingsState state,
    AppLocalizations l10n,
  ) {
    final _AudioSpeechProfile base = state == AudioSpeechSettingsState.english
        ? _AudioSpeechProfile(
            language: _AudioSpeechLanguage.english,
            languageLabel: l10n.settingsAudioSpeechEnglishLanguageLabel,
            sample: l10n.settingsAudioSpeechEnglishSampleText,
            sampleHint: null,
            rate: 0.55,
            pitch: 1.0,
            volume: 0.9,
            selectedVoiceId: 'e-emma',
            voices: <_AudioSpeechVoice>[
              _AudioSpeechVoice(
                id: 'sys',
                name: l10n.settingsAudioSpeechEnglishSystemVoiceName,
                meta: l10n.settingsAudioSpeechEnglishSystemVoiceMeta,
                isDefault: true,
              ),
              _AudioSpeechVoice(
                id: 'e-emma',
                name: l10n.settingsAudioSpeechEnglishEmmaVoiceName,
                meta: l10n.settingsAudioSpeechEnglishEmmaVoiceMeta,
              ),
              _AudioSpeechVoice(
                id: 'e-ryan',
                name: l10n.settingsAudioSpeechEnglishRyanVoiceName,
                meta: l10n.settingsAudioSpeechEnglishRyanVoiceMeta,
              ),
            ],
          )
        : _AudioSpeechProfile(
            language: _AudioSpeechLanguage.korean,
            languageLabel: l10n.settingsAudioSpeechKoreanLanguageLabel,
            sample: l10n.settingsAudioSpeechKoreanSampleText,
            sampleHint: l10n.settingsAudioSpeechKoreanSampleHint,
            rate: 0.5,
            pitch: 1.0,
            volume: 0.85,
            selectedVoiceId: 'k-suji',
            voices: <_AudioSpeechVoice>[
              _AudioSpeechVoice(
                id: 'sys',
                name: l10n.settingsAudioSpeechKoreanSystemVoiceName,
                meta: l10n.settingsAudioSpeechKoreanSystemVoiceMeta,
                isDefault: true,
              ),
              _AudioSpeechVoice(
                id: 'k-suji',
                name: l10n.settingsAudioSpeechKoreanSujiVoiceName,
                meta: l10n.settingsAudioSpeechKoreanSujiVoiceMeta,
              ),
              _AudioSpeechVoice(
                id: 'k-minho',
                name: l10n.settingsAudioSpeechKoreanMinhoVoiceName,
                meta: l10n.settingsAudioSpeechKoreanMinhoVoiceMeta,
              ),
              _AudioSpeechVoice(
                id: 'k-eun',
                name: l10n.settingsAudioSpeechKoreanEunhaVoiceName,
                meta: l10n.settingsAudioSpeechKoreanEunhaVoiceMeta,
              ),
            ],
          );

    if (state == AudioSpeechSettingsState.loading) {
      return base.copyWith(isLoading: true);
    }
    if (state == AudioSpeechSettingsState.empty) {
      return base.copyWith(isEmpty: true);
    }
    return base;
  }

  final _AudioSpeechLanguage language;
  final String languageLabel;
  final String sample;
  final String? sampleHint;
  final double rate;
  final double pitch;
  final double volume;
  final String selectedVoiceId;
  final List<_AudioSpeechVoice> voices;
  final bool isLoading;
  final bool isEmpty;

  _AudioSpeechProfile copyWith({
    bool? isLoading,
    bool? isEmpty,
  }) => _AudioSpeechProfile(
    language: language,
    languageLabel: languageLabel,
    sample: sample,
    sampleHint: sampleHint,
    rate: rate,
    pitch: pitch,
    volume: volume,
    selectedVoiceId: selectedVoiceId,
    voices: isEmpty == true ? <_AudioSpeechVoice>[] : voices,
    isLoading: isLoading ?? this.isLoading,
    isEmpty: isEmpty ?? this.isEmpty,
  );
}

class _AudioSpeechVoice {
  const _AudioSpeechVoice({
    required this.id,
    required this.name,
    required this.meta,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String meta;
  final bool isDefault;
}
