import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/flashcard_tag_dao.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';

/// Drift-backed [TagRepository] over `flashcard_tags`. Assumes pre-normalized
/// (trimmed, lowercased) input from the domain layer; owns collision policy and
/// merge orchestration, delegating single-table work to [FlashcardTagDao].
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({required FlashcardTagDao dao}) : _dao = dao;

  final FlashcardTagDao _dao;

  @override
  Stream<List<TagWithCount>> watchAllWithCount() =>
      _dao.watchTagsWithCount().map(
        (List<TagsWithCountResult> rows) => rows
            .map(
              (TagsWithCountResult r) =>
                  TagWithCount(name: r.tag, cardCount: r.cardCount),
            )
            .toList(growable: false),
      );

  @override
  Future<Result<bool>> existsCaseInsensitive(String normalizedName) async {
    try {
      return (failure: null, data: await _dao.tagExists(normalizedName));
    } catch (error) {
      return (failure: _read(error), data: null);
    }
  }

  @override
  Future<Result<void>> rename({
    required String normalizedOldName,
    required String normalizedNewName,
  }) async {
    // No-op when the name is unchanged (case-insensitive).
    if (normalizedOldName == normalizedNewName) {
      return (failure: null, data: null);
    }
    try {
      // Renaming onto an existing tag would collide; surface a conflict so the
      // caller can offer the explicit merge action (never auto-merge).
      if (await _dao.tagExists(normalizedNewName)) {
        return (
          failure: const Failure.conflict(message: 'tag_name_exists'),
          data: null,
        );
      }
      await _dao.renameTag(normalizedOldName, normalizedNewName);
      return (failure: null, data: null);
    } catch (error) {
      return (failure: _write(error), data: null);
    }
  }

  @override
  Future<Result<MergeResult>> merge({
    required String normalizedSource,
    required String normalizedDestination,
  }) async {
    try {
      final int affected = await _dao.countCardsWithTag(normalizedSource);
      await _dao.mergeTag(normalizedSource, normalizedDestination);
      return (
        failure: null,
        data: MergeResult(
          destination: normalizedDestination,
          affectedCardCount: affected,
        ),
      );
    } catch (error) {
      return (failure: _write(error), data: null);
    }
  }

  @override
  Future<Result<int>> delete(String normalizedName) async {
    try {
      return (failure: null, data: await _dao.deleteTag(normalizedName));
    } catch (error) {
      return (failure: _write(error), data: null);
    }
  }

  Failure _write(Object error) => Failure.storage(
    operation: StorageOp.write,
    table: 'flashcard_tags',
    cause: error.toString(),
  );

  Failure _read(Object error) => Failure.storage(
    operation: StorageOp.read,
    table: 'flashcard_tags',
    cause: error.toString(),
  );
}
