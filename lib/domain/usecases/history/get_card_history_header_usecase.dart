import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads the Card History header (preview + SRS state + lifetime counters).
///
/// Counters come straight from `flashcard_progress`; accuracy is never computed
/// by scanning attempts (`docs/contracts/usecase-contracts/history.md`).
class GetCardHistoryHeaderUseCase {
  const GetCardHistoryHeaderUseCase(this._repository);

  final CardHistoryRepository _repository;

  Future<Result<CardHistoryHeader>> call({required FlashcardId flashcardId}) =>
      _repository.loadHeader(flashcardId: flashcardId);
}
