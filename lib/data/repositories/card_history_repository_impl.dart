import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
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

      final List<String> results = await _dao.loadResultsDesc(flashcardId);

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

  @override
  Future<Result<CardHistoryTimeline>> loadTimeline({
    required FlashcardId flashcardId,
  }) async {
    try {
      final (
        List<CardHistoryAttemptsResult> attempts,
        List<CardHistoryCardEventsResult> events,
      ) = await (
        _dao.loadAttempts(flashcardId),
        _dao.loadCardEvents(flashcardId),
      ).wait;

      final List<CardHistoryEvent> merged =
          <CardHistoryEvent>[
            ...attempts.map(_mapAttempt),
            ...events.map(_mapEvent),
          ]..sort((CardHistoryEvent a, CardHistoryEvent b) {
            final int byTime = b.occurredAt.compareTo(a.occurredAt);
            return byTime != 0 ? byTime : b.id.compareTo(a.id);
          });

      return Result<CardHistoryTimeline>.ok(
        CardHistoryTimeline(events: merged),
      );
    } catch (error) {
      return Result<CardHistoryTimeline>.err(
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
      final int nowMs = _now().toUtc().millisecondsSinceEpoch;
      final int updated = await _dao.resetProgress(
        flashcardId: flashcardId,
        nowMs: nowMs,
      );
      if (updated > 0) {
        await _dao.insertCardEvent(
          id: IdGenerator.newId(),
          flashcardId: flashcardId,
          type: 'reset',
          occurredAt: nowMs,
        );
      }
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

  CardHistoryAttemptEvent _mapAttempt(CardHistoryAttemptsResult row) =>
      CardHistoryAttemptEvent(
        id: row.id,
        occurredAt: _date(row.attemptedAt),
        result: StudyMapper.attemptResultFromStorage(row.result),
        studyMode: StudyMapper.studyModeFromStorage(row.studyMode),
        boxBefore: row.boxBefore,
        boxAfter: row.boxAfter,
        durationMs: row.durationMs,
        sessionId: row.sessionId,
        sessionStatus: StudyMapper.sessionStatusFromStorage(row.sessionStatus),
      );

  CardHistoryLifecycleEvent _mapEvent(CardHistoryCardEventsResult row) =>
      CardHistoryLifecycleEvent(
        id: row.id,
        occurredAt: _date(row.occurredAt),
        kind: _eventKind(row.type),
        detail: row.detail,
      );

  static CardEventKind _eventKind(String stored) => switch (stored) {
    'edited' => CardEventKind.edited,
    'audio_added' => CardEventKind.audioAdded,
    'reset' => CardEventKind.reset,
    _ => CardEventKind.created,
  };

  static DateTime _date(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static DateTime? _dateOrNull(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}
