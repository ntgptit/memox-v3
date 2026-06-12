import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/types/progress_range.dart';

const Set<String> _passingResults = <String>{
  'perfect',
  'initial_passed',
  'recovered',
};

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._dao);

  final ProgressDao _dao;

  @override
  Future<Result<ProgressOverview>> loadProgressOverview({
    required DateTime now,
    required ProgressRange range,
  }) async {
    try {
      final Result<BoxDistribution> boxDistribution =
          await loadBoxDistribution();
      if (boxDistribution is Err<BoxDistribution>) {
        return Result<ProgressOverview>.err(boxDistribution.failure);
      }

      final DateTime local = now.toLocal();
      final DateTime today = DateTime(local.year, local.month, local.day);

      final (
        ProgressActivity activity,
        List<int> attemptTimestamps,
        int suspendedCount,
        int buriedTodayCount,
      ) = await (
        _loadActivity(now: now, today: today, range: range),
        _dao.loadAttemptTimestamps(),
        _dao.loadSuspendedCount(),
        _dao.loadBuriedTodayCount(nowMs: now.toUtc().millisecondsSinceEpoch),
      ).wait;

      return Result<ProgressOverview>.ok(
        ProgressOverview(
          activity: activity,
          boxDistribution: (boxDistribution as Ok<BoxDistribution>).value,
          streak: _computeStreak(
            studyDays: _localDays(attemptTimestamps),
            today: today,
          ),
          cardStateCounts: ProgressCardStateCounts(
            suspendedCount: suspendedCount,
            buriedTodayCount: buriedTodayCount,
          ),
        ),
      );
    } catch (error) {
      return Result<ProgressOverview>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_attempts',
        ),
      );
    }
  }

  Future<ProgressActivity> _loadActivity({
    required DateTime now,
    required DateTime today,
    required ProgressRange range,
  }) async {
    if (range == ProgressRange.allTime) {
      final ProgressStudyStatisticsResult stats = await _dao
          .loadStudyStatistics();
      final List<int> timestamps = await _dao.loadAttemptTimestamps();
      return ProgressActivity(
        range: range,
        days: const <ProgressDayActivity>[],
        totalAttempts: stats.totalAttemptCount,
        correctAttempts: stats.correctCount,
        previousTotalAttempts: 0,
        previousCorrectAttempts: 0,
        distinctStudyDayCount: _localDays(timestamps).length,
      );
    }

    final int dayCount = range.dayCount;
    final DateTime rangeStart = today.subtract(Duration(days: dayCount - 1));
    final DateTime previousStart = rangeStart.subtract(
      Duration(days: dayCount),
    );
    final DateTime rangeEnd = today.add(const Duration(days: 1));

    final List<ProgressAttemptsBetweenResult> rows = await _dao
        .loadAttemptsBetween(
          startMs: previousStart.millisecondsSinceEpoch,
          endMs: rangeEnd.millisecondsSinceEpoch,
        );

    final Map<DateTime, ({int attempts, int correct})> buckets =
        <DateTime, ({int attempts, int correct})>{};
    int previousTotal = 0;
    int previousCorrect = 0;
    for (final ProgressAttemptsBetweenResult row in rows) {
      final DateTime attemptedLocal = DateTime.fromMillisecondsSinceEpoch(
        row.attemptedAt,
        isUtc: true,
      ).toLocal();
      final DateTime day = DateTime(
        attemptedLocal.year,
        attemptedLocal.month,
        attemptedLocal.day,
      );
      final bool passing = _passingResults.contains(row.result);
      if (day.isBefore(rangeStart)) {
        previousTotal += 1;
        if (passing) previousCorrect += 1;
        continue;
      }
      final ({int attempts, int correct}) bucket =
          buckets[day] ?? (attempts: 0, correct: 0);
      buckets[day] = (
        attempts: bucket.attempts + 1,
        correct: bucket.correct + (passing ? 1 : 0),
      );
    }

    final List<ProgressDayActivity> days = <ProgressDayActivity>[
      for (int i = 0; i < dayCount; i++)
        () {
          final DateTime day = rangeStart.add(Duration(days: i));
          final ({int attempts, int correct})? bucket = buckets[day];
          return ProgressDayActivity(
            day: day,
            attemptCount: bucket?.attempts ?? 0,
            correctCount: bucket?.correct ?? 0,
          );
        }(),
    ];

    return ProgressActivity(
      range: range,
      days: days,
      totalAttempts: days.fold(
        0,
        (int sum, ProgressDayActivity day) => sum + day.attemptCount,
      ),
      correctAttempts: days.fold(
        0,
        (int sum, ProgressDayActivity day) => sum + day.correctCount,
      ),
      previousTotalAttempts: previousTotal,
      previousCorrectAttempts: previousCorrect,
      distinctStudyDayCount: days
          .where((ProgressDayActivity day) => day.attemptCount > 0)
          .length,
    );
  }

  /// Distinct local-midnight days for the given UTC-epoch-ms timestamps,
  /// sorted ascending.
  List<DateTime> _localDays(List<int> timestamps) {
    final Set<DateTime> days = <DateTime>{};
    for (final int ms in timestamps) {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(
        ms,
        isUtc: true,
      ).toLocal();
      days.add(DateTime(local.year, local.month, local.day));
    }
    final List<DateTime> sorted = days.toList()..sort();
    return sorted;
  }

  ProgressStreak _computeStreak({
    required List<DateTime> studyDays,
    required DateTime today,
  }) {
    if (studyDays.isEmpty) {
      return const ProgressStreak(currentDays: 0, longestDays: 0);
    }

    int longest = 1;
    int run = 1;
    for (int i = 1; i < studyDays.length; i++) {
      run = studyDays[i].difference(studyDays[i - 1]).inDays == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
    }

    // Current streak counts back from today (or yesterday when today has no
    // study yet — an unfinished day does not break the streak).
    final Set<DateTime> daySet = studyDays.toSet();
    DateTime cursor = today;
    if (!daySet.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    int current = 0;
    while (daySet.contains(cursor)) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return ProgressStreak(currentDays: current, longestDays: longest);
  }

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
  Future<Result<Map<DateTime, int>>> loadAttemptCountsByDay() async {
    try {
      final List<int> rows = await _dao.loadAttemptCountsByDay();
      final Map<DateTime, int> countsByDay = <DateTime, int>{};
      for (final int attemptedAt in rows) {
        final DateTime localDay = _localDayFromEpochMs(attemptedAt);
        countsByDay[localDay] = (countsByDay[localDay] ?? 0) + 1;
      }
      return Result<Map<DateTime, int>>.ok(countsByDay);
    } catch (error) {
      return Result<Map<DateTime, int>>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_attempts',
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

  DateTime _localDayFromEpochMs(int epochMs) {
    final DateTime localDateTime = DateTime.fromMillisecondsSinceEpoch(
      epochMs,
      isUtc: true,
    ).toLocal();
    return DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
  }
}
