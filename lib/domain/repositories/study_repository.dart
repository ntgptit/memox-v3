import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

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

  /// Atomically creates a new session for [scope] with one ordered
  /// `study_session_items` row per id in [flashcardIds] (queue order preserved),
  /// stamped at [now] (epoch ms). V1 persists the session directly as
  /// `in_progress` (`docs/business/study/study-flow.md` §Session lifecycle).
  /// Returns the created [StudySession]. [flashcardIds] must be non-empty — the
  /// empty-scope gate (WBS 4.1.1) runs first; an empty list is a
  /// `ValidationFailure`. The `maxSessionItems` cap is applied by the caller
  /// (WBS 4.2.4). A write error maps to a `StorageFailure`.
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    required int now,
  });
}
