/// How a study session was started (`docs/contracts/types-catalog.md` §EntryType,
/// `docs/business/study/study-flow.md` §Entry types).
///
/// `tag` is a Target/Future entry (needs tag-scope queries + a tag picker) and is
/// intentionally NOT part of the current core enum — it lands with the tag-study
/// slice, not study entry eligibility (WBS 4.1.1).
enum EntryType {
  /// Study cards from one deck. `entry_ref_id` = deck id.
  deck,

  /// Study cards from a folder, recursively over its subtree. `entry_ref_id` =
  /// folder id.
  folder,

  /// Study today's due cards across all of the user's data. `entry_ref_id` =
  /// `null`.
  today,
}
