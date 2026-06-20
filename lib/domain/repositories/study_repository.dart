import 'package:memox/core/error/result.dart';

/// Study session persistence port (ENABLER skeleton — WBS 4.0.1).
///
/// This is the foundation the study loop builds on; it intentionally exposes
/// only the stale-session retention sweep for now. Session creation, item
/// loading, self-grade recording, finalization, and the SRS box transition land
/// with the study use cases (WBS 4.1.x+) and will grow this port per
/// `docs/contracts/repository-contracts/study-repository.md`.
///
/// Follows the repository `Result<T>` pattern (the `fpdart`/`Either` shape in
/// the contract is the target architecture, not yet adopted — see the contract
/// header). The clock is injected by the caller, matching the other read repos.
abstract interface class StudyRepository {
  /// The resume window: a `draft`/`in_progress` session older than this from
  /// "now" is no longer resumable and is swept to `cancelled`
  /// (`docs/contracts/types-catalog.md` §SessionStatus "Resumable when").
  static const Duration resumeWindow = Duration(days: 30);

  /// Cancels stale resumable sessions: every `draft`/`in_progress` session whose
  /// `updated_at` is older than [resumeWindow] from [now] (epoch ms) becomes
  /// `cancelled`. Returns the number of sessions cancelled. Sessions are never
  /// hard-deleted (`docs/contracts/repository-contracts/study-repository.md`
  /// §Forbidden). Maps a read/write error to a `StorageFailure`.
  Future<Result<int>> expireOldSessions({required int now});
}
