import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
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
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/status/mx_card_status.dart';
import 'package:memox/presentation/shared/widgets/status/mx_status_badge.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

class DashboardOfflineBanner extends StatelessWidget {
  const DashboardOfflineBanner({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.form,
      vertical: SpacingTokens.sm,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxIconTile(
          icon: Icons.cloud_off_outlined,
          size: SizeTokens.iconTile,
          color: context.customColors.warning,
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(title, role: MxTextRole.titleSmall),
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                message,
                role: MxTextRole.bodySmall,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

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
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.form,
        vertical: SpacingTokens.inline,
      ),
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
              textAlign: TextAlign.center,
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
            MxCard(
              clip: Clip.antiAlias,
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < highlights.recentDecks.length;
                    index++
                  ) ...<Widget>[
                    DashboardRecentDeckRow(
                      deck: highlights.recentDecks[index],
                      index: index,
                    ),
                    if (index != highlights.recentDecks.length - 1)
                      SizedBox(
                        height: BorderTokens.width,
                        width: double.infinity,
                        child: ColoredBox(
                          color: context.colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ],
              ),
            ),
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

    return MxTappable(
      onTap: () => context.pushFlashcardList(deck.deckId),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.form,
            vertical: SpacingTokens.md,
          ),
          child: Row(
            children: <Widget>[
              MxIconTile(
                icon: Icons.style_outlined,
                color: accent,
                size: SizeTokens.iconTile,
              ),
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
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxCard(
          padding: const EdgeInsets.all(SpacingTokens.form),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Align(
                alignment: Alignment.center,
                child: MxIconTile(
                  icon: Icons.auto_awesome_outlined,
                  size: SizeTokens.iconXl,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              MxText(
                l10n.dashboardOnboardingHeroTitle,
                role: MxTextRole.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              MxText(
                l10n.dashboardOnboardingHeroMessage,
                role: MxTextRole.bodySmall,
                color: context.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.md),
              MxPrimaryButton(
                label: l10n.dashboardCreateFirstDeckAction,
                onPressed: () => context.goLibrary(),
                icon: Icons.layers_outlined,
                size: MxButtonSize.compact,
                fullWidth: true,
                stretchOnCompact: true,
              ),
              const SizedBox(height: SpacingTokens.sm),
              MxSecondaryButton(
                label: l10n.dashboardImportDeckAction,
                onPressed: () => context.goLibrary(),
                icon: Icons.upload_outlined,
                variant: MxSecondaryVariant.tonal,
                size: MxButtonSize.compact,
                fullWidth: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        DashboardOnboardingInfoCard(
          icon: Icons.cloud_outlined,
          title: l10n.dashboardOnboardingLocalFirstTitle,
          message: l10n.dashboardOnboardingLocalFirstMessage,
        ),
        const SizedBox(height: SpacingTokens.sm),
        DashboardOnboardingInfoCard(
          icon: Icons.wb_sunny_outlined,
          title: l10n.dashboardOnboardingRhythmTitle,
          message: l10n.dashboardOnboardingRhythmMessage,
        ),
        const SizedBox(height: SpacingTokens.sm),
        DashboardOnboardingInfoCard(
          icon: Icons.shield_outlined,
          title: l10n.dashboardOnboardingPressureTitle,
          message: l10n.dashboardOnboardingPressureMessage,
        ),
      ],
    );
  }
}

class DashboardOnboardingInfoCard extends StatelessWidget {
  const DashboardOnboardingInfoCard({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.form,
      vertical: SpacingTokens.sm,
    ),
    child: Row(
      children: <Widget>[
        MxIconTile(
          icon: icon,
          size: SizeTokens.iconTile,
          color: context.customColors.accent,
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(title, role: MxTextRole.titleSmall),
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                message,
                role: MxTextRole.bodySmall,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class DashboardPausedSessionsChip extends StatelessWidget {
  const DashboardPausedSessionsChip({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxSecondaryButton(
      label: l10n.dashboardMorePausedSessions(count - 1),
      onPressed: () {},
      icon: Icons.chevron_right_rounded,
      variant: MxSecondaryVariant.tonal,
      size: MxButtonSize.small,
    );
  }
}

class DashboardStreakBrokenBanner extends StatelessWidget {
  const DashboardStreakBrokenBanner({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.form,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxIconTile(
            icon: Icons.eco_outlined,
            size: SizeTokens.iconTile,
            color: context.customColors.mastery,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  l10n.dashboardStreakBrokenTitle(days),
                  role: MxTextRole.titleSmall,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  l10n.dashboardStreakBrokenMessage,
                  role: MxTextRole.bodySmall,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Icon(
            Icons.close_rounded,
            size: SizeTokens.iconSm,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
