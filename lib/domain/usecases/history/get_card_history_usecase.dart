import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads the full Card History read model for one card (kit screen 09; WBS 7.6.2).
///
/// Thin delegation to [CardHistoryRepository.loadCardHistory] — a read-only,
/// full-load compose (header + merged feed). A missing card → `NotFoundFailure`;
/// a read error → `StorageFailure`.
class GetCardHistoryUseCase {
  const GetCardHistoryUseCase({required this.repository});

  final CardHistoryRepository repository;

  Future<Result<CardHistory>> call({required FlashcardId flashcardId}) =>
      repository.loadCardHistory(flashcardId: flashcardId);
}
