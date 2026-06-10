import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';

/// Renames one tag across all cards.
class RenameTagUseCase {
  const RenameTagUseCase(this._repository);

  final TagRepository _repository;

  Future<Result<void>> call({
    required String oldName,
    required String newName,
  }) async {
    final Failure? oldValidation = TagValidator.validate(oldName);
    if (oldValidation != null) {
      return Result<void>.err(oldValidation);
    }

    final Failure? newValidation = TagValidator.validate(newName);
    if (newValidation != null) {
      return Result<void>.err(newValidation);
    }

    final String normalizedOld = TagValidator.storageValue(oldName);
    final String normalizedNew = TagValidator.storageValue(newName);
    if (normalizedOld == normalizedNew) {
      return const Result<void>.ok(null);
    }

    return _repository.rename(oldName: normalizedOld, newName: normalizedNew);
  }
}
