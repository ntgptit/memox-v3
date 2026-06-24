import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_event_row.dart';

/// formatHistoryMeta buckets an event time into today / yesterday / N-days-ago /
/// absolute month-day, relative to an injected [now] (deterministic).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    // The app initializes intl date symbols via GlobalMaterialLocalizations; a
    // pure unit test must initialize them explicitly for DateFormat.
    await initializeDateFormatting();
  });

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  final DateTime now = DateTime(2026, 6, 24, 10);
  int ms(DateTime d) => d.millisecondsSinceEpoch;

  test('today → "Today · H:mm"', () {
    final String s = formatHistoryMeta(
      l10n,
      'en',
      ms(DateTime(2026, 6, 24, 9, 41)),
      now,
    );
    expect(s, 'Today · 9:41');
  });

  test('yesterday → "Yesterday · H:mm"', () {
    final String s = formatHistoryMeta(
      l10n,
      'en',
      ms(DateTime(2026, 6, 23, 8, 5)),
      now,
    );
    expect(s, 'Yesterday · 8:05');
  });

  test('within a week → "N days ago"', () {
    final String s = formatHistoryMeta(
      l10n,
      'en',
      ms(DateTime(2026, 6, 21, 21, 10)),
      now,
    );
    expect(s, '3 days ago · 21:10');
  });

  test('older than a week → absolute month/day', () {
    final String s = formatHistoryMeta(
      l10n,
      'en',
      ms(DateTime(2026, 3, 2, 9, 30)),
      now,
    );
    expect(s, 'Mar 2 · 9:30');
  });
}
