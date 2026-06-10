import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/domain/models/bulk_delete_result.dart';
import 'package:memox/domain/repositories/flashcard_bulk_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Drift-backed bulk flashcard mutation repository.
class FlashcardBulkRepositoryImpl implements FlashcardBulkRepository {
  FlashcardBulkRepositoryImpl(this._dao);

  final FlashcardDao _dao;

  @override
  Future<Result<BulkDeleteResult>> deleteMany({
    required List<FlashcardId> ids,
  }) async {
    if (ids.isEmpty) {
      return const Result<BulkDeleteResult>.err(
        Failure.validation(
          field: 'ids',
          code: ValidationCode.insufficientContent,
        ),
      );
    }

    final List<String> trimmedIds = ids
        .map(StringUtils.trimmed)
        .toList(growable: false);
    if (trimmedIds.any((String id) => id.isEmpty)) {
      return const Result<BulkDeleteResult>.err(
        Failure.validation(field: 'ids', code: ValidationCode.empty),
      );
    }
    if (!_hasUniqueValues(trimmedIds)) {
      return const Result<BulkDeleteResult>.err(
        Failure.validation(field: 'ids', code: ValidationCode.duplicate),
      );
    }

    try {
      final Set<String> requested = trimmedIds.toSet();
      final Set<String> existingIds = <String>{};
      for (final List<String> chunk in _chunks(requested.toList())) {
        final List<FlashcardRow> existing = await (_dao.select(
          _dao.flashcards,
        )..where((Flashcards t) => t.id.isIn(chunk))).get();
        existingIds.addAll(existing.map((FlashcardRow row) => row.id));
      }
      final int skippedCount = requested.length - existingIds.length;

      if (existingIds.isEmpty) {
        return Result<BulkDeleteResult>.ok(
          BulkDeleteResult(deletedCount: 0, skippedCount: skippedCount),
        );
      }

      await _dao.transaction(() async {
        final List<String> batchedIds = existingIds.toList(growable: false);
        for (int index = 0; index < batchedIds.length; index += 500) {
          final List<String> chunk = batchedIds.sublist(
            index,
            index + 500 > batchedIds.length ? batchedIds.length : index + 500,
          );
          await (_dao.delete(
            _dao.flashcards,
          )..where((Flashcards t) => t.id.isIn(chunk))).go();
        }
      });

      return Result<BulkDeleteResult>.ok(
        BulkDeleteResult(
          deletedCount: existingIds.length,
          skippedCount: skippedCount,
        ),
      );
    } catch (error) {
      return Result<BulkDeleteResult>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'flashcards',
        ),
      );
    }
  }

  static bool _hasUniqueValues(List<String> values) {
    final Set<String> seen = <String>{};
    for (final String value in values) {
      if (!seen.add(value)) {
        return false;
      }
    }
    return true;
  }

  static Iterable<List<String>> _chunks(
    List<String> values, [
    int size = 500,
  ]) sync* {
    for (int index = 0; index < values.length; index += size) {
      yield values.sublist(
        index,
        index + size > values.length ? values.length : index + size,
      );
    }
  }
}
