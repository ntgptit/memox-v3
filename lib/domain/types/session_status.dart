/// Lifecycle of a study session
/// (`docs/contracts/types-catalog.md` §SessionStatus,
/// `docs/business/resume/resume-session.md`).
///
/// Storage: `study_sessions.status` TEXT, snake_case. Resumable when status is
/// [draft] or [inProgress] AND `started_at > now - 30 days`.
enum SessionStatus {
  /// Created but no attempts yet.
  draft,

  /// Has at least one attempt, not finalized.
  inProgress,

  /// All planned items answered + finalized.
  completed,

  /// User discarded.
  cancelled,

  /// Items written but summary aggregate failed.
  failedToFinalize,
}
