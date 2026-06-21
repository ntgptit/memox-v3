import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
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
  /// `ValidationFailure`. The `maxSessionItems` cap is applied by
  /// `CreateStudySessionUseCase` (WBS 4.2.4) before the list reaches this method.
  /// A write error maps to a `StorageFailure`.
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    required int now,
  });

  /// Cancels the resumable session [id] by moving its status to `cancelled` (the
  /// session row is never deleted; recorded `study_attempts` are preserved —
  /// `docs/contracts/repository-contracts/study-repository.md` §Forbidden). Only
  /// `draft`/`in_progress` sessions may transition; a missing session is a
  /// `NotFoundFailure`, a terminal session (`completed`/`cancelled`/
  /// `failed_to_finalize`) is an `UnsupportedActionFailure`, and a write error
  /// maps to a `StorageFailure`. Used by the transactional start-over flow
  /// (WBS 4.2.3), which only cancels a resumable session.
  Future<Result<void>> cancelSession({required SessionId id});

  /// Loads the persisted session [id] plus its ordered `study_session_items`
  /// joined with their flashcards, for the review screen (WBS 4.3.1). A missing
  /// session is a `NotFoundFailure`; a session with no items is a controlled
  /// integrity error (`ValidationFailure`) — a persisted session must always
  /// have items (`docs/contracts/usecase-contracts/study.md`
  /// §LoadStudySessionReviewUseCase). A read error maps to a `StorageFailure`.
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId id,
  });

  /// Records one self-grade answer for [sessionItemId] in [sessionId] (WBS
  /// 4.4.1). In one transaction: inserts a `study_attempts` row (with the
  /// computed `box_before` → `box_after` Leitner transition for [result]),
  /// marks the item answered, and touches `study_sessions.updated_at` at [now].
  /// Does **not** update `flashcard_progress` — box changes are
  /// finalization-owned. A missing session/item is a `NotFoundFailure`; a
  /// terminal session or an already-answered item is an `UnsupportedActionFailure`;
  /// a write error maps to a `StorageFailure`.
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    required int now,
  });

  /// The most recent resumable (`draft`/`in_progress`) session for [scope] whose
  /// `updated_at` is within the 30-day [resumeWindow] from [now] (epoch ms), or
  /// `null` when none (WBS 4.2.2). Backs the no-silent-resume gate
  /// (`docs/business/resume/resume-session.md`). A read error maps to a
  /// `StorageFailure`.
  Future<Result<StudySession?>> findResumable({
    required StudyScope scope,
    required int now,
  });

  /// Finalizes the session [sessionId] (WBS 4.6.1/4.6.2/4.6.4): in one
  /// transaction, applies the Leitner SRS outcome (box transition + interval
  /// due-date + counters) to each card's `flashcard_progress` and marks the
  /// session `completed`, stamped at [now] (epoch ms). All `study_session_items`
  /// must be answered first — otherwise a `FinalizationFailure` keeps the session
  /// open. A missing session is a `NotFoundFailure`; a terminal session is an
  /// `UnsupportedActionFailure`; a write error rolls back and maps to a
  /// `StorageFailure`. `flashcard_progress` box changes are owned here, not at
  /// answer time (`docs/contracts/usecase-contracts/study.md`
  /// §FinalizeStudySessionUseCase).
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
    required int now,
  });
}
