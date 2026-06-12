/// Time range selector for the Progress screen
/// (`docs/wireframes/03-progress.md` §Range tabs).
///
/// `week` covers the last 7 local days, `month` the last 28 local days
/// (matching the mock's "over the past 28 days"), `allTime` aggregates the
/// whole history without a per-day chart.
enum ProgressRange {
  week(dayCount: 7),
  month(dayCount: 28),
  allTime(dayCount: 0);

  const ProgressRange({required this.dayCount});

  /// Number of local days in the range; `0` means unbounded (all time).
  final int dayCount;
}
