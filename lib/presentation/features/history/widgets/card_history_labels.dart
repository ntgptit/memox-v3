import 'package:intl/intl.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

/// Pure l10n mapping for the Card History screen — keeps result/box/date copy
/// out of the widgets. No `DateTime.now()` here; callers pass `now`.
abstract final class CardHistoryLabels {
  CardHistoryLabels._();

  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// "Box {n} of 8 · Due …/Suspended" line for the header.
  static String stateLine(
    AppLocalizations l10n,
    CardHistoryHeader header,
    DateTime now,
  ) {
    final String box = l10n.cardHistoryBoxState(header.boxNumber);
    return '$box · ${_stateSuffix(l10n, header, now)}';
  }

  static String _stateSuffix(
    AppLocalizations l10n,
    CardHistoryHeader header,
    DateTime now,
  ) {
    if (header.isSuspended) {
      return l10n.cardHistoryStateSuspended;
    }
    final DateTime? dueAt = header.dueAt;
    if (dueAt == null || !dueAt.isAfter(now)) {
      return l10n.cardHistoryDueNow;
    }
    final RelativeTime relative = RelativeTime.between(dueAt, now);
    return l10n.cardHistoryDueLabel(
      l10n.relativeTimeUntil(relative.unit.name, relative.count),
    );
  }

  static String resultLabel(AppLocalizations l10n, AttemptResult result) =>
      switch (result) {
        AttemptResult.perfect => l10n.cardHistoryResultPerfect,
        AttemptResult.initialPassed => l10n.cardHistoryResultPassed,
        AttemptResult.recovered => l10n.cardHistoryResultRecovered,
        AttemptResult.forgot => l10n.cardHistoryResultForgot,
      };

  /// "Box {before} → {after}", or "—" for pre-migration rows (0 on either side).
  static String boxTransition(AppLocalizations l10n, CardHistoryAttempt a) =>
      a.boxBefore == 0 || a.boxAfter == 0
      ? l10n.cardHistoryBoxUnknown
      : l10n.cardHistoryBoxTransition(a.boxBefore, a.boxAfter);

  /// Absolute local date (ISO `yyyy-MM-dd`) used for reset divider + sub-label.
  static String isoDate(DateTime instant) => _isoDate.format(instant.toLocal());

  /// Newest-first attempt timestamp, formatted absolute.
  static String attemptTimestamp(DateTime instant) =>
      DateFormat.yMd().add_Hm().format(instant.toLocal());
}
