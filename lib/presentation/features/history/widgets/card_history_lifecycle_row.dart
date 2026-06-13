import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_event_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline_row.dart'
    show CardHistoryChip;

/// One lifecycle event in the timeline (card created / edited / audio added).
/// Created uses the mastery accent; edits/audio use a neutral accent
/// (`docs/wireframes/09-flashcard-history.md` §Timeline).
class CardHistoryLifecycleRow extends StatelessWidget {
  const CardHistoryLifecycleRow({
    required this.event,
    required this.deckName,
    required this.now,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final CardHistoryLifecycleEvent event;
  final String deckName;
  final DateTime now;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color color = _accent(event.kind, context);
    return CardHistoryEventCard(
      nodeColor: color,
      isFirst: isFirst,
      isLast: isLast,
      occurredAt: event.occurredAt,
      now: now,
      chip: CardHistoryChip(
        color: color,
        icon: _icon(event.kind),
        label: CardHistoryLabels.lifecycleChipLabel(l10n, event.kind),
      ),
      description: CardHistoryLabels.lifecycleDescription(
        l10n,
        event.kind,
        deckName,
      ),
    );
  }

  static Color _accent(CardEventKind kind, BuildContext context) =>
      switch (kind) {
        CardEventKind.created => context.customColors.mastery,
        CardEventKind.reset => context.colorScheme.tertiary,
        CardEventKind.edited ||
        CardEventKind.audioAdded => context.colorScheme.onSurfaceVariant,
      };

  static IconData _icon(CardEventKind kind) => switch (kind) {
    CardEventKind.created => Icons.auto_awesome_outlined,
    CardEventKind.edited => Icons.edit_outlined,
    CardEventKind.audioAdded => Icons.mic_none_outlined,
    CardEventKind.reset => Icons.restart_alt,
  };
}
