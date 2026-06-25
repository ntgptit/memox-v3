import 'package:memox/domain/types/tts_card_side.dart';

/// The front-only TTS playback policy (WBS 8.4.3,
/// `docs/business/tts/tts-settings.md` §Playback policy).
///
/// TTS is for prompts (the front of a card). The back and the note are
/// user-revealed content and are never spoken. `SpeakFlashcardUseCase` consults
/// this before any `TtsService.speak`; callers MUST NOT bypass it. If a new
/// playable side is ever needed, change the policy here (and the doc) first —
/// do not pass `back`/`note` to the engine directly.
class TtsPlaybackPolicy {
  const TtsPlaybackPolicy();

  /// Whether [side] may be spoken. Only [TtsCardSide.front] returns `true`.
  bool canSpeak(TtsCardSide side) => side == TtsCardSide.front;
}
