import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_controller.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_import_file_chip.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// Max preview rows shown before "…and N more" is implied by the summary counts.
const int _kPreviewCap = 6;

/// One combined preview row (valid card, or a skipped invalid/duplicate row).
class _Entry {
  const _Entry({
    required this.line,
    required this.valid,
    required this.title,
    this.reason,
  });

  final int line;
  final bool valid;
  final String title;
  final String? reason;
}

/// The Deck Import preview (kit `10--preview-*`): the file summary chip, a skip
/// warning when any row is invalid/duplicate, a capped per-row valid/skip list,
/// and the "Import N valid cards" commit button.
class DeckImportPreviewView extends ConsumerWidget {
  const DeckImportPreviewView({
    required this.deckId,
    required this.state,
    super.key,
  });

  final String deckId;
  final DeckImportPreview state;

  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final int validCount = state.preparation.importCount;
    final int skipCount = state.foundCount - validCount;
    final List<_Entry> entries = _entries(l10n);
    final List<_Entry> shown = entries.take(_kPreviewCap).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space4,
        MxSpacing.screen,
        MxSpacing.space6,
      ),
      children: <Widget>[
        DeckImportFileChip(
          fileName: state.fileName,
          meta: l10n.deckImportPreviewSummary(
            state.foundCount,
            validCount,
            skipCount,
          ),
          onClear: () =>
              ref.read(deckImportControllerProvider(deckId).notifier).reset(),
        ),
        const SizedBox(height: MxSpacing.space4),
        skipCount > 0
            ? _SkipBanner(text: l10n.deckImportSkipWarning(skipCount))
            : _AllValidBanner(text: l10n.deckImportAllValid(validCount)),
        const SizedBox(height: MxSpacing.space4),
        Padding(
          padding: const EdgeInsets.only(left: MxSpacing.space1),
          child: MxText(
            l10n.deckImportPreviewLabel(shown.length),
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:10-deck-import/preview-list'),
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space2,
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < shown.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(indent: _rowDividerIndent),
                _PreviewRow(entry: shown[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space5),
        MxPrimaryButton(
          label: l10n.deckImportCommitButton(validCount),
          icon: Icons.download_outlined,
          fullWidth: true,
          onPressed: validCount > 0
              ? () => ref
                    .read(deckImportControllerProvider(deckId).notifier)
                    .commit()
              : null,
        ),
      ],
    );
  }

  /// Combines valid rows + parse issues + skipped duplicates, ordered by line.
  List<_Entry> _entries(AppLocalizations l10n) {
    final List<_Entry> out = <_Entry>[
      for (final FlashcardImportRow row in state.preparation.previewItems)
        _Entry(
          line: row.lineNumber,
          valid: true,
          title: l10n.deckImportCardPair(row.front, row.back),
        ),
      for (final ImportValidationIssue issue in state.preview.issues)
        _Entry(
          line: issue.lineNumber,
          valid: false,
          title: l10n.deckImportSkippedRow,
          reason: issue.message,
        ),
      for (final FlashcardImportSkippedDuplicate dup
          in state.preparation.skippedDuplicates)
        _Entry(
          line: dup.lineNumber,
          valid: false,
          title: l10n.deckImportCardPair(dup.front, dup.back),
          reason: l10n.deckImportDuplicateReason,
        ),
    ]..sort((_Entry a, _Entry b) => a.line.compareTo(b.line));
    return out;
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tint = entry.valid ? colors.success : colors.danger;
    final String? reason = entry.reason;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
      child: Row(
        children: <Widget>[
          MxIconTile(
            color: tint,
            icon: entry.valid
                ? Icons.check_rounded
                : Icons.error_outline_rounded,
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  entry.title,
                  role: MxTextRole.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (reason != null) ...<Widget>[
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    reason,
                    role: MxTextRole.bodySmall,
                    color: colors.danger,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (!entry.valid) ...<Widget>[
            const SizedBox(width: MxSpacing.space2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MxSpacing.space2,
                vertical: MxSpacing.space1,
              ),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: MxOpacity.selected),
                borderRadius: MxRadius.pillAll,
              ),
              child: MxText(
                l10n.deckImportSkipBadge,
                role: MxTextRole.labelSmall,
                color: colors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkipBanner extends StatelessWidget {
  const _SkipBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => _Banner(
    text: text,
    tint: context.mxColors.warn,
    icon: Icons.warning_amber_rounded,
  );
}

class _AllValidBanner extends StatelessWidget {
  const _AllValidBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => _Banner(
    text: text,
    tint: context.mxColors.success,
    icon: Icons.check_circle_outline_rounded,
  );
}

/// A tinted preview banner (skip-warning or all-valid).
class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.tint, required this.icon});

  final String text;
  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(MxSpacing.space4),
    decoration: BoxDecoration(
      color: tint.withValues(alpha: MxOpacity.selected),
      borderRadius: MxRadius.mdAll,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: tint, size: MxIconSize.sm),
        const SizedBox(width: MxSpacing.space3),
        Expanded(
          child: MxText(text, role: MxTextRole.bodyMedium, color: tint),
        ),
      ],
    ),
  );
}
