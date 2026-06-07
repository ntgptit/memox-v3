import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads a single flashcard's editor detail.
///
/// Thin orchestration over [FlashcardRepository]; the editor screen uses this
/// to prefill the shared create/edit surface.
class GetFlashcardDetailUseCase {
  const GetFlashcardDetailUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardDetail>> call({required FlashcardId flashcardId}) =>
      _repository.getFlashcardDetail(flashcardId: flashcardId);
}
