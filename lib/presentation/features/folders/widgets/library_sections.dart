import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
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
class LibrarySearchNoResultsSection extends StatelessWidget {
  const LibrarySearchNoResultsSection({required this.onClear, super.key});

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

/// `{n} FOLDERS` overline above the list (count only — no sort UI in V1).
class LibraryFolderCountHeader extends StatelessWidget {
  const LibraryFolderCountHeader({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) =>
      MxSectionHeader(label: AppLocalizations.of(context).libraryFolderCountLabel(count));
}

/// Non-interactive due-summary card, shown only when `dueToday > 0`.
class LibraryDueSummaryCard extends StatelessWidget {
  const LibraryDueSummaryCard({required this.dueToday, super.key});

  final int dueToday;

  @override
  Widget build(BuildContext context) => MxCard(
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.bolt_rounded),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: MxText(
              AppLocalizations.of(context).libraryDueSummaryTitle(dueToday),
              role: MxTextRole.titleMedium,
              fontWeight: TypographyTokens.bold,
            ),
          ),
        ],
      ),
    );
}
