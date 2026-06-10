import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';

/// Merges one or more source tags into a target tag.
class MergeTagsUseCase {
  const MergeTagsUseCase(this._repository);

  final TagRepository _repository;

  Future<Result<MergeResult>> call({
    required List<String> sourceNames,
    required String targetName,
  }) async {
    if (sourceNames.isEmpty) {
      return Future<Result<MergeResult>>.value(
        const Result<MergeResult>.err(
          Failure.validation(
            field: 'sourceNames',
            code: ValidationCode.insufficientContent,
          ),
        ),
      );
    }

    final Failure? targetValidation = TagValidator.validate(targetName);
    if (targetValidation != null) {
      return Result<MergeResult>.err(targetValidation);
    }

    final String normalizedTarget = TagValidator.storageValue(targetName);
    final Set<String> normalizedSources = <String>{};
    for (final String source in sourceNames) {
      final Failure? validation = TagValidator.validate(source);
      if (validation != null) {
        return Result<MergeResult>.err(validation);
      }
      normalizedSources.add(TagValidator.storageValue(source));
    }

    if (normalizedSources.contains(normalizedTarget)) {
      return const Result<MergeResult>.err(
        Failure.validation(field: 'targetName', code: ValidationCode.duplicate),
      );
    }

    final List<String> normalizedSourceList = normalizedSources.toList()
      ..sort();
    return _repository.merge(
      sourceNames: normalizedSourceList,
      targetName: normalizedTarget,
    );
  }
}
