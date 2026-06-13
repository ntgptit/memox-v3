import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Card History header read model: card preview, current SRS state, and
/// cumulative lifetime counters (`docs/business/history/card-history.md`).
///
/// Lifetime counters stay cumulative across progress resets — [lastResetAt]
/// drives the "Includes attempts before last reset" sub-label, not a counter
/// reset. Accuracy is derived from the stored counters, never by scanning
/// attempts.
class CardHistoryHeader {
  const CardHistoryHeader({
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.boxNumber,
    required this.dueAt,
    required this.buriedUntil,
    required this.isSuspended,
    required this.reviewCount,
    required this.lapseCount,
    required this.lastResetAt,
  });

  final String flashcardId;
  final String front;
  final String back;

  /// Leitner box 1..8 (1 for a never-studied card).
  final int boxNumber;
  final DateTime? dueAt;
  final DateTime? buriedUntil;
  final bool isSuspended;
  final int reviewCount;
  final int lapseCount;
  final DateTime? lastResetAt;

  bool get hasReviews => reviewCount > 0;

  /// Lifetime accuracy in `0.0..1.0`, or `null` when there are no reviews.
  /// `(reviewCount - lapseCount) / reviewCount`.
  double? get accuracy =>
      reviewCount > 0 ? (reviewCount - lapseCount) / reviewCount : null;
}

/// One attempt row in the timeline.
class CardHistoryAttempt {
  const CardHistoryAttempt({
    required this.id,
    required this.result,
    required this.studyMode,
    required this.boxBefore,
    required this.boxAfter,
    required this.attemptedAt,
    required this.sessionId,
    required this.sessionStatus,
  });

  final String id;
  final AttemptResult result;
  final StudyMode studyMode;

  /// Leitner box before/after this attempt. `0` marks a pre-migration row; the
  /// UI renders `—` instead of "Box 0".
  final int boxBefore;
  final int boxAfter;
  final DateTime attemptedAt;
  final String sessionId;
  final SessionStatus sessionStatus;

  /// Whether tapping this row may open its session result screen.
  bool get isSessionCompleted => sessionStatus == SessionStatus.completed;
}

/// Opaque cursor for the next timeline page — the last loaded row's
/// `(attemptedAt, id)`. Cursor pagination only; never offset.
class CardHistoryCursor {
  const CardHistoryCursor({required this.attemptedAt, required this.id});

  final DateTime attemptedAt;
  final String id;
}

/// One page of timeline attempts plus the cursor for the next page
/// (`null` when this is the last page).
class CardHistoryPage {
  const CardHistoryPage({required this.attempts, required this.nextCursor});

  final List<CardHistoryAttempt> attempts;
  final CardHistoryCursor? nextCursor;

  bool get hasMore => nextCursor != null;
}
