import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/week_activity.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:memox/presentation/features/stats/widgets/deck_mastery_row.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_bar_chart.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_section_header.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Stats body (screen 18): a weekly review-activity column chart over a
/// per-deck mastery list, read from [statsOverviewProvider]. Owns the data watch
/// so the screen shell stays watch-free. All money states (loading / error /
/// loaded, including the zero-data variant) are handled here.
class StatsBody extends ConsumerWidget {
  const StatsBody({super.key});

  /// Left inset of the per-deck divider: the leading tile (40) + its gap (12),
  /// so the hairline starts under the deck name like the mock.
  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<StatsOverview>> async = ref.watch(
      statsOverviewProvider,
    );

    return AppAsyncBuilder<Result<StatsOverview>>(
      value: async,
      loading: (_) => const MxLoadingState(),
      data: (Result<StatsOverview> result) {
        final StatsOverview? overview = result.data;
        if (overview == null) {
          return MxErrorState(
            icon: Icons.bar_chart_outlined,
            title: l10n.statsLoadFailedTitle,
            message: l10n.statsLoadFailedMessage,
            action: MxPrimaryButton(
              label: l10n.commonRetryLabel,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(statsOverviewProvider),
            ),
          );
        }
        return _content(context, l10n, overview);
      },
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    StatsOverview overview,
  ) => ListView(
    padding: const EdgeInsets.fromLTRB(
      MxSpacing.screen,
      MxSpacing.space2,
      MxSpacing.screen,
      MxSpacing.space6,
    ),
    children: <Widget>[
      _weekCard(context, l10n, overview.weekActivity),
      const SizedBox(height: MxSpacing.gapSection),
      _masterySection(context, l10n, overview.deckMastery),
    ],
  );

  Widget _weekCard(
    BuildContext context,
    AppLocalizations l10n,
    WeekActivity week,
  ) {
    final MxColors colors = context.mxColors;
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final List<String> narrow = material.narrowWeekdays; // index 0 = Sunday
    final List<MxBarDatum> data = <MxBarDatum>[
      for (final DayActivity day in week.days)
        MxBarDatum(
          label: narrow[day.weekday % narrow.length],
          value: day.count,
          semanticsLabel:
              '${narrow[day.weekday % narrow.length]}: '
              '${l10n.statsCardsCount(day.count)}',
        ),
    ];

    return MxCard(
      key: const ValueKey<String>('mx-node:18-stats/week-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.date_range,
                    size: MxIconSize.sm,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: MxSpacing.space2),
                  MxText(
                    l10n.statsCardsThisWeekLabel,
                    role: MxTextRole.labelMedium,
                    color: colors.textSecondary,
                  ),
                ],
              ),
              MxText(
                MaterialLocalizations.of(context).formatDecimal(week.total),
                role: MxTextRole.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space4),
          MxBarChart(
            key: const ValueKey<String>('mx-node:18-stats/week-chart'),
            data: data,
          ),
        ],
      ),
    );
  }

  Widget _masterySection(
    BuildContext context,
    AppLocalizations l10n,
    List<DeckMastery> decks,
  ) {
    final MxColors colors = context.mxColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxSectionHeader(
          key: const ValueKey<String>('mx-node:18-stats/mastery-section'),
          title: l10n.statsPerDeckMasteryTitle,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:18-stats/mastery-list'),
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space2,
          ),
          child: decks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: MxSpacing.space3,
                  ),
                  child: MxText(
                    l10n.statsNoDecksHint,
                    role: MxTextRole.bodyMedium,
                    color: colors.textSecondary,
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (int i = 0; i < decks.length; i++) ...<Widget>[
                      if (i > 0) const MxDivider(indent: _rowDividerIndent),
                      DeckMasteryRow(deck: decks[i], index: i),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
