import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_card_status.dart';
import 'package:memox/presentation/shared/widgets/status/mx_status_badge.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

class DashboardNewLearningCard extends ConsumerWidget {
  const DashboardNewLearningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<DashboardDeckHighlights> query = ref.watch(
      dashboardDeckHighlightsQueryProvider,
    );
    final int newCardCount = query.maybeWhen(
      data: (DashboardDeckHighlights highlights) => highlights.newCardCount,
      orElse: () => 0,
    );
    if (newCardCount <= 0) {
      return const SizedBox.shrink();
    }

    return MxCard(
      onTap: () => context.goStudyEntry(
        entryType: EntryType.today,
        studyType: StudyType.newCards,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_outlined,
            size: SizeTokens.iconSm,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              l10n.dashboardStartNewLearningAction,
              role: MxTextRole.labelLarge,
              color: context.colorScheme.primary,
            ),
          ),
          MxStatusBadge(
            status: MxCardStatus.newCard,
            label: l10n.dashboardNewCardsBadge(newCardCount),
          ),
        ],
      ),
    );
  }
}

class DashboardRecentDecksSection extends ConsumerWidget {
  const DashboardRecentDecksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<DashboardDeckHighlights> query = ref.watch(
      dashboardDeckHighlightsQueryProvider,
    );
    return MxRetainedAsyncState<DashboardDeckHighlights>(
      value: query,
      skeletonBuilder: (_) => const SizedBox.shrink(),
      errorBuilder: (Object error, StackTrace? stackTrace) =>
          const SizedBox.shrink(),
      data: (DashboardDeckHighlights highlights) {
        if (highlights.recentDecks.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MxSectionHeader(
              label: l10n.dashboardRecentDecksTitle,
              trailing: MxActionButton(
                intent: MxActionIntent.inline,
                label: l10n.libraryTitle,
                icon: Icons.chevron_right_rounded,
                onPressed: () => context.goLibrary(),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            for (
              int index = 0;
              index < highlights.recentDecks.length;
              index++
            ) ...<Widget>[
              DashboardRecentDeckRow(
                deck: highlights.recentDecks[index],
                index: index,
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
          ],
        );
      },
    );
  }
}

class DashboardRecentDeckRow extends StatelessWidget {
  const DashboardRecentDeckRow({
    required this.deck,
    required this.index,
    super.key,
  });

  final DashboardRecentDeck deck;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color accent = switch (index % 3) {
      0 => context.customColors.mastery,
      1 => context.customColors.accent,
      _ => context.customColors.streak,
    };
    final String cardsLabel = l10n.dashboardDeckCardCount(deck.cardCount);
    final String metaLabel = deck.lastStudiedAt == null
        ? cardsLabel
        : () {
            final RelativeTime relativeTime = RelativeTime.between(
              deck.lastStudiedAt!,
              DateTime.now(),
            );
            return '$cardsLabel · ${l10n.dashboardDeckLastStudied(l10n.relativeTimeAgo(relativeTime.unit.name, relativeTime.count))}';
          }();

    return MxCard(
      onTap: () => context.pushFlashcardList(deck.deckId),
      child: Row(
        children: <Widget>[
          MxIconTile(icon: Icons.style_outlined, color: accent),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  deck.deckName,
                  role: MxTextRole.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  metaLabel,
                  role: MxTextRole.bodySmall,
                  color: context.colorScheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (deck.dueCount > 0) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            MxStatusBadge(
              status: MxCardStatus.reviewing,
              label: l10n.dashboardDeckDueBadge(deck.dueCount),
            ),
          ],
        ],
      ),
    );
  }
}

class DashboardOverlineLabel extends StatelessWidget {
  const DashboardOverlineLabel({
    required this.label,
    required this.accent,
    super.key,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: SpacingTokens.compact,
        height: SpacingTokens.compact,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      ),
      const SizedBox(width: SpacingTokens.tight),
      MxText(
        StringUtils.uppercased(label),
        role: MxTextRole.labelLarge,
        color: context.colorScheme.onSurfaceVariant,
      ),
    ],
  );
}

class DashboardOnboardingState extends StatelessWidget {
  const DashboardOnboardingState({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: MxEmptyState(
        icon: Icons.library_add_outlined,
        title: l10n.dashboardNewStudyTitle,
        message: l10n.dashboardNewStudyEmptyMessage,
        actionLabel: l10n.dashboardOpenLibraryAction,
        onAction: () => context.goLibrary(),
      ),
    );
  }
}
