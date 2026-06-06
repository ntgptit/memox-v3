import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// True-empty library (no folders at all): create-folder CTA.
class LibraryEmptyStateSection extends StatelessWidget {
  const LibraryEmptyStateSection({required this.onCreateFolder, super.key});

  final VoidCallback onCreateFolder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.folder_outlined,
      title: l10n.libraryEmptyTitle,
      message: l10n.libraryEmptyMessage,
      actionLabel: l10n.libraryNewFolderLabel,
      onAction: onCreateFolder,
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
    return MxEmptyState(
      key: const ValueKey<String>('library_search_no_results'),
      icon: Icons.search_off_outlined,
      title: l10n.librarySearchNoResultsTitle,
      message: l10n.librarySearchNoResultsMessage,
      actionLabel: l10n.commonClear,
      onAction: onClear,
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
    return MxErrorState(
      icon: Icons.cloud_off_outlined,
      title: l10n.libraryLoadFailedTitle,
      message: l10n.libraryLoadFailedMessage,
      retryLabel: l10n.commonRetry,
      onRetry: onRetry,
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
      padding: const EdgeInsets.only(
        left: SpacingTokens.lg + SpacingTokens.xxs,
        right: SpacingTokens.lg + SpacingTokens.xxs,
      ),
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
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      decoration: const BoxDecoration(borderRadius: RadiusTokens.brFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.swap_vert_rounded, size: 11, color: tone),
          const SizedBox(width: 5),
          MxText(
            l10n.librarySortRecentLabel,
            role: MxTextRole.labelMedium,
            color: tone,
          ),
          const SizedBox(width: 5),
          Icon(Icons.keyboard_arrow_down_rounded, size: 11, color: tone),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            context.colorScheme.primary.withValues(alpha: 0.08),
            context.customColors.accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: context.colorScheme.primary.withValues(alpha: 0.18),
        ),
        borderRadius: RadiusTokens.brLg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm + SpacingTokens.xxs,
      ),
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.bolt_rounded, size: 36),
          const SizedBox(width: SpacingTokens.md),
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
                const SizedBox(height: 1),
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
          Icon(
            Icons.chevron_right,
            size: 18,
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
