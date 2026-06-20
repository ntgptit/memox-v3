/// Lifecycle of a study session (`docs/contracts/types-catalog.md` §SessionStatus,
/// `docs/business/study/study-flow.md` §Session lifecycle).
///
/// V1 persists a new session directly as [inProgress] (not [draft]); [draft] is
/// kept in the enum and treated as resumable if encountered.
/// [failedToFinalize] exists but is never written in V1 (a failed finalize rolls
/// back and the session stays [inProgress]).
enum SessionStatus {
  /// Created but no attempts yet (not written by V1 create; resumable if seen).
  draft,

  /// Has at least one attempt / is the active session, not finalized.
  inProgress,

  /// All planned items answered + finalized.
  completed,

  /// User discarded, or auto-expired by the retention sweep.
  cancelled,

  /// Items written but the summary aggregate failed (never written in V1).
  failedToFinalize,
}
