import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Card History header read model: card preview, breadcrumb context, current SRS
/// state, and cumulative lifetime stats (`docs/business/history/card-history.md`,
/// `docs/wireframes/09-flashcard-history.md`).
///
/// Lifetime counters stay cumulative across progress resets — [lastResetAt]
/// drives the "Includes attempts before last reset" sub-label, not a counter
/// reset. [accuracy] (recall rate) is derived from the stored counters, never by
/// scanning attempts.
class CardHistoryHeader {
  const CardHistoryHeader({
    required this.flashcardId,
    required this.deckId,
    required this.deckName,
    required this.breadcrumb,
    required this.front,
    required this.back,
    required this.boxNumber,
    required this.dueAt,
    required this.buriedUntil,
    required this.isSuspended,
    required this.reviewCount,
    required this.lapseCount,
    required this.correctStreak,
    required this.createdAt,
    required this.lastResetAt,
  });

  final String flashcardId;
  final String deckId;
  final String deckName;

  /// Folder ancestor chain (root → deck's parent) for the breadcrumb.
  final List<FolderBreadcrumbSegment> breadcrumb;
  final String front;
  final String back;

  /// Leitner box 1..8 (1 for a never-studied card).
  final int boxNumber;
  final DateTime? dueAt;
  final DateTime? buriedUntil;
  final bool isSuspended;
  final int reviewCount;
  final int lapseCount;

  /// Consecutive non-forgot attempts counting back from the most recent.
  final int correctStreak;
  final DateTime createdAt;
  final DateTime? lastResetAt;

  bool get hasReviews => reviewCount > 0;

  /// Lifetime recall rate in `0.0..1.0`, or `null` when there are no reviews.
  /// `(reviewCount - lapseCount) / reviewCount`.
  double? get accuracy =>
      reviewCount > 0 ? (reviewCount - lapseCount) / reviewCount : null;
}

/// Coarse result category used for attempt chips/descriptions
/// (perfect + initial_passed collapse to [correct]).
enum CardHistoryResultCategory { correct, recovered, forgot }

/// Non-attempt lifecycle event kinds shown in the timeline.
enum CardEventKind { created, edited, audioAdded, reset }

/// One entry in the Card History activity feed — an attempt or a lifecycle
/// event. Sorted by [occurredAt] (newest first).
sealed class CardHistoryEvent {
  const CardHistoryEvent({required this.id, required this.occurredAt});

  final String id;
  final DateTime occurredAt;
}

/// A graded study attempt.
class CardHistoryAttemptEvent extends CardHistoryEvent {
  const CardHistoryAttemptEvent({
    required super.id,
    required super.occurredAt,
    required this.result,
    required this.studyMode,
    required this.boxBefore,
    required this.boxAfter,
    required this.durationMs,
    required this.sessionId,
    required this.sessionStatus,
  });

  final AttemptResult result;
  final StudyMode studyMode;

  /// Leitner box before/after. `0` marks a pre-migration row → the UI omits the
  /// transition and shows "Logged with missing details".
  final int boxBefore;
  final int boxAfter;

  /// Time-on-card in ms, or `null` when not measured → "duration not logged".
  final int? durationMs;
  final String sessionId;
  final SessionStatus sessionStatus;

  CardHistoryResultCategory get category => switch (result) {
    AttemptResult.perfect ||
    AttemptResult.initialPassed => CardHistoryResultCategory.correct,
    AttemptResult.recovered => CardHistoryResultCategory.recovered,
    AttemptResult.forgot => CardHistoryResultCategory.forgot,
  };

  /// Whether the box transition is renderable (both sides known).
  bool get hasBoxTransition => boxBefore != 0 && boxAfter != 0;

  /// True when the row lacks details the timeline normally shows.
  bool get isPartial => !hasBoxTransition || durationMs == null;
}

/// A non-attempt lifecycle event (card created / edited / audio added).
class CardHistoryLifecycleEvent extends CardHistoryEvent {
  const CardHistoryLifecycleEvent({
    required super.id,
    required super.occurredAt,
    required this.kind,
    this.detail,
  });

  final CardEventKind kind;
  final String? detail;
}

/// The full per-card activity feed (attempts + lifecycle), newest first, plus a
/// flag for the "Beginning of history" terminal marker.
class CardHistoryTimeline {
  const CardHistoryTimeline({required this.events});

  final List<CardHistoryEvent> events;

  bool get isEmpty => events.isEmpty;
  int get eventCount => events.length;

  /// The feed is always fully loaded, so a non-empty feed always shows the
  /// "Beginning of history" terminal marker.
  bool get reachedBeginning => events.isNotEmpty;
}
