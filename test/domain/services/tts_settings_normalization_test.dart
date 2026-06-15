import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/types/tts_language_code.dart';

void main() {
  group('TtsSettings normalization', () {
    test('T2: normalizeRate clamps values outside [0.3, 0.7]', () {
      expect(TtsSettings.normalizeRate(0.0), 0.3);
      expect(TtsSettings.normalizeRate(0.5), 0.5);
      expect(TtsSettings.normalizeRate(1.0), 0.7);
      expect(TtsSettings.normalizeRate(0.3), 0.3);
      expect(TtsSettings.normalizeRate(0.7), 0.7);
    });

    test('T3: normalizePitch clamps values outside [0.7, 1.5]', () {
      expect(TtsSettings.normalizePitch(0.0), 0.7);
      expect(TtsSettings.normalizePitch(1.0), 1.0);
      expect(TtsSettings.normalizePitch(2.0), 1.5);
      expect(TtsSettings.normalizePitch(0.7), 0.7);
      expect(TtsSettings.normalizePitch(1.5), 1.5);
    });

    test('T4: normalizeVolume clamps values outside [0.0, 1.0]', () {
      expect(TtsSettings.normalizeVolume(-0.5), 0.0);
      expect(TtsSettings.normalizeVolume(0.5), 0.5);
      expect(TtsSettings.normalizeVolume(1.5), 1.0);
      expect(TtsSettings.normalizeVolume(0.0), 0.0);
      expect(TtsSettings.normalizeVolume(1.0), 1.0);
    });

    test('withLanguage clears frontVoiceName', () {
      final TtsSettings settings = TtsSettings.defaults.withVoice('test-voice');
      expect(settings.frontVoiceName, 'test-voice');
      final TtsSettings changed = settings.withLanguage(TtsLanguageCode.enUS);
      expect(changed.frontLanguage, TtsLanguageCode.enUS);
      expect(changed.frontVoiceName, isNull);
    });

    test('withVoice normalizes empty string to null', () {
      final TtsSettings settings = TtsSettings.defaults.withVoice('');
      expect(settings.frontVoiceName, isNull);
    });

    test('withVoice normalizes whitespace-only string to null', () {
      final TtsSettings settings = TtsSettings.defaults.withVoice('   ');
      expect(settings.frontVoiceName, isNull);
    });

    test('defaults have expected values', () {
      expect(TtsSettings.defaults.autoPlay, false);
      expect(TtsSettings.defaults.frontLanguage, TtsLanguageCode.koKR);
      expect(TtsSettings.defaults.rate, TtsSettings.defaultRate);
      expect(TtsSettings.defaults.pitch, TtsSettings.defaultPitch);
      expect(TtsSettings.defaults.volume, TtsSettings.defaultVolume);
      expect(TtsSettings.defaults.frontVoiceName, isNull);
    });
  });
}
