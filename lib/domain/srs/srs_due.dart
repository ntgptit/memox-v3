import 'package:memox/domain/srs/box_intervals.dart';

/// The due time for a card entering [box] when finalized at [nowMs]:
/// `localMidnight(studyDay + interval[box])` (WBS 4.6.4). Computed in Dart
/// (local time), never via a SQLite `localtime` modifier, so "due today" counts
/// stay stable across the day. Shared by every finalize path (one-terminal-attempt
/// and Match).
int dueAtFor(int nowMs, int box) {
  final DateTime nowLocal = DateTime.fromMillisecondsSinceEpoch(
    nowMs,
  ).toLocal();
  final DateTime studyDayMidnight = DateTime(
    nowLocal.year,
    nowLocal.month,
    nowLocal.day,
  );
  final DateTime due = studyDayMidnight.add(
    Duration(days: BoxIntervals.daysFor(box)),
  );
  return due.millisecondsSinceEpoch;
}
