/// Coarse relative-time unit for compact "last {n}{unit} ago" display
/// (Folder-detail deck rows, mock `04`).
enum RelativeTimeUnit { justNow, minutes, hours, days, weeks }

/// A bucketed relative time: the chosen [unit] and its [count] (0 for
/// [RelativeTimeUnit.justNow]).
typedef RelativeTime = ({RelativeTimeUnit unit, int count});

/// Buckets the gap between [time] and [now] into a coarse unit + count. A
/// future or sub-minute gap collapses to [RelativeTimeUnit.justNow]. Pure — the
/// localized string mapping lives in the presentation layer.
RelativeTime relativeTimeFrom(DateTime time, DateTime now) {
  final int seconds = now.difference(time).inSeconds;
  if (seconds < 60) return (unit: RelativeTimeUnit.justNow, count: 0);
  final int minutes = seconds ~/ 60;
  if (minutes < 60) return (unit: RelativeTimeUnit.minutes, count: minutes);
  final int hours = minutes ~/ 60;
  if (hours < 24) return (unit: RelativeTimeUnit.hours, count: hours);
  final int days = hours ~/ 24;
  if (days < 7) return (unit: RelativeTimeUnit.days, count: days);
  return (unit: RelativeTimeUnit.weeks, count: days ~/ 7);
}
