import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

part 'card_history.freezed.dart';

/// A card-lifecycle event kind for the Card History feed (`card_events.type`;
/// `docs/business/history/card-history.md`). `created` is synthesized from the
/// flashcard's `created_at` (always present); `edited`/`reset`/`audioAdded` come
/// from `card_events` rows when emitted.
enum CardEventKind {
  created,
  edited,
  reset,
  audioAdded;

  /// Maps a `card_events.type` storage token to a kind; unknown tokens fall back
  /// to [edited] (a neutral "card changed") rather than throwing on read.
  static CardEventKind fromToken(String token) => switch (token) {
    'created' => CardEventKind.created,
    'edited' => CardEventKind.edited,
    'reset' => CardEventKind.reset,
    'audio_added' => CardEventKind.audioAdded,
    _ => CardEventKind.edited,
  };
}

/// The Card History header (kit screen 09): the card preview + its current SRS
/// snapshot + lifetime counters, for the screen's top card.
///
/// [accuracy] (retention) is derived from the STORED counters
/// (`(reviewCount - lapseCount) / reviewCount`), never by scanning attempts
/// (`docs/contracts/usecase-contracts/history.md` §Forbidden). [avgDurationMs] is
/// the mean measured attempt duration (null when no attempt has a logged
/// duration). [lastResetAt] drives the "includes attempts before reset" sub-label.
@freezed
sealed class CardHistoryHeader with _$CardHistoryHeader {
  const factory CardHistoryHeader({
    required String front,
    required String deckName,
    required int boxNumber,
    required int reviewCount,
    required int lapseCount,
    required int createdAt,
    int? avgDurationMs,
    int? lastResetAt,
  }) = _CardHistoryHeader;
  const CardHistoryHeader._();

  /// Lifetime retention in 0..1, or null when nothing has been reviewed.
  double? get accuracy =>
      reviewCount > 0 ? (reviewCount - lapseCount) / reviewCount : null;

  /// Whether any review has been recorded.
  bool get hasReviews => reviewCount > 0;
}

/// One row of the Card History activity feed — either a graded [CardHistoryAttempt]
/// or a lifecycle [CardHistoryLifecycle] event. [occurredAt] (epoch ms) is the
/// merge/sort key (newest first).
@freezed
sealed class CardHistoryEvent with _$CardHistoryEvent {
  /// A graded study attempt (`study_attempts`).
  const factory CardHistoryEvent.attempt({
    required int occurredAt,
    required AttemptResult result,
    required StudyMode mode,
    required int boxBefore,
    required int boxAfter,
    int? durationMs,
  }) = CardHistoryAttempt;

  /// A card lifecycle event (synthesized `created`, or a `card_events` row).
  const factory CardHistoryEvent.lifecycle({
    required int occurredAt,
    required CardEventKind kind,
    String? detail,
  }) = CardHistoryLifecycle;

  const CardHistoryEvent._();

  /// The merge/sort key — epoch ms, newest first.
  @override
  int get occurredAt => switch (this) {
    CardHistoryAttempt(:final int occurredAt) => occurredAt,
    CardHistoryLifecycle(:final int occurredAt) => occurredAt,
  };
}

/// The full Card History read model: the [header] plus the merged activity
/// [events] (attempts + lifecycle), newest first. Loaded fully per card (per-card
/// scale is small — no pagination; `docs/business/history/card-history.md`).
@freezed
sealed class CardHistory with _$CardHistory {
  const factory CardHistory({
    required CardHistoryHeader header,
    required List<CardHistoryEvent> events,
  }) = _CardHistory;
  const CardHistory._();

  /// Whether the feed has any attempt rows (lifecycle-only = "no reviews yet").
  bool get hasActivity =>
      events.any((CardHistoryEvent e) => e is CardHistoryAttempt);
}
