import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Resets a card's SRS scheduling (box 1, due now, unburied) and stamps
/// `last_reset_at = now`. Lifetime counters and attempts are retained so the
/// Card History timeline keeps prior attempts and shows the reset divider
/// (`docs/business/history/card-history.md`, decision row H3).
class ResetFlashcardProgressUseCase {
  const ResetFlashcardProgressUseCase(this._repository);

  final CardHistoryRepository _repository;

  Future<Result<void>> call({required FlashcardId flashcardId}) =>
      _repository.resetProgress(flashcardId: flashcardId);
}
