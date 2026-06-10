import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._dao);

  final ProgressDao _dao;

  @override
  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  }) async {
    try {
      final List<ProgressDueDeckSummariesResult> rows = await _dao
          .loadDueDeckSummaries(nowMs: now.toUtc().millisecondsSinceEpoch);
      final List<DeckDueSummary> decks = rows
          .map(
            (ProgressDueDeckSummariesResult row) => DeckDueSummary(
              deckId: row.deckId,
              deckName: row.deckName,
              parentFolderId: row.parentFolderId,
              dueCount: row.dueCount ?? 0,
            ),
          )
          .toList(growable: false);
      final int totalDueCount = decks.fold<int>(
        0,
        (int total, DeckDueSummary row) => total + row.dueCount,
      );
      return Result<ProgressDueSummary>.ok(
        ProgressDueSummary(totalDueCount: totalDueCount, decks: decks),
      );
    } catch (error) {
      return Result<ProgressDueSummary>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcard_progress',
        ),
      );
    }
  }

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() async {
    try {
      final int invalidBoxCount = await _dao.invalidBoxCount();
      if (invalidBoxCount > 0) {
        return Result<BoxDistribution>.err(
          Failure.integrity(
            message: 'Invalid flashcard_progress.box_number values found.',
            cause: 'invalid_box_count=$invalidBoxCount',
          ),
        );
      }

      final List<ProgressBoxDistributionResult> rows = await _dao
          .loadBoxDistribution();
      final Map<int, int> countsByBox = <int, int>{
        for (int box = 1; box <= 8; box++) box: 0,
      };
      for (final ProgressBoxDistributionResult row in rows) {
        countsByBox[row.boxNumber] = row.cardCount;
      }

      return Result<BoxDistribution>.ok(
        BoxDistribution(
          boxes: <BoxDistributionItem>[
            for (int box = 1; box <= 8; box++)
              BoxDistributionItem(
                boxNumber: box,
                cardCount: countsByBox[box] ?? 0,
              ),
          ],
        ),
      );
    } catch (error) {
      return Result<BoxDistribution>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'flashcard_progress',
        ),
      );
    }
  }

  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() async {
    try {
      final ProgressStudyStatisticsResult row = await _dao
          .loadStudyStatistics();
      return Result<StudyStatistics>.ok(
        StudyStatistics(
          completedSessionCount: row.completedSessionCount,
          totalAttemptCount: row.totalAttemptCount,
          correctCount: row.correctCount,
          forgotCount: row.forgotCount,
          lastStudiedAt: row.lastStudiedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  row.lastStudiedAt!,
                  isUtc: true,
                ),
        ),
      );
    } catch (error) {
      return Result<StudyStatistics>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_attempts',
        ),
      );
    }
  }

  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required DateTime now,
  }) async {
    final (
      Result<ProgressDueSummary> dueSummary,
      Result<BoxDistribution> boxDistribution,
      Result<StudyStatistics> studyStatistics,
    ) = await (
      loadProgressDueSummary(now: now),
      loadBoxDistribution(),
      loadStudyStatistics(),
    ).wait;

    if (dueSummary is Err<ProgressDueSummary>) {
      return Result<ProgressReadModel>.err(dueSummary.failure);
    }
    if (boxDistribution is Err<BoxDistribution>) {
      return Result<ProgressReadModel>.err(boxDistribution.failure);
    }
    if (studyStatistics is Err<StudyStatistics>) {
      return Result<ProgressReadModel>.err(studyStatistics.failure);
    }

    return Result<ProgressReadModel>.ok(
      ProgressReadModel(
        dueSummary: (dueSummary as Ok<ProgressDueSummary>).value,
        boxDistribution: (boxDistribution as Ok<BoxDistribution>).value,
        studyStatistics: (studyStatistics as Ok<StudyStatistics>).value,
      ),
    );
  }
}
