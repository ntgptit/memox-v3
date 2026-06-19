/// How Library / Folder-detail / deck content rows are ordered.
///
/// V1 only consumes [manual] for the flashcard list (the deck's
/// user-controlled `sort_order`). The other modes are reserved for the Future
/// sort control — see `docs/contracts/types-catalog.md` §ContentSortMode and
/// `docs/wireframes/02-library.md` §Sort options.
///
/// The enum is never persisted on a row; the user's sort preference persists in
/// SharedPreferences (key `library.sort`).
enum ContentSortMode {
  /// User-controlled order via `sort_order` (default).
  manual,

  /// Name A→Z.
  name,

  /// Most recently created first.
  newest,

  /// Most recently studied subtree first.
  lastStudied,
}
