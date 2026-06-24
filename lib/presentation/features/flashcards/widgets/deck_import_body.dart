import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_controller.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_import_file_chip.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_import_preview_view.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_import_result_view.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The Deck Import body (kit screen 10): renders the wizard state for [deckId].
class DeckImportBody extends ConsumerWidget {
  const DeckImportBody({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DeckImportState state = ref.watch(
      deckImportControllerProvider(deckId),
    );
    final DeckImportController controller = ref.read(
      deckImportControllerProvider(deckId).notifier,
    );

    return switch (state) {
      DeckImportEmpty() => _empty(context, l10n, controller),
      DeckImportFileSelected(:final String fileName, :final int sizeBytes) =>
        _fileSelected(context, l10n, controller, fileName, sizeBytes),
      DeckImportParsing() => MxLoadingState(message: l10n.deckImportParsing),
      DeckImportPreview() => DeckImportPreviewView(
        deckId: deckId,
        state: state,
      ),
      DeckImportImporting() => MxLoadingState(
        message: l10n.deckImportImporting,
      ),
      DeckImportSuccess() ||
      DeckImportPartial() ||
      DeckImportFailed() => DeckImportResultView(deckId: deckId, state: state),
    };
  }

  Widget _empty(
    BuildContext context,
    AppLocalizations l10n,
    DeckImportController controller,
  ) {
    final MxColors colors = context.mxColors;
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.screen),
      children: <Widget>[
        MxCard(
          key: const ValueKey<String>('mx-node:10-deck-import/empty-card'),
          padding: const EdgeInsets.all(MxSpacing.space6),
          child: Column(
            children: <Widget>[
              MxIconTile(
                color: colors.accent,
                icon: Icons.upload_file_outlined,
              ),
              const SizedBox(height: MxSpacing.space4),
              MxText(
                l10n.deckImportEmptyTitle,
                role: MxTextRole.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space2),
              MxText(
                l10n.deckImportEmptyMessage,
                role: MxTextRole.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space5),
              MxPrimaryButton(
                key: const ValueKey<String>(
                  'mx-node:10-deck-import/choose-file',
                ),
                label: l10n.deckImportChooseFile,
                icon: Icons.folder_open_outlined,
                fullWidth: true,
                onPressed: controller.pickFile,
              ),
            ],
          ),
        ),
        const SizedBox(height: MxSpacing.space4),
        _InfoBanner(text: l10n.deckImportSupportedFormats),
      ],
    );
  }

  Widget _fileSelected(
    BuildContext context,
    AppLocalizations l10n,
    DeckImportController controller,
    String fileName,
    int sizeBytes,
  ) => ListView(
    padding: const EdgeInsets.all(MxSpacing.screen),
    children: <Widget>[
      DeckImportFileChip(
        fileName: fileName,
        meta: l10n.deckImportFileMeta(
          formatImportFileSize(l10n, sizeBytes),
          importFileTypeLabel(fileName),
          l10n.deckImportReadyToParse,
        ),
        onClear: controller.clear,
      ),
      const SizedBox(height: MxSpacing.space4),
      MxPrimaryButton(
        label: l10n.deckImportParseFile,
        icon: Icons.document_scanner_outlined,
        fullWidth: true,
        onPressed: controller.parse,
      ),
      const SizedBox(height: MxSpacing.space3),
      MxText(
        l10n.deckImportParseHint,
        role: MxTextRole.bodySmall,
        color: context.mxColors.textSecondary,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.all(MxSpacing.space4),
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: MxOpacity.selected),
        borderRadius: MxRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, color: colors.info, size: MxIconSize.sm),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: MxText(text, role: MxTextRole.bodySmall, color: colors.info),
          ),
        ],
      ),
    );
  }
}
