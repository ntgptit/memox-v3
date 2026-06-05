/// What a folder is allowed to contain
/// (`docs/contracts/types-catalog.md` §ContentMode,
/// `docs/business/folder/folder-management.md`).
///
/// Storage: `folders.content_mode` TEXT, lowercase. Serialization lives in the
/// data-layer mapper, not here.
enum ContentMode {
  /// Empty — can still become [subfolders] or [decks] mode.
  unlocked,

  /// Locked to subfolders only.
  subfolders,

  /// Locked to decks only.
  decks,
}
