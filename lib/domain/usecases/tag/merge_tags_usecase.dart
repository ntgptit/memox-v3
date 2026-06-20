import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';

/// Merge a source tag into a destination tag across every card.
///
/// Validates [destinationName] via [TagValidator] and rejects merging a tag into
/// itself ([ValidationCode.duplicate]). The per-card de-dup and transactional
/// re-tag live in [TagRepository.merge].
///
/// Contract: `docs/contracts/usecase-contracts/tag.md` §MergeTagUseCase.
class MergeTagsUseCase {
  const MergeTagsUseCase({required this.repository});

  final TagRepository repository;

  Future<Result<MergeResult>> call({
    required String sourceName,
    required String destinationName,
  }) async {
    final Result<String> validated = TagValidator.validate(destinationName);
    if (validated.isFailure) {
      return (failure: validated.failure, data: null);
    }
    // Non-null after the failure guard above; the default is unreachable.
    final String normalizedDestination = validated.data ?? '';
    final String normalizedSource = StringUtils.normalizeTag(sourceName);

    if (normalizedSource == normalizedDestination) {
      return (
        failure: const Failure.validation(
          field: 'tag',
          code: ValidationCode.duplicate,
        ),
        data: null,
      );
    }

    return repository.merge(
      normalizedSource: normalizedSource,
      normalizedDestination: normalizedDestination,
    );
  }
}
