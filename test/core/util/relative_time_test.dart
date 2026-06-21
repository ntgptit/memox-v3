import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/util/relative_time.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 6, 21, 12);
  RelativeTime at(Duration ago) => relativeTimeFrom(now.subtract(ago), now);

  test('sub-minute and future gaps collapse to justNow', () {
    expect(at(const Duration(seconds: 30)).unit, RelativeTimeUnit.justNow);
    expect(
      relativeTimeFrom(now.add(const Duration(hours: 1)), now).unit,
      RelativeTimeUnit.justNow,
    );
  });

  test('buckets minutes / hours / days / weeks with counts', () {
    expect(at(const Duration(minutes: 5)), (
      unit: RelativeTimeUnit.minutes,
      count: 5,
    ));
    expect(at(const Duration(hours: 2)), (
      unit: RelativeTimeUnit.hours,
      count: 2,
    ));
    expect(at(const Duration(days: 4)), (
      unit: RelativeTimeUnit.days,
      count: 4,
    ));
    expect(at(const Duration(days: 21)), (
      unit: RelativeTimeUnit.weeks,
      count: 3,
    ));
  });

  test('boundaries: 59m → minutes, 60m → hours, 23h → hours, 7d → weeks', () {
    expect(at(const Duration(minutes: 59)).unit, RelativeTimeUnit.minutes);
    expect(at(const Duration(minutes: 60)).unit, RelativeTimeUnit.hours);
    expect(at(const Duration(hours: 23)).unit, RelativeTimeUnit.hours);
    expect(at(const Duration(days: 6)).unit, RelativeTimeUnit.days);
    expect(at(const Duration(days: 7)).unit, RelativeTimeUnit.weeks);
  });
}
