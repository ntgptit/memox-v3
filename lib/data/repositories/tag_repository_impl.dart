import 'dart:async';

import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/ids.dart';

/// Drift-backed tag repository over `flashcard_tags`.
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._dao);

  final FlashcardDao _dao;

  @override
  Stream<Result<List<TagWithCount>>> watchAllWithCount({String? searchTerm}) {
    final String normalized = _normalizeSearch(searchTerm);
    final Stream<List<TagWithCount>> source = _watchTagCounts(
      normalizedSearch: normalized,
    );
    return _wrapStream(source, 'flashcard_tags');
  }

  @override
  Stream<Result<List<String>>> watchTagsForDeck(DeckId deckId) {
    final String trimmedDeckId = StringUtils.trimmed(deckId);
    final Stream<List<String>> source = Stream<List<String>>.fromFuture(
      _loadTagsForDeck(trimmedDeckId),
    );
    return _wrapStream(source, 'flashcard_tags');
  }

  @override
  Stream<Result<List<String>>> watchTagsForCard(FlashcardId flashcardId) {
    final String trimmedCardId = StringUtils.trimmed(flashcardId);
    final Stream<List<String>> source = Stream<List<String>>.fromFuture(
      _loadTagsForCard(trimmedCardId),
    );
    return _wrapStream(source, 'flashcard_tags');
  }

  @override
  Future<Result<bool>> existsCaseInsensitive(String name) async {
    try {
      final String normalized = _normalizeTag(name);
      final tagExpr = _dao.flashcardTags.tag;
      final bool exists =
          await (_dao.selectOnly(_dao.flashcardTags)
                ..addColumns(<Expression<Object>>[tagExpr])
                ..where(tagExpr.equals(normalized))
                ..limit(1))
              .getSingleOrNull()
              .then((TypedResult? row) => row != null);
      return Result<bool>.ok(exists);
    } on _TagValidation catch (error) {
      return Result<bool>.err(error.failure);
    } catch (error) {
      return Result<bool>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcard_tags',
        ),
      );
    }
  }

  @override
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) async {
    try {
      final String normalizedOld = _normalizeTag(oldName);
      final String normalizedNew = _normalizeTag(newName);
      if (normalizedOld == normalizedNew) {
        return const Result<void>.ok(null);
      }

      final tagExpr = _dao.flashcardTags.tag;
      final bool collision =
          await (_dao.selectOnly(_dao.flashcardTags)
                ..addColumns(<Expression<Object>>[tagExpr])
                ..where(tagExpr.equals(normalizedNew))
                ..limit(1))
              .getSingleOrNull()
              .then((TypedResult? row) => row != null);
      if (collision) {
        return const Result<void>.err(
          Failure.conflict(message: 'tag_collision'),
        );
      }

      await _dao.transaction(() async {
        await (_dao.update(_dao.flashcardTags)
              ..where((FlashcardTags t) => t.tag.equals(normalizedOld)))
            .write(FlashcardTagsCompanion(tag: Value<String>(normalizedNew)));
      });
      return const Result<void>.ok(null);
    } on _TagValidation catch (error) {
      return Result<void>.err(error.failure);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'flashcard_tags',
        ),
      );
    }
  }

  @override
  Future<Result<MergeResult>> merge({
    required List<String> sourceNames,
    required String targetName,
  }) async {
    try {
      if (sourceNames.isEmpty) {
        return const Result<MergeResult>.err(
          Failure.validation(
            field: 'sourceNames',
            code: ValidationCode.insufficientContent,
          ),
        );
      }

      final String normalizedTarget = _normalizeTag(targetName);
      final Set<String> normalizedSources = <String>{
        for (final String source in sourceNames) _normalizeTag(source),
      };

      if (normalizedSources.contains(normalizedTarget)) {
        return const Result<MergeResult>.err(
          Failure.validation(
            field: 'targetName',
            code: ValidationCode.duplicate,
          ),
        );
      }

      final List<String> sourceList = normalizedSources.toList(growable: false);
      final flashcardIdExpr = _dao.flashcardTags.flashcardId;
      final List<TypedResult> rows =
          await (_dao.selectOnly(_dao.flashcardTags)
                ..addColumns(<Expression<Object>>[flashcardIdExpr])
                ..where(_dao.flashcardTags.tag.isIn(sourceList)))
              .get();
      final List<String> cardIds = <String>{
        for (final TypedResult row in rows) row.read(flashcardIdExpr)!,
      }.toList(growable: false);

      if (cardIds.isEmpty) {
        return const Result<MergeResult>.ok(MergeResult(affectedCardCount: 0));
      }

      await _dao.transaction(() async {
        for (final String cardId in cardIds) {
          await (_dao.delete(_dao.flashcardTags)..where(
                (FlashcardTags t) =>
                    t.flashcardId.equals(cardId) & t.tag.isIn(sourceList),
              ))
              .go();
          await _dao
              .into(_dao.flashcardTags)
              .insert(
                FlashcardTagsCompanion.insert(
                  flashcardId: cardId,
                  tag: normalizedTarget,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      });

      return Result<MergeResult>.ok(
        MergeResult(affectedCardCount: cardIds.length),
      );
    } on _TagValidation catch (error) {
      return Result<MergeResult>.err(error.failure);
    } catch (error) {
      return Result<MergeResult>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'flashcard_tags',
        ),
      );
    }
  }

  @override
  Future<Result<int>> delete({required String name}) async {
    try {
      final String normalized = _normalizeTag(name);
      final int deleted = await _dao.transaction(
        () async => (_dao.delete(
          _dao.flashcardTags,
        )..where((FlashcardTags t) => t.tag.equals(normalized))).go(),
      );
      return Result<int>.ok(deleted);
    } on _TagValidation catch (error) {
      return Result<int>.err(error.failure);
    } catch (error) {
      return Result<int>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'flashcard_tags',
        ),
      );
    }
  }

  Stream<List<TagWithCount>> _watchTagCounts({String? normalizedSearch}) {
    final tagExpr = _dao.flashcardTags.tag;
    final countExpr = _dao.flashcardTags.flashcardId.count();
    final query = _dao.selectOnly(_dao.flashcardTags)
      ..addColumns(<Expression<Object>>[tagExpr, countExpr])
      ..groupBy(<Expression<Object>>[tagExpr])
      ..orderBy(<OrderingTerm>[OrderingTerm(expression: tagExpr)]);
    if (normalizedSearch != null) {
      query.where(tagExpr.like('%$normalizedSearch%'));
    }
    return query.watch().map(
      (List<TypedResult> rows) => rows
          .map(
            (TypedResult row) => TagWithCount(
              tag: row.read(tagExpr)!,
              usageCount: row.read(countExpr) ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<List<String>> _loadTagsForDeck(String deckId) async {
    if (deckId.isEmpty) {
      return const <String>[];
    }
    final tagExpr = _dao.flashcardTags.tag;
    final rows =
        _dao.select(_dao.flashcardTags).join([
            innerJoin(
              _dao.attachedDatabase.flashcards,
              _dao.attachedDatabase.flashcards.id.equalsExp(
                _dao.flashcardTags.flashcardId,
              ),
            ),
          ])
          ..where(_dao.attachedDatabase.flashcards.deckId.equals(deckId))
          ..orderBy(<OrderingTerm>[OrderingTerm(expression: tagExpr)]);
    final Set<String> tags = <String>{};
    for (final row in await rows.get()) {
      tags.add(row.readTable(_dao.flashcardTags).tag);
    }
    return tags.toList(growable: false);
  }

  Future<List<String>> _loadTagsForCard(String flashcardId) async {
    if (flashcardId.isEmpty) {
      return const <String>[];
    }
    return (_dao.selectOnly(_dao.flashcardTags)
          ..addColumns(<Expression<Object>>[_dao.flashcardTags.tag])
          ..where(_dao.flashcardTags.flashcardId.equals(flashcardId))
          ..orderBy(<OrderingTerm>[
            OrderingTerm(expression: _dao.flashcardTags.tag),
          ]))
        .map((TypedResult row) => row.read(_dao.flashcardTags.tag)!)
        .get();
  }

  static Stream<Result<T>> _wrapStream<T>(Stream<T> source, String table) =>
      source.transform(
        StreamTransformer<T, Result<T>>.fromHandlers(
          handleData: (T data, EventSink<Result<T>> sink) =>
              sink.add(Result<T>.ok(data)),
          handleError:
              (Object error, StackTrace stack, EventSink<Result<T>> sink) =>
                  sink.add(
                    Result<T>.err(
                      Failure.storage(
                        operation: StorageOp.read,
                        cause: error.toString(),
                        table: table,
                      ),
                    ),
                  ),
        ),
      );

  static String _normalizeSearch(String? value) {
    final String trimmed = StringUtils.trimmed(value ?? '');
    return trimmed.isEmpty ? '' : StringUtils.normalize(trimmed);
  }

  static String _normalizeTag(String value) {
    final Failure? validation = TagValidator.validate(value);
    if (validation != null) {
      throw _TagValidation(validation);
    }
    return TagValidator.storageValue(value);
  }
}

class _TagValidation implements Exception {
  const _TagValidation(this.failure);

  final Failure failure;
}
