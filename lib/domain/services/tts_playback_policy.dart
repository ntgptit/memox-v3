/// Enforces front-only TTS playback.
/// See `docs/business/tts/tts-settings.md` §Playback policy.
final class TtsPlaybackPolicy {
  const TtsPlaybackPolicy();

  /// Only the front side of a card may be spoken.
  bool canSpeakFlashcardSide(String side) => side == 'front';
}
