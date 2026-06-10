import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/bulk_delete_result.dart';
import 'package:memox/domain/repositories/flashcard_bulk_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Deletes a snapshot of selected flashcards transactionally.
class DeleteFlashcardsUseCase {
  const DeleteFlashcardsUseCase(this._repository);

  final FlashcardBulkRepository _repository;

  Future<Result<BulkDeleteResult>> call({required List<FlashcardId> ids}) {
    final List<String> trimmedIds = ids.map(StringUtils.trimmed).toList();
    if (trimmedIds.isEmpty) {
      return Future<Result<BulkDeleteResult>>.value(
        const Result<BulkDeleteResult>.err(
          Failure.validation(
            field: 'ids',
            code: ValidationCode.insufficientContent,
          ),
        ),
      );
    }
    return _repository.deleteMany(ids: trimmedIds);
  }
}
