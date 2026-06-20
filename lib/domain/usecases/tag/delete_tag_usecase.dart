import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/repositories/tag_repository.dart';

/// Delete a tag from every card (the cards themselves are kept). Returns the
/// number of cards that carried the tag. Highly destructive — the caller MUST
/// confirm via the delete-confirm dialog first.
///
/// Contract: `docs/contracts/usecase-contracts/tag.md` §DeleteTagUseCase.
class DeleteTagUseCase {
  const DeleteTagUseCase({required this.repository});

  final TagRepository repository;

  Future<Result<int>> call({required String tag}) =>
      repository.delete(StringUtils.normalizeTag(tag));
}
