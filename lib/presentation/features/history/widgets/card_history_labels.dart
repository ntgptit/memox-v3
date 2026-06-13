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

  // ── Header / progress card ──────────────────────────────────────────────
  static String boxChip(AppLocalizations l10n, int boxNumber) =>
      l10n.cardHistoryBoxChip(boxNumber, kMaxBox);

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

  // ── Attempt rows ────────────────────────────────────────────────────────
  static String attemptChipLabel(
    AppLocalizations l10n,
    CardHistoryResultCategory category,
  ) => switch (category) {
    CardHistoryResultCategory.correct => l10n.cardHistoryChipCorrect,
    CardHistoryResultCategory.recovered => l10n.cardHistoryChipRecovered,
    CardHistoryResultCategory.forgot => l10n.cardHistoryChipForgot,
  };

  /// Row description; "Logged with missing details" for partial rows.
  static String attemptDescription(
    AppLocalizations l10n,
    CardHistoryAttemptEvent a,
  ) {
    if (!a.hasBoxTransition) {
      return l10n.cardHistoryPartialDescription;
    }
    return switch (a.category) {
      CardHistoryResultCategory.correct => l10n.cardHistoryDescCorrect,
      CardHistoryResultCategory.recovered => l10n.cardHistoryDescRecovered,
      CardHistoryResultCategory.forgot => l10n.cardHistoryDescForgot,
    };
  }

  /// "B2" / "B3" box label.
  static String boxLabel(AppLocalizations l10n, int box) =>
      l10n.progressBoxLabel(box);

  /// "1.4s", or "duration not logged" when not measured.
  static String durationValue(AppLocalizations l10n, int? durationMs) =>
      durationMs == null
      ? l10n.cardHistoryDurationMissing
      : l10n.cardHistoryDurationValue((durationMs / 1000).toStringAsFixed(1));

  // ── Lifecycle rows ──────────────────────────────────────────────────────
  static String lifecycleChipLabel(AppLocalizations l10n, CardEventKind kind) =>
      switch (kind) {
        CardEventKind.created => l10n.cardHistoryEventCreatedChip,
        CardEventKind.edited => l10n.cardHistoryEventEditedChip,
        CardEventKind.audioAdded => l10n.cardHistoryEventAudioChip,
        CardEventKind.reset => l10n.cardHistoryEventResetChip,
      };

  static String lifecycleDescription(
    AppLocalizations l10n,
    CardEventKind kind,
    String deckName,
  ) => switch (kind) {
    CardEventKind.created => l10n.cardHistoryEventCreatedDescription(deckName),
    CardEventKind.edited => l10n.cardHistoryEventEditedDescription,
    CardEventKind.audioAdded => l10n.cardHistoryEventAudioDescription,
    CardEventKind.reset => l10n.cardHistoryEventResetDescription,
  };

  // ── Shared ──────────────────────────────────────────────────────────────
  static String relativeTime(
    AppLocalizations l10n,
    DateTime instant,
    DateTime now,
  ) {
    final RelativeTime relative = RelativeTime.between(instant, now);
    return l10n.relativeTimeAgo(relative.unit.name, relative.count);
  }

  static String absoluteTime(DateTime instant) =>
      _absolute.format(instant.toLocal());

  static String isoDate(DateTime instant) => _isoDate.format(instant.toLocal());
}
