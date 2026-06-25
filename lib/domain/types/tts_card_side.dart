/// The side of a flashcard a TTS request targets — the input to
/// `TtsPlaybackPolicy` (WBS 8.4.3, `docs/business/tts/tts-settings.md`
/// §Playback policy). Only [front] is ever spoken; [back]/[note] are
/// user-revealed content and never read aloud.
enum TtsCardSide { front, back, note }
