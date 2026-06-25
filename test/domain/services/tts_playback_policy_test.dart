import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/services/tts_playback_policy.dart';
import 'package:memox/domain/types/tts_card_side.dart';

void main() {
  // The front-only TTS policy (WBS 8.4.3) — only the front of a card is ever
  // spoken (docs/business/tts/tts-settings.md §Playback policy).
  group('TtsPlaybackPolicy', () {
    const TtsPlaybackPolicy policy = TtsPlaybackPolicy();

    test('front can be spoken', () {
      expect(policy.canSpeak(TtsCardSide.front), isTrue);
    });

    test('back is never spoken', () {
      expect(policy.canSpeak(TtsCardSide.back), isFalse);
    });

    test('note is never spoken', () {
      expect(policy.canSpeak(TtsCardSide.note), isFalse);
    });
  });
}
