/// Identifier typedefs (`docs/contracts/types-catalog.md` §Typedefs).
///
/// All are UUID strings except [TagName], which is the already-normalized
/// (lowercased, trimmed) tag string itself.
library;

typedef FlashcardId = String;
typedef DeckId = String;
typedef FolderId = String;
typedef TagName = String;
typedef SessionId = String;

/// Nullable for `entry_type = today`.
typedef EntryRefId = String?;
