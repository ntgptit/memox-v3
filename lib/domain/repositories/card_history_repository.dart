import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/ids.dart';

/// Default timeline page size (`docs/wireframes/09-flashcard-history.md`:
/// 50 attempts per page).
const int kCardHistoryPageSize = 50;

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

  /// One page of attempts, newest first. Pass [before] to fetch the page after a
  /// cursor; cursor pagination only (never offset).
  Future<Result<CardHistoryPage>> loadAttempts({
    required FlashcardId flashcardId,
    CardHistoryCursor? before,
    int limit = kCardHistoryPageSize,
  });

  /// Resets the card's SRS scheduling (box 1, due now, unburied) and stamps
  /// `last_reset_at = now`. Lifetime counters and attempts are retained.
  Future<Result<void>> resetProgress({required FlashcardId flashcardId});
}
