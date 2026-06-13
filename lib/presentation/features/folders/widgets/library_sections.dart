import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// True-empty library (no folders at all): create-folder CTA.
class LibraryEmptyStateSection extends StatelessWidget {
  const LibraryEmptyStateSection({required this.onCreateFolder, super.key});

  final VoidCallback onCreateFolder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _LibraryStateShell(
      child: MxCard(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: _LibraryStateCard(
          icon: Icons.folder_outlined,
          iconColor: context.colorScheme.primary,
          title: l10n.libraryEmptyTitle,
          message: l10n.libraryEmptyMessage,
          actionLabel: l10n.libraryNewFolderLabel,
          onAction: onCreateFolder,
          actionIcon: Icons.create_new_folder_outlined,
        ),
      ),
    );
  }
}

/// Active search matched no folders (but the library is non-empty): clear CTA.
class LibrarySearchNoResults extends StatelessWidget {
  const LibrarySearchNoResults({required this.onClear, super.key});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _LibraryStateShell(
      child: MxCard(
        key: const ValueKey<String>('library_search_no_results'),
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: _LibraryStateCard(
          icon: Icons.search_off_outlined,
          iconColor: context.colorScheme.primary,
          title: l10n.librarySearchNoResultsTitle,
          message: l10n.librarySearchNoResultsMessage,
          actionLabel: l10n.commonClear,
          onAction: onClear,
          actionIntent: MxActionIntent.emptyState,
        ),
      ),
    );
  }
}

/// First-load failure: localized message + retry.
class LibraryErrorSection extends StatelessWidget {
  const LibraryErrorSection({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _LibraryStateShell(
      child: MxCard(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: _LibraryStateCard(
          icon: Icons.cloud_off_outlined,
          iconColor: context.colorScheme.error,
          title: l10n.libraryLoadFailedTitle,
          message: l10n.libraryLoadFailedMessage,
          actionLabel: l10n.commonRetry,
          onAction: onRetry,
          actionIntent: MxActionIntent.emptyState,
          actionIcon: Icons.refresh_rounded,
        ),
      ),
    );
  }
}

/// `{n} FOLDERS` overline label used by the library section header.
class LibraryFolderCount extends StatelessWidget {
  const LibraryFolderCount({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) => MxSectionHeader(
    label: AppLocalizations.of(context).libraryFolderCountLabel(count),
  );
}

/// Section header row used by Library Overview: folder count on the left and a
/// mock-aligned sort pill on the right.
class LibraryFolderHeader extends StatelessWidget {
  const LibraryFolderHeader({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MxSectionHeader(label: l10n.libraryFolderCountLabel(count)),
          const _LibrarySortPill(),
        ],
      ),
    );
  }
}

class _LibrarySortPill extends StatelessWidget {
  const _LibrarySortPill();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tone = context.colorScheme.onSurfaceVariant;
    return Container(
      height: SizeTokens.surfaceBadgeSm,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: const BoxDecoration(borderRadius: RadiusTokens.brFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.swap_vert_rounded, size: SizeTokens.iconTiny, color: tone),
          const SizedBox(width: SpacingTokens.xs),
          MxText(
            l10n.librarySortRecentLabel,
            role: MxTextRole.labelMedium,
            color: tone,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: SizeTokens.iconTiny,
            color: tone,
          ),
        ],
      ),
    );
  }
}

/// Non-interactive due-summary card, shown only when `dueToday > 0`.
class LibraryDueSummary extends StatelessWidget {
  const LibraryDueSummary({
    required this.dueToday,
    required this.dueFolderCount,
    super.key,
  });

  final int dueToday;
  final int dueFolderCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int estimatedMinutes = _estimatedMinutesForDueToday(dueToday);
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.form,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.bolt_rounded, size: SizeTokens.buttonSm),
          const SizedBox(width: SpacingTokens.form),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  l10n.libraryDueSummaryTitle(dueToday),
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  l10n.libraryDueSummarySubtitle(
                    dueFolderCount,
                    estimatedMinutes,
                  ),
                  role: MxTextRole.labelMedium,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Icon(
            Icons.chevron_right,
            size: SizeTokens.iconMinor,
            color: context.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

int _estimatedMinutesForDueToday(int dueToday) {
  int estimatedMinutes = (dueToday / 5.5).round();
  if (estimatedMinutes < 1) {
    estimatedMinutes = 1;
  }
  if (estimatedMinutes > 9999) {
    estimatedMinutes = 9999;
  }
  return estimatedMinutes;
}

class _LibraryStateShell extends StatelessWidget {
  const _LibraryStateShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.form),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: child,
        ),
      ),
    ),
  );
}

class _LibraryStateCard extends StatelessWidget {
  const _LibraryStateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.actionIntent = MxActionIntent.emptyState,
    this.actionIcon,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final MxActionIntent actionIntent;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxIconTile(icon: icon, color: iconColor, size: SizeTokens.iconXl),
        const SizedBox(height: SpacingTokens.lg),
        MxText(
          title,
          role: MxTextRole.titleMedium,
          textAlign: TextAlign.center,
          fontWeight: TypographyTokens.bold,
        ),
        const SizedBox(height: SpacingTokens.xs),
        MxText(
          message,
          role: MxTextRole.bodyMedium,
          textAlign: TextAlign.center,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxActionButton(
          intent: actionIntent,
          icon: actionIcon,
          label: actionLabel,
          onPressed: onAction,
        ),
      ],
    );
  }
}
