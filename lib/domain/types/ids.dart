/// Stable id typedefs for domain entities.
///
/// All ids are UUID-like text (generated via `IdGenerator`), per
/// `docs/contracts/types-catalog.md` §Typedefs and
/// `docs/database/schema-contract.md` §Rules. They are plain `String`
/// aliases — the alias documents intent at call sites without runtime cost.
library;

/// Identifier of a [Folder] row (`folders.id`).
typedef FolderId = String;

/// Identifier of a [Deck] row (`decks.id`).
typedef DeckId = String;

/// Identifier of a flashcard row (`flashcards.id`).
typedef FlashcardId = String;

/// A normalized tag name (lowercased, trimmed) stored in `flashcard_tags.tag`.
///
/// Unlike the other ids this is the value itself, not a UUID
/// (`docs/contracts/types-catalog.md` §FlashcardId, DeckId, FolderId, TagName).
typedef TagName = String;
