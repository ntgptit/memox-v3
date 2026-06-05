/// Coarse time-ago / time-until bucket.
enum RelativeTimeUnit { justNow, minutes, hours, days, weeks, months, years }

/// A relative time expressed as a [unit] + [count], computed purely from two
/// instants so it stays testable (no hidden `DateTime.now()`).
///
/// Core is l10n-free: this is the structured value the presentation layer maps
/// to a localized `{relativeTime}` string (see `app_*.arb`). [debugLabel] is an
/// English approximation for logs only — never render it to users.
class RelativeTime {
  const RelativeTime({
    required this.unit,
    required this.count,
    required this.isFuture,
  });

  /// Buckets the gap between [instant] and [now]. Pass `now` explicitly.
  factory RelativeTime.between(DateTime instant, DateTime now) {
    final delta = now.difference(instant);
    final isFuture = delta.isNegative;
    final seconds = delta.abs().inSeconds;

    if (seconds < _minute) {
      return RelativeTime(
        unit: RelativeTimeUnit.justNow,
        count: 0,
        isFuture: isFuture,
      );
    }
    final (unit, count) = _bucket(seconds);
    return RelativeTime(unit: unit, count: count, isFuture: isFuture);
  }

  final RelativeTimeUnit unit;
  final int count;
  final bool isFuture;

  static const int _minute = 60;
  static const int _hour = 60 * _minute;
  static const int _day = 24 * _hour;
  static const int _week = 7 * _day;
  static const int _month = 30 * _day;
  static const int _year = 365 * _day;

  static (RelativeTimeUnit, int) _bucket(int seconds) {
    if (seconds < _hour) {
      return (RelativeTimeUnit.minutes, seconds ~/ _minute);
    }
    if (seconds < _day) {
      return (RelativeTimeUnit.hours, seconds ~/ _hour);
    }
    if (seconds < _week) {
      return (RelativeTimeUnit.days, seconds ~/ _day);
    }
    if (seconds < _month) {
      return (RelativeTimeUnit.weeks, seconds ~/ _week);
    }
    if (seconds < _year) {
      return (RelativeTimeUnit.months, seconds ~/ _month);
    }
    return (RelativeTimeUnit.years, seconds ~/ _year);
  }

  /// English approximation for logs/debugging only.
  String get debugLabel {
    if (unit == RelativeTimeUnit.justNow) {
      return 'just now';
    }
    final phrase = '$count ${unit.name}';
    return isFuture ? 'in $phrase' : '$phrase ago';
  }
}
