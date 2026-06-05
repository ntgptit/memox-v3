/// How a study session was started
/// (`docs/contracts/types-catalog.md` §EntryType,
/// `docs/business/study/study-flow.md`).
///
/// Current core entries are [deck], [folder], and [today]. A `tag` entry is a
/// Target/Future Proposal and is intentionally absent until the tag-study
/// query + storage migration lands.
enum EntryType {
  /// `entry_ref_id` = deck id.
  deck,

  /// `entry_ref_id` = folder id (recursive).
  folder,

  /// `entry_ref_id` = null (global "today").
  today,
}
