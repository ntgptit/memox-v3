import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads a card's full activity feed (attempts + lifecycle events), newest
/// first (`docs/contracts/usecase-contracts/history.md`).
class GetCardTimelineUseCase {
  const GetCardTimelineUseCase(this._repository);

  final CardHistoryRepository _repository;

  Future<Result<CardHistoryTimeline>> call({
    required FlashcardId flashcardId,
  }) => _repository.loadTimeline(flashcardId: flashcardId);
}
