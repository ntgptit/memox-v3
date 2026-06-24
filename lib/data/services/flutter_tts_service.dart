import 'package:flutter_tts/flutter_tts.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/tts_language_code.dart';

/// `flutter_tts`-backed [TtsService] — the platform speech-engine adapter.
///
/// Not headless-testable (no engine on the test host); covered by a faked
/// `TtsService` in widget/controller tests. The engine's voice maps are
/// untyped, so [availableVoices] defensively reads `name`/`locale` and filters
/// by language prefix.
class FlutterTtsService implements TtsService {
  FlutterTtsService(this._tts);

  final FlutterTts _tts;

  @override
  Future<void> init() async {
    await _tts.awaitSpeakCompletion(true);
  }

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguageCode language) async {
    final Object? raw = await _tts.getVoices;
    final String prefix = language.localeTag.split('-').first.toLowerCase();
    final List<TtsVoice> voices = <TtsVoice>[];
    if (raw is List) {
      for (final Object? item in raw) {
        if (item is Map) {
          final Map<String, Object?> v = Map<String, Object?>.from(item);
          final Object? name = v['name'];
          final Object? locale = v['locale'];
          if (name is String &&
              locale is String &&
              locale.toLowerCase().startsWith(prefix)) {
            voices.add(TtsVoice(name: name, localeTag: locale));
          }
        }
      }
    }
    return voices;
  }

  @override
  Future<void> applySettings(TtsSettings settings) async {
    final TtsLanguageCode language = settings.frontLanguage.languageCode;
    await _tts.setLanguage(language.localeTag);
    await _tts.setSpeechRate(settings.rate);
    await _tts.setPitch(settings.pitch);
    await _tts.setVolume(settings.volume);
    final String? voiceName = settings.frontVoiceName;
    if (voiceName != null) {
      await _tts.setVoice(<String, String>{
        'name': voiceName,
        'locale': language.localeTag,
      });
    }
  }

  @override
  Future<void> speak(String text, {required TtsLanguageCode language}) async {
    await _tts.setLanguage(language.localeTag);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
