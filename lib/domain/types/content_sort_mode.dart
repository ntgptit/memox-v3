/// How Library / Folder content rows are ordered
/// (`docs/wireframes/02-library.md` §Sort options).
///
/// Persisted per user in SharedPreferences (key `library.sort`). Sort lives in
/// the repository/use-case layer; V1 renders no sort UI control.
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
