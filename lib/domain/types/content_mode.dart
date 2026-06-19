/// What a folder is allowed to contain.
///
/// A folder holds either subfolders or decks, never both. The mode is the
/// enforced lock that protects that invariant — see
/// `docs/business/folder/folder-management.md` §Content mode and
/// `docs/contracts/types-catalog.md` §ContentMode.
///
/// Stored in `folders.content_mode` as the lowercase enum name.
enum ContentMode {
  /// Empty / not yet locked. Can become [subfolders] or [decks].
  unlocked,

  /// Locked to subfolders only.
  subfolders,

  /// Locked to decks only.
  decks,
}
