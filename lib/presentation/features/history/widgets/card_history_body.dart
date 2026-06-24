import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/features/history/widgets/card_history_event_row.dart';
import 'package:memox/presentation/features/history/widgets/card_history_header_card.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Card History body (kit `09`): the header card + the activity feed, read
/// from [cardHistoryProvider]. Handles loading / error / empty (no attempts) /
/// loaded.
class CardHistoryBody extends ConsumerWidget {
  const CardHistoryBody({required this.flashcardId, super.key});

  final String flashcardId;

  /// Left inset of the feed divider: leading tile (40) + its gap (12).
  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<CardHistory>> async = ref.watch(
      cardHistoryProvider(flashcardId),
    );

    return AppAsyncBuilder<Result<CardHistory>>(
      value: async,
      loading: (_) => const MxLoadingState(),
      data: (Result<CardHistory> result) {
        final CardHistory? history = result.data;
        if (history == null) {
          return MxErrorState(
            icon: Icons.cloud_off_outlined,
            title: l10n.cardHistoryLoadFailedTitle,
            message: l10n.cardHistoryLoadFailedMessage,
            action: MxPrimaryButton(
              label: l10n.commonRetryLabel,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(cardHistoryProvider(flashcardId)),
            ),
          );
        }
        return _content(context, l10n, history);
      },
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    CardHistory history,
  ) {
    const EdgeInsets padding = EdgeInsets.fromLTRB(
      MxSpacing.screen,
      MxSpacing.space4,
      MxSpacing.screen,
      MxSpacing.space12,
    );

    if (!history.hasActivity) {
      // No graded attempts yet → header + the "no history" empty state (the
      // synthesized `created` event is not surfaced as activity).
      return ListView(
        padding: padding,
        children: <Widget>[
          CardHistoryHeaderCard(header: history.header),
          const SizedBox(height: MxSpacing.space12),
          MxEmptyState(
            icon: Icons.history_rounded,
            title: l10n.cardHistoryEmptyTitle,
            message: l10n.cardHistoryEmptyMessage,
          ),
        ],
      );
    }

    final DateTime now = DateTime.now();
    return ListView(
      padding: padding,
      children: <Widget>[
        CardHistoryHeaderCard(header: history.header),
        const SizedBox(height: MxSpacing.gapSection),
        Padding(
          padding: const EdgeInsets.only(left: MxSpacing.space1),
          child: MxText(
            l10n.cardHistoryActivityLabel,
            role: MxTextRole.labelMedium,
            color: context.mxColors.textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:09-flashcard-history/activity'),
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space2,
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < history.events.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(indent: _rowDividerIndent),
                CardHistoryEventRow(event: history.events[i], now: now),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
