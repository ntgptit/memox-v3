/// The language of a deck's FRONT field. Drives TTS gating.
///
/// Every deck declares a target language so TTS does not speak content with the
/// wrong voice (`docs/business/deck/deck-management.md` §Target language). See
/// `docs/contracts/types-catalog.md` §TargetLanguage.
///
/// Stored in `decks.target_language` as the lowercase enum name. Default
/// [korean].
enum TargetLanguage {
  /// Korean (ko-KR) front content. TTS supported.
  korean,

  /// English (en-US) front content. TTS supported.
  english,

  /// Any other language. TTS disabled for this deck.
  unsupported,
}
