import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// Number of days within which the feed shows a relative day label
/// ("N days ago") before switching to an absolute month/day.
const int _kRelativeDayWindow = 7;

/// Pure formatter for an activity-row meta line ("Today · 9:41", "3 days ago ·
/// 21:10", "Mar 2 · 9:30"). [now] is injected so the relative buckets are
/// testable / deterministic. Time is 24h `H:mm`; older-than-a-week falls back to
/// a localized month/day.
String formatHistoryMeta(
  AppLocalizations l10n,
  String localeName,
  int occurredAtMs,
  DateTime now,
) {
  final DateTime dt = DateTime.fromMillisecondsSinceEpoch(
    occurredAtMs,
  ).toLocal();
  final DateTime day = DateTime(dt.year, dt.month, dt.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  final int diffDays = today.difference(day).inDays;
  // 24h "H:mm" — unpadded hour, padded minute (kit: "9:41", "21:10").
  final String time = DateFormat('H:mm', localeName).format(dt);
  final String relative = _relativeDay(l10n, localeName, dt, diffDays);
  return l10n.cardHistoryRowMeta(relative, time);
}

/// The relative-day label for [diffDays] (today / yesterday / N days ago), or a
/// localized month/day once older than a week. Guard-clause style (no `else`).
String _relativeDay(
  AppLocalizations l10n,
  String localeName,
  DateTime dt,
  int diffDays,
) {
  if (diffDays <= 0) {
    return l10n.cardHistoryToday;
  }
  if (diffDays == 1) {
    return l10n.cardHistoryYesterday;
  }
  if (diffDays < _kRelativeDayWindow) {
    return l10n.cardHistoryDaysAgo(diffDays);
  }
  return DateFormat.MMMd(localeName).format(dt);
}

/// One Card History activity-feed row (kit `09`): a tinted status tile + a title
/// over the meta line, with the attempt duration trailing. Renders either a
/// graded [CardHistoryAttempt] or a lifecycle [CardHistoryLifecycle].
class CardHistoryEventRow extends StatelessWidget {
  const CardHistoryEventRow({
    required this.event,
    required this.now,
    super.key,
  });

  final CardHistoryEvent event;

  /// Clock for the relative meta label (injected for deterministic rendering).
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String localeName = Localizations.localeOf(context).toString();

    final _RowVisual v = _visual(context, l10n);
    final String? trailing = _trailing(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      child: Row(
        children: <Widget>[
          MxIconTile(color: v.tint, icon: v.icon),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  v.title,
                  role: MxTextRole.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  formatHistoryMeta(l10n, localeName, event.occurredAt, now),
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: MxSpacing.space2),
            MxText(
              trailing,
              role: MxTextRole.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  _RowVisual _visual(BuildContext context, AppLocalizations l10n) {
    final MxColors colors = context.mxColors;
    return switch (event) {
      CardHistoryAttempt(:final AttemptResult result) => switch (result) {
        AttemptResult.perfect || AttemptResult.initialPassed => _RowVisual(
          icon: Icons.check_rounded,
          tint: colors.success,
          title: l10n.cardHistoryAttemptCorrect,
        ),
        AttemptResult.recovered => _RowVisual(
          icon: Icons.replay_rounded,
          tint: colors.warn,
          title: l10n.cardHistoryAttemptRecovered,
        ),
        AttemptResult.forgot => _RowVisual(
          icon: Icons.refresh_rounded,
          tint: colors.danger,
          title: l10n.cardHistoryAttemptForgot,
        ),
      },
      CardHistoryLifecycle(:final CardEventKind kind) => switch (kind) {
        CardEventKind.created => _RowVisual(
          icon: Icons.add_rounded,
          tint: colors.info,
          title: l10n.cardHistoryEventCreated,
        ),
        CardEventKind.edited => _RowVisual(
          icon: Icons.edit_outlined,
          tint: colors.textSecondary,
          title: l10n.cardHistoryEventEdited,
        ),
        CardEventKind.reset => _RowVisual(
          icon: Icons.restart_alt_rounded,
          tint: colors.warn,
          title: l10n.cardHistoryEventReset,
        ),
        CardEventKind.audioAdded => _RowVisual(
          icon: Icons.volume_up_outlined,
          tint: colors.info,
          title: l10n.cardHistoryEventAudio,
        ),
      },
    };
  }

  String? _trailing(AppLocalizations l10n) {
    final CardHistoryEvent e = event;
    if (e is! CardHistoryAttempt) {
      return null;
    }
    final int? ms = e.durationMs;
    if (ms == null) {
      return null;
    }
    return l10n.cardHistoryDurationSeconds((ms / 1000).toStringAsFixed(1));
  }
}

class _RowVisual {
  const _RowVisual({
    required this.icon,
    required this.tint,
    required this.title,
  });

  final IconData icon;
  final Color tint;
  final String title;
}
