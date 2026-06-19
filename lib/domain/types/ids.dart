/// Stable id typedefs for domain entities.
///
/// All ids are UUID-like text (generated via `IdGenerator`), per
/// `docs/contracts/types-catalog.md` §Typedefs and
/// `docs/database/schema-contract.md` §Rules. They are plain `String`
/// aliases — the alias documents intent at call sites without runtime cost.
library;

/// Identifier of a [Folder] row (`folders.id`).
typedef FolderId = String;
