import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/progress_engagement.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/study_statistics.dart';
import 'package:memox/domain/models/week_activity.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/srs/srs_box.dart';

/// Drift-backed [ProgressRepository] (WBS 7.1.1–7.4.1: due summary, box
/// distribution, study statistics, and the composed progress read model).
///
/// Runs the per-deck due-count query and derives the global total as the sum of
/// the per-deck counts (every flashcard belongs to exactly one deck), keeping the
/// global and per-deck numbers consistent by construction. Suspended /
/// currently-buried exclusion lives in the query.
class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({required ProgressDao dao}) : _dao = dao;

  final ProgressDao _dao;

  @override
  Future<Result<DueSummary>> loadDueSummary({required int now}) async {
    try {
      final List<DeckDueCountRow> rows = await _dao.dueCounts(now);
      final List<DeckDueCount> decks = <DeckDueCount>[
        for (final DeckDueCountRow row in rows)
          DeckDueCount(
            deckId: row.deckId,
            deckName: row.deckName,
            dueCount: row.dueCount,
          ),
      ];
      final int total = decks.fold<int>(0, (sum, d) => sum + d.dueCount);
      return (
        failure: null,
        data: DueSummary(totalDueCount: total, decksWithDue: decks),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() async {
    try {
      final List<BoxCountRow> rows = await _dao.boxCounts();
      // Zero-fill the full ladder so the chart axis is stable.
      final Map<int, int> counts = <int, int>{
        for (int box = SrsBox.min; box <= SrsBox.max; box++) box: 0,
      };
      for (final BoxCountRow row in rows) {
        if (row.boxNumber < SrsBox.min || row.boxNumber > SrsBox.max) {
          // Fail fast: a persisted box outside 1..8 is a data-invariant
          // violation (decision row P9), not user input — surface it as an
          // IntegrityFailure (logged severe / blocking) rather than silently
          // bucketing it (`docs/contracts/error-contract.md` §IntegrityFailure).
          return (
            failure: Failure.integrity(
              message:
                  'Persisted box_number ${row.boxNumber} is outside '
                  'SrsBox.min..SrsBox.max (1..8) in flashcard_progress.',
            ),
            data: null,
          );
        }
        counts[row.boxNumber] = row.cardCount;
      }
      return (failure: null, data: BoxDistribution(countsByBox: counts));
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() async {
    try {
      final int completed = await _dao.completedSessions();
      final AttemptStatsRow attempts = await _dao.attemptStats();
      return (
        failure: null,
        data: StudyStatistics(
          completedSessions: completed,
          totalAttempts: attempts.total,
          // correct = every non-forgot outcome (perfect / recovered / the
          // compatibility-only initial_passed); only `forgot` is a lapse.
          correctCount: attempts.total - attempts.forgot,
          forgotCount: attempts.forgot,
          lastStudiedAt: attempts.lastStudiedAt,
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required int now,
  }) async {
    // Compose the three Progress reads; the first failure short-circuits.
    final Result<DueSummary> due = await loadDueSummary(now: now);
    if (due.failure != null) {
      return (failure: due.failure, data: null);
    }
    final Result<BoxDistribution> boxes = await loadBoxDistribution();
    if (boxes.failure != null) {
      return (failure: boxes.failure, data: null);
    }
    final Result<StudyStatistics> stats = await loadStudyStatistics();
    if (stats.failure != null) {
      return (failure: stats.failure, data: null);
    }
    return (
      failure: null,
      data: ProgressReadModel(
        dueSummary: due.data!,
        boxDistribution: boxes.data!,
        statistics: stats.data!,
      ),
    );
  }

  @override
  Future<Result<StatsOverview>> loadStatsOverview({required int now}) async {
    try {
      final WeekActivity week = await _loadWeekActivity(now);
      final List<DeckMastery> decks = await _loadDeckMastery();
      return (
        failure: null,
        data: StatsOverview(weekActivity: week, deckMastery: decks),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<StudyDayActivity>> loadStudyActivity({required int now}) async {
    try {
      // All attempt timestamps (start = 0 → whole history); the streak + today
      // count are computed by LOCAL day in Dart (never SQL — the test sqlite
      // returns NULL for 'localtime'), mirroring the Stats week-bucketing.
      final List<int> times = await _dao.attemptTimesSince(0);
      return (failure: null, data: _studyDayActivity(times, now));
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// Pure local-day reduction of attempt [times] (epoch ms) as of [now]: today's
  /// answered count + the current/longest consecutive study-day streak. Days are
  /// normalized to a UTC-midnight ordinal so DST never miscounts adjacency.
  static StudyDayActivity _studyDayActivity(List<int> times, int now) {
    int ordinalOf(int epochMs) {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(
        epochMs,
      ).toLocal();
      return DateTime.utc(
        local.year,
        local.month,
        local.day,
      ).difference(DateTime.utc(2000)).inDays;
    }

    final int todayOrdinal = ordinalOf(now);
    final Set<int> days = <int>{};
    int todayCount = 0;
    for (final int t in times) {
      final int ord = ordinalOf(t);
      days.add(ord);
      if (ord == todayOrdinal) todayCount++;
    }

    // Current streak: count back from today, or from yesterday when today has no
    // attempt yet (an unfinished today must not break the run).
    int current = 0;
    int anchor = days.contains(todayOrdinal)
        ? todayOrdinal
        : (days.contains(todayOrdinal - 1) ? todayOrdinal - 1 : null) ??
              todayOrdinal;
    if (days.contains(anchor)) {
      while (days.contains(anchor)) {
        current++;
        anchor--;
      }
    }

    // Longest streak: longest run of consecutive ordinals across all study days.
    int longest = 0;
    if (days.isNotEmpty) {
      final List<int> sorted = days.toList()..sort();
      int run = 1;
      longest = 1;
      for (int i = 1; i < sorted.length; i++) {
        run = sorted[i] == sorted[i - 1] + 1 ? run + 1 : 1;
        if (run > longest) longest = run;
      }
    }

    return StudyDayActivity(
      todayAnsweredCount: todayCount,
      currentStreak: current,
      longestStreak: longest,
    );
  }

  /// The current local week's daily review counts (Monday → Sunday), bucketed in
  /// Dart from raw attempt timestamps so the `'localtime'`-NULL sqlite quirk on
  /// Windows tests never bites (Stats decision row P20).
  Future<WeekActivity> _loadWeekActivity(int now) async {
    final DateTime nowLocal = DateTime.fromMillisecondsSinceEpoch(
      now,
    ).toLocal();
    // Monday of the current local week, at local midnight.
    final DateTime weekStart = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day - (nowLocal.weekday - DateTime.monday),
    );
    final List<int> times = await _dao.attemptTimesSince(
      weekStart.millisecondsSinceEpoch,
    );

    final List<int> counts = List<int>.filled(_daysPerWeek, 0);
    for (final int t in times) {
      final DateTime d = DateTime.fromMillisecondsSinceEpoch(t).toLocal();
      final int index = _weekdayIndex(
        weekStart,
        DateTime(d.year, d.month, d.day),
      );
      if (index >= 0 && index < _daysPerWeek) {
        counts[index]++;
      }
    }

    return WeekActivity(
      days: <DayActivity>[
        for (int i = 0; i < _daysPerWeek; i++)
          () {
            // Day-arithmetic via the constructor normalizes across month/DST.
            final DateTime day = DateTime(
              weekStart.year,
              weekStart.month,
              weekStart.day + i,
            );
            return DayActivity(
              date: day,
              weekday: day.weekday,
              count: counts[i],
            );
          }(),
      ],
    );
  }

  /// Index (0..6, Monday-based) of [day] within the week starting [weekStart],
  /// matched by calendar date so a DST hour shift can't miscount the bucket.
  int _weekdayIndex(DateTime weekStart, DateTime day) {
    for (int i = 0; i < _daysPerWeek; i++) {
      final DateTime wd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      if (wd.year == day.year && wd.month == day.month && wd.day == day.day) {
        return i;
      }
    }
    return -1;
  }

  Future<List<DeckMastery>> _loadDeckMastery() async {
    final List<DeckMasteryRow> rows = await _dao.deckMasteryRows();
    return <DeckMastery>[
      for (final DeckMasteryRow row in rows)
        DeckMastery(
          deckId: row.deckId,
          deckName: row.deckName,
          masteryFraction: _masteryFraction(row.avgBox),
        ),
    ];
  }

  /// Maps an average Leitner box onto a 0..1 mastery fraction: box `SrsBox.min`
  /// → 0.0, box `SrsBox.max` → 1.0 (Stats decision row P21).
  double _masteryFraction(double avgBox) {
    const int span = SrsBox.max - SrsBox.min;
    if (span <= 0) {
      return 0;
    }
    return ((avgBox - SrsBox.min) / span).clamp(0.0, 1.0);
  }

  /// Days in the Stats weekly chart (Monday → Sunday).
  static const int _daysPerWeek = 7;
}
