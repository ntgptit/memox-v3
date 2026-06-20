import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';

/// Rename a tag across every card.
///
/// Validates [newName] via [TagValidator], no-ops when the normalized new name
/// equals the old, and surfaces [ConflictFailure] (never auto-merges) when the
/// new name already exists — the caller offers the explicit merge action.
///
/// Contract: `docs/contracts/usecase-contracts/tag.md` §RenameTagUseCase.
class RenameTagUseCase {
  const RenameTagUseCase({required this.repository});

  final TagRepository repository;

  Future<Result<void>> call({
    required String oldName,
    required String newName,
  }) async {
    final Result<String> validated = TagValidator.validate(newName);
    if (validated.isFailure) {
      return (failure: validated.failure, data: null);
    }
    // Non-null after the failure guard above; the default is unreachable.
    final String normalizedNew = validated.data ?? '';
    final String normalizedOld = StringUtils.normalizeTag(oldName);

    return repository.rename(
      normalizedOldName: normalizedOld,
      normalizedNewName: normalizedNew,
    );
  }
}
