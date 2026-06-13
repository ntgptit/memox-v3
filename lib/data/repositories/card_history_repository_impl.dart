import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

class CardHistoryRepositoryImpl implements CardHistoryRepository {
  CardHistoryRepositoryImpl(this._dao, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final CardHistoryDao _dao;
  final DateTime Function() _now;

  @override
  Future<Result<CardHistoryHeader>> loadHeader({
    required FlashcardId flashcardId,
  }) async {
    try {
      final CardHistoryHeaderResult? row = await _dao.loadHeader(flashcardId);
      if (row == null) {
        return Result<CardHistoryHeader>.err(
          Failure.notFound(entity: 'flashcard', id: flashcardId),
        );
      }
      return Result<CardHistoryHeader>.ok(
        CardHistoryHeader(
          flashcardId: row.flashcardId,
          front: row.front,
          back: row.back,
          boxNumber: row.boxNumber ?? 1,
          dueAt: _dateOrNull(row.dueAt),
          buriedUntil: _dateOrNull(row.buriedUntil),
          isSuspended: row.isSuspended ?? false,
          reviewCount: row.reviewCount ?? 0,
          lapseCount: row.lapseCount ?? 0,
          lastResetAt: _dateOrNull(row.lastResetAt),
        ),
      );
    } catch (error) {
      return Result<CardHistoryHeader>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcard_progress',
        ),
      );
    }
  }

  @override
  Future<Result<CardHistoryPage>> loadAttempts({
    required FlashcardId flashcardId,
    CardHistoryCursor? before,
    int limit = kCardHistoryPageSize,
  }) async {
    try {
      // Fetch one extra row to learn whether a further page exists without a
      // second count query.
      final int fetchLimit = limit + 1;
      final List<CardHistoryAttemptRow> rows = before == null
          ? await _dao.loadFirstPage(
              flashcardId: flashcardId,
              limit: fetchLimit,
            )
          : await _dao.loadNextPage(
              flashcardId: flashcardId,
              beforeAttemptedAt: before.attemptedAt.millisecondsSinceEpoch,
              beforeId: before.id,
              limit: fetchLimit,
            );

      final bool hasMore = rows.length > limit;
      final List<CardHistoryAttemptRow> pageRows = hasMore
          ? rows.sublist(0, limit)
          : rows;

      final List<CardHistoryAttempt> attempts = pageRows
          .map(_mapAttempt)
          .toList(growable: false);

      final CardHistoryAttempt? last = attempts.isEmpty ? null : attempts.last;
      return Result<CardHistoryPage>.ok(
        CardHistoryPage(
          attempts: attempts,
          nextCursor: hasMore && last != null
              ? CardHistoryCursor(attemptedAt: last.attemptedAt, id: last.id)
              : null,
        ),
      );
    } catch (error) {
      return Result<CardHistoryPage>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_attempts',
        ),
      );
    }
  }

  @override
  Future<Result<void>> resetProgress({required FlashcardId flashcardId}) async {
    try {
      await _dao.resetProgress(
        flashcardId: flashcardId,
        nowMs: _now().toUtc().millisecondsSinceEpoch,
      );
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'flashcard_progress',
        ),
      );
    }
  }

  CardHistoryAttempt _mapAttempt(CardHistoryAttemptRow row) =>
      CardHistoryAttempt(
        id: row.id,
        result: StudyMapper.attemptResultFromStorage(row.result),
        studyMode: StudyMapper.studyModeFromStorage(row.studyMode),
        boxBefore: row.boxBefore,
        boxAfter: row.boxAfter,
        attemptedAt: DateTime.fromMillisecondsSinceEpoch(
          row.attemptedAt,
          isUtc: true,
        ),
        sessionId: row.sessionId,
        sessionStatus: StudyMapper.sessionStatusFromStorage(row.sessionStatus),
      );

  static DateTime? _dateOrNull(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}
