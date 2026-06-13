import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads one page of a card's attempt timeline, newest first.
///
/// Cursor pagination only: pass [before] to fetch the page after a cursor
/// (`docs/contracts/usecase-contracts/history.md`).
class GetCardHistoryPageUseCase {
  const GetCardHistoryPageUseCase(this._repository);

  final CardHistoryRepository _repository;

  Future<Result<CardHistoryPage>> call({
    required FlashcardId flashcardId,
    CardHistoryCursor? before,
    int limit = kCardHistoryPageSize,
  }) => _repository.loadAttempts(
    flashcardId: flashcardId,
    before: before,
    limit: limit,
  );
}
