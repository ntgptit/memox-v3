import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_delete_preview.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/features/history/widgets/card_history_body.dart';
import 'package:memox/presentation/features/history/widgets/card_history_overflow_sheet.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// Per-card review history (`docs/wireframes/09-flashcard-history.md`). Read-only
/// timeline of attempts with a header (preview + SRS state + lifetime stats) and
/// an overflow with Edit / Reset progress / Delete.
class CardHistoryScreen extends ConsumerWidget {
  const CardHistoryScreen({
    required this.deckId,
    required this.flashcardId,
    super.key,
  });

  final String deckId;
  final String flashcardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // guard:allow-screen-watch -- reason: the app bar overflow operates on the
    // loaded card (front/back), so the screen needs the header value.
    final AsyncValue<CardHistoryHeader> header = ref.watch(
      cardHistoryHeaderProvider(flashcardId),
    );
    final CardHistoryHeader? loaded = header.asData?.value;

    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.cardHistoryTitle,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            child: MxActionButton(
              intent: MxActionIntent.toolbar,
              icon: Icons.edit_outlined,
              label: l10n.commonEdit,
              onPressed: () => context.pushFlashcardEdit(deckId, flashcardId),
            ),
          ),
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            onPressed: loaded == null
                ? null
                : () => _openActions(context, ref, loaded),
          ),
        ],
      ),
      body: MxRetainedAsyncState<CardHistoryHeader>(
        value: header,
        skeletonBuilder: (_) => const MxLoadingState(),
        errorBuilder: (Object error, StackTrace? stack) => _HeaderError(
          isNotFound: error is NotFoundFailure,
          onRetry: () => ref.invalidate(cardHistoryHeaderProvider(flashcardId)),
        ),
        data: (CardHistoryHeader data) => CardHistoryBody(
          deckId: deckId,
          flashcardId: flashcardId,
          header: data,
        ),
      ),
    );
  }

  Future<void> _openActions(
    BuildContext context,
    WidgetRef ref,
    CardHistoryHeader header,
  ) async {
    final CardHistoryAction? action = await showCardHistoryActions(
      context,
      front: header.front,
    );
    if (action == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    switch (action) {
      case CardHistoryAction.resetProgress:
        await _resetProgress(context, ref);
      case CardHistoryAction.delete:
        await _deleteCard(context, ref, header);
    }
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.cardHistoryResetConfirmTitle,
      message: l10n.cardHistoryResetConfirmMessage,
      confirmLabel: l10n.flashcardsResetProgressAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final Result<void> result = await ref
        .read(cardHistoryControllerProvider.notifier)
        .resetProgress(flashcardId);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (Failure _) => showMxSnackbar(
        context,
        message: l10n.cardHistoryActionError,
        isError: true,
      ),
      (void _) =>
          showMxSnackbar(context, message: l10n.cardHistoryResetDoneMessage),
    );
  }

  Future<void> _deleteCard(
    BuildContext context,
    WidgetRef ref,
    CardHistoryHeader header,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.flashcardDeleteOneTitle,
      content: FlashcardDeletePreview(front: header.front, back: header.back),
      message: l10n.flashcardDeleteOneMessage,
      confirmLabel: l10n.flashcardsDeleteCardAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final Result<void> result = await ref
        .read(deleteFlashcardUseCaseProvider)
        .call(flashcardId);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (Failure _) => showMxSnackbar(
        context,
        message: l10n.cardHistoryActionError,
        isError: true,
      ),
      (void _) {
        showMxSnackbar(context, message: l10n.flashcardDeletedOneMessage);
        unawaited(Navigator.of(context).maybePop());
      },
    );
  }
}

class _HeaderError extends StatelessWidget {
  const _HeaderError({required this.isNotFound, required this.onRetry});

  final bool isNotFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (isNotFound) {
      return MxErrorState(
        icon: Icons.search_off,
        title: l10n.cardHistoryNotFoundTitle,
        message: l10n.cardHistoryNotFoundMessage,
      );
    }
    return MxErrorState(
      icon: Icons.history,
      title: l10n.cardHistoryErrorTitle,
      message: l10n.cardHistoryErrorMessage,
      retryLabel: l10n.commonRetry,
      onRetry: onRetry,
    );
  }
}
