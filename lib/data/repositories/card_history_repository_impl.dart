import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';

class CardHistoryRepositoryImpl implements CardHistoryRepository {
  CardHistoryRepositoryImpl(
    this._dao,
    this._folderDao, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final CardHistoryDao _dao;
  final FolderDao _folderDao;
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

      final DeckRow? deckRow = await _folderDao.findDeck(row.deckId);
      final String deckName = deckRow?.name ?? '';
      final List<FolderBreadcrumbSegment> breadcrumb = deckRow == null
          ? const <FolderBreadcrumbSegment>[]
          : (await _folderDao.breadcrumb(deckRow.folderId))
                .map(
                  (FolderBreadcrumbResult b) =>
                      FolderBreadcrumbSegment(id: b.id, name: b.name),
                )
                .toList(growable: false);

      final (int eventCount, List<String> results) = await (
        _dao.loadEventCount(flashcardId),
        _dao.loadResultsDesc(flashcardId),
      ).wait;

      return Result<CardHistoryHeader>.ok(
        CardHistoryHeader(
          flashcardId: row.flashcardId,
          deckId: row.deckId,
          deckName: deckName,
          breadcrumb: breadcrumb,
          front: row.front,
          back: row.back,
          boxNumber: row.boxNumber ?? 1,
          dueAt: _dateOrNull(row.dueAt),
          buriedUntil: _dateOrNull(row.buriedUntil),
          isSuspended: row.isSuspended ?? false,
          reviewCount: row.reviewCount ?? 0,
          lapseCount: row.lapseCount ?? 0,
          correctStreak: _correctStreak(results),
          totalEvents: eventCount,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row.createdAt,
            isUtc: true,
          ),
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

  /// Leading run of non-`forgot` results from the most recent attempt.
  int _correctStreak(List<String> resultsNewestFirst) {
    int streak = 0;
    for (final String stored in resultsNewestFirst) {
      if (StudyMapper.attemptResultFromStorage(stored) ==
          AttemptResult.forgot) {
        break;
      }
      streak += 1;
    }
    return streak;
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
