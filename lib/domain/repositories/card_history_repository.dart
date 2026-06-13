import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/ids.dart';

/// Read access to a flashcard's review history plus the per-card progress reset.
///
/// Contract: `docs/contracts/usecase-contracts/history.md`,
/// `docs/contracts/repository-contracts/progress-repository.md`.
abstract interface class CardHistoryRepository {
  /// Card preview + current SRS state + cumulative lifetime counters.
  /// `NotFoundFailure` when the flashcard no longer exists.
  Future<Result<CardHistoryHeader>> loadHeader({
    required FlashcardId flashcardId,
  });

  /// The full per-card activity feed (attempts + lifecycle events), newest
  /// first. Per-card scale is small, so the feed loads fully (no pagination).
  Future<Result<CardHistoryTimeline>> loadTimeline({
    required FlashcardId flashcardId,
  });

  /// Resets the card's SRS scheduling (box 1, due now, unburied) and stamps
  /// `last_reset_at = now`. Lifetime counters and attempts are retained.
  Future<Result<void>> resetProgress({required FlashcardId flashcardId});
}
