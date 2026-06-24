import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_controller.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The terminal Deck Import result card (kit `10--success` / `--partial` /
/// `--failed`): a tinted tile + headline + body, with two actions.
class DeckImportResultView extends ConsumerWidget {
  const DeckImportResultView({
    required this.deckId,
    required this.state,
    super.key,
  });

  final String deckId;
  final DeckImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final DeckImportController controller = ref.read(
      deckImportControllerProvider(deckId).notifier,
    );

    final _ResultSpec spec = switch (state) {
      DeckImportSuccess(:final int count) => _ResultSpec(
        icon: Icons.check_rounded,
        tint: colors.success,
        title: l10n.deckImportSuccessTitle(count),
        message: l10n.deckImportSuccessMessage(_deckName(ref, l10n)),
        primaryLabel: l10n.deckImportOpenDeck,
        primaryIcon: Icons.style_outlined,
        onPrimary: () => _pop(context),
        secondaryLabel: l10n.commonDone,
        onSecondary: () => _pop(context),
      ),
      DeckImportPartial(:final int imported, :final int skipped) => _ResultSpec(
        icon: Icons.done_all_rounded,
        tint: colors.warn,
        title: l10n.deckImportPartialTitle(imported, skipped),
        message: l10n.deckImportPartialMessage,
        primaryLabel: l10n.deckImportImportAnother,
        primaryIcon: Icons.refresh,
        onPrimary: controller.reset,
        secondaryLabel: l10n.commonDone,
        onSecondary: () => _pop(context),
      ),
      _ => _ResultSpec(
        icon: Icons.close_rounded,
        tint: colors.danger,
        title: l10n.deckImportFailedTitle,
        message: l10n.deckImportFailedMessage,
        primaryLabel: l10n.commonTryAgain,
        primaryIcon: Icons.refresh,
        onPrimary: controller.reset,
        secondaryLabel: l10n.deckImportChooseAnother,
        onSecondary: controller.reset,
      ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MxSpacing.screen),
        child: MxCard(
          key: const ValueKey<String>('mx-node:10-deck-import/result-card'),
          padding: const EdgeInsets.all(MxSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxIconTile(color: spec.tint, icon: spec.icon),
              const SizedBox(height: MxSpacing.space4),
              MxText(
                spec.title,
                role: MxTextRole.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space2),
              MxText(
                spec.message,
                role: MxTextRole.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MxSpacing.space5),
              MxPrimaryButton(
                label: spec.primaryLabel,
                icon: spec.primaryIcon,
                fullWidth: true,
                onPressed: spec.onPrimary,
              ),
              const SizedBox(height: MxSpacing.space3),
              MxSecondaryButton(
                label: spec.secondaryLabel,
                variant: MxSecondaryVariant.outlined,
                fullWidth: true,
                onPressed: spec.onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _deckName(WidgetRef ref, AppLocalizations l10n) {
    final Result<FlashcardListDetail>? detail = ref
        .watch(flashcardListStreamProvider(deckId))
        .asData
        ?.value;
    return detail?.data?.deck.name ?? l10n.deckImportThisDeck;
  }

  void _pop(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
  }
}

class _ResultSpec {
  const _ResultSpec({
    required this.icon,
    required this.tint,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String message;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
}
