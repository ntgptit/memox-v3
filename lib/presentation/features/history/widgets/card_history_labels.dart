import 'package:intl/intl.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/box_number.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

/// Pure l10n/format mapping for the Card History screen — keeps copy + date
/// formatting out of the widgets. No `DateTime.now()` here; callers pass `now`.
abstract final class CardHistoryLabels {
  CardHistoryLabels._();

  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _absolute = DateFormat('MMM d, HH:mm');

  /// "Box {n} / 8" chip text.
  static String boxChip(AppLocalizations l10n, int boxNumber) =>
      l10n.cardHistoryBoxChip(boxNumber, kMaxBox);

  /// Current-progress "Due" value: "Suspended" / "now" / "in 6 days".
  static String dueValue(
    AppLocalizations l10n,
    CardHistoryHeader header,
    DateTime now,
  ) {
    if (header.isSuspended) {
      return l10n.cardHistoryStateSuspended;
    }
    final DateTime? dueAt = header.dueAt;
    if (dueAt == null || !dueAt.isAfter(now)) {
      return l10n.relativeTimeUntil(RelativeTimeUnit.justNow.name, 0);
    }
    final RelativeTime relative = RelativeTime.between(dueAt, now);
    return l10n.relativeTimeUntil(relative.unit.name, relative.count);
  }

  /// Recall rate: "78%" or "—" when there are no reviews.
  static String recallValue(AppLocalizations l10n, CardHistoryHeader header) =>
      header.accuracy == null
      ? l10n.cardHistoryBoxUnknown
      : l10n.cardHistoryPercentValue((header.accuracy! * 100).round());

  static String streakValue(AppLocalizations l10n, int streak) =>
      l10n.cardHistoryStreakValue(streak);

  static String sinceAddedValue(
    AppLocalizations l10n,
    DateTime createdAt,
    DateTime now,
  ) {
    final int days = now.difference(createdAt).inDays;
    return l10n.cardHistorySinceAddedValue(days < 0 ? 0 : days);
  }

  static String chipLabel(
    AppLocalizations l10n,
    CardHistoryResultCategory category,
  ) => switch (category) {
    CardHistoryResultCategory.correct => l10n.cardHistoryChipCorrect,
    CardHistoryResultCategory.recovered => l10n.cardHistoryChipRecovered,
    CardHistoryResultCategory.forgot => l10n.cardHistoryChipForgot,
  };

  static String description(
    AppLocalizations l10n,
    CardHistoryResultCategory category,
  ) => switch (category) {
    CardHistoryResultCategory.correct => l10n.cardHistoryDescCorrect,
    CardHistoryResultCategory.recovered => l10n.cardHistoryDescRecovered,
    CardHistoryResultCategory.forgot => l10n.cardHistoryDescForgot,
  };

  /// "B2 → B3", or "—" for pre-migration rows (0 on either side).
  static String boxTransition(AppLocalizations l10n, CardHistoryAttempt a) =>
      a.boxBefore == 0 || a.boxAfter == 0
      ? l10n.cardHistoryBoxUnknown
      : '${l10n.progressBoxLabel(a.boxBefore)} → '
            '${l10n.progressBoxLabel(a.boxAfter)}';

  /// Relative attempt time, e.g. "2 hours ago".
  static String attemptRelative(
    AppLocalizations l10n,
    DateTime attemptedAt,
    DateTime now,
  ) {
    final RelativeTime relative = RelativeTime.between(attemptedAt, now);
    return l10n.relativeTimeAgo(relative.unit.name, relative.count);
  }

  /// Absolute attempt time, e.g. "May 26, 14:32".
  static String attemptAbsolute(DateTime instant) =>
      _absolute.format(instant.toLocal());

  /// Absolute local date (ISO `yyyy-MM-dd`) used for reset divider + sub-label.
  static String isoDate(DateTime instant) => _isoDate.format(instant.toLocal());
}
