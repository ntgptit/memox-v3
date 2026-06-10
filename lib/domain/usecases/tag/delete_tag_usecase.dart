import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';

/// Deletes a tag from all cards.
class DeleteTagUseCase {
  const DeleteTagUseCase(this._repository);

  final TagRepository _repository;

  Future<Result<int>> call({required String tag}) {
    final Failure? validation = TagValidator.validate(tag);
    if (validation != null) {
      return Future<Result<int>>.value(Result<int>.err(validation));
    }
    return _repository.delete(name: TagValidator.storageValue(tag));
  }
}
