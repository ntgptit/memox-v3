import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/types/tts_front_language.dart';

void main() {
  group('TtsSettings defaults', () {
    test('match the documented defaults', () {
      const TtsSettings s = TtsSettings();
      expect(s.autoPlay, isFalse);
      expect(s.frontLanguage, TtsFrontLanguage.korean);
      expect(s.rate, TtsSettings.defaultRate);
      expect(s.pitch, TtsSettings.defaultPitch);
      expect(s.volume, TtsSettings.defaultVolume);
      expect(s.frontVoiceName, isNull);
    });
  });

  group('TtsSettings normalization', () {
    test('clamps rate / pitch / volume into range', () {
      expect(TtsSettings.normalizeRate(0.1), TtsSettings.minRate);
      expect(TtsSettings.normalizeRate(0.9), TtsSettings.maxRate);
      expect(TtsSettings.normalizeRate(0.5), 0.5);

      expect(TtsSettings.normalizePitch(0.1), TtsSettings.minPitch);
      expect(TtsSettings.normalizePitch(2.0), TtsSettings.maxPitch);

      expect(TtsSettings.normalizeVolume(-1.0), TtsSettings.minVolume);
      expect(TtsSettings.normalizeVolume(5.0), TtsSettings.maxVolume);
    });

    test('normalized() clamps all sliders', () {
      const TtsSettings corrupt = TtsSettings(rate: 9, pitch: 9, volume: 9);
      final TtsSettings fixed = corrupt.normalized();
      expect(fixed.rate, TtsSettings.maxRate);
      expect(fixed.pitch, TtsSettings.maxPitch);
      expect(fixed.volume, TtsSettings.maxVolume);
    });
  });

  group('TtsSettings.withFrontLanguage', () {
    test('switches language and clears the stored voice', () {
      const TtsSettings s = TtsSettings(
        frontLanguage: TtsFrontLanguage.korean,
        frontVoiceName: 'ko-voice-1',
      );
      final TtsSettings next = s.withFrontLanguage(TtsFrontLanguage.english);
      expect(next.frontLanguage, TtsFrontLanguage.english);
      expect(next.frontVoiceName, isNull);
    });
  });

  group('TtsFrontLanguage.fromStorage', () {
    test('parses known values, falls back to Korean', () {
      expect(TtsFrontLanguage.fromStorage('korean'), TtsFrontLanguage.korean);
      expect(TtsFrontLanguage.fromStorage('english'), TtsFrontLanguage.english);
      expect(TtsFrontLanguage.fromStorage(null), TtsFrontLanguage.korean);
      expect(TtsFrontLanguage.fromStorage('bogus'), TtsFrontLanguage.korean);
    });
  });
}
