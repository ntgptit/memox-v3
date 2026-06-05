/// The language of a deck's front field; drives TTS gating
/// (`docs/contracts/types-catalog.md` §TargetLanguage,
/// `docs/business/deck/deck-management.md`).
///
/// Storage: `decks.target_language` TEXT, lowercase, default `'korean'`. Only
/// [korean] and [english] enable the TTS UI in study modes.
enum TargetLanguage {
  korean,
  english,

  /// TTS disabled for this deck.
  unsupported,
}
