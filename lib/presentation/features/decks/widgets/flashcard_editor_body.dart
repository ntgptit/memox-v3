import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/controllers/flashcard_action_controller.dart';
import 'package:memox/presentation/features/decks/flashcard_failure_message.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/navigation/library_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// The loaded card-editor form (mock `07` create / `08` edit): an X / Save app
/// bar, the deck breadcrumb, and FRONT / BACK fields. Owns the text-controller
/// hooks and the save → create/update → pop flow. Built only once the deck (and,
/// for edit, the [card]) has loaded — `FlashcardEditorScreen` handles the async.
/// WBS 2.11.2 / 2.12.2.
class FlashcardEditorForm extends HookConsumerWidget {
  const FlashcardEditorForm({
    required this.deckId,
    required this.deck,
    required this.breadcrumb,
    required this.card,
    super.key,
  });

  final String deckId;
  final Deck deck;
  final List<Folder> breadcrumb;

  /// The edited card, or `null` for a new card.
  final Flashcard? card;

  bool get _isEdit => card != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxTextSubmitState front = useMxTextSubmitState(
      initialText: card?.front ?? '',
    );
    final MxTextSubmitState back = useMxTextSubmitState(
      initialText: card?.back ?? '',
    );
    // Optional Details fields (business model: example / pronunciation / hint —
    // `flashcard-management.md` §V1 create/edit). The mock `07`/`08` deck-selector
    // is Future (deck retargeting) and its single "Note" maps to these.
    final MxTextSubmitState example = useMxTextSubmitState(
      initialText: card?.exampleSentence ?? '',
    );
    final MxTextSubmitState pronunciation = useMxTextSubmitState(
      initialText: card?.pronunciation ?? '',
    );
    final MxTextSubmitState hint = useMxTextSubmitState(
      initialText: card?.hint ?? '',
    );
    // Auto-open the Details expander when editing a card that already has any.
    final bool hasDetails =
        (card?.exampleSentence ?? '').isNotEmpty ||
        (card?.pronunciation ?? '').isNotEmpty ||
        (card?.hint ?? '').isNotEmpty;
    final ValueNotifier<bool> detailsOpen = useState<bool>(hasDetails);
    // Save in-flight (Save spinner, mock `07`/`08` Saving) + last-save-failed
    // (inline danger banner, mock Save-failed — replaces the snackbar).
    final ValueNotifier<bool> saving = useState<bool>(false);
    final ValueNotifier<bool> saveFailed = useState<bool>(false);

    final bool canSubmit = front.canSubmit && back.canSubmit;
    // Dirty = any field differs from the loaded card (empty for create).
    final bool dirty =
        front.trimmedText != (card?.front ?? '') ||
        back.trimmedText != (card?.back ?? '') ||
        example.trimmedText != (card?.exampleSentence ?? '') ||
        pronunciation.trimmedText != (card?.pronunciation ?? '') ||
        hint.trimmedText != (card?.hint ?? '');

    Future<bool> confirmDiscard() => MxConfirmDialog.show(
      context,
      title: l10n.cardDiscardTitle,
      message: l10n.cardDiscardMessage,
      confirmLabel: l10n.cardDiscardConfirm,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );

    String? orNull(String text) => text.isEmpty ? null : text;

    Future<void> save() async {
      if (!canSubmit || saving.value) return;
      saving.value = true;
      saveFailed.value = false;
      final Flashcard? existing = card;
      final Result<Flashcard> result = existing == null
          ? await ref
                .read(flashcardActionControllerProvider.notifier)
                .create(
                  deckId: deckId,
                  front: front.trimmedText,
                  back: back.trimmedText,
                  exampleSentence: orNull(example.trimmedText),
                  pronunciation: orNull(pronunciation.trimmedText),
                  hint: orNull(hint.trimmedText),
                )
          : await ref
                .read(flashcardActionControllerProvider.notifier)
                .update(
                  flashcardId: existing.id,
                  front: front.trimmedText,
                  back: back.trimmedText,
                  exampleSentence: orNull(example.trimmedText),
                  pronunciation: orNull(pronunciation.trimmedText),
                  hint: orNull(hint.trimmedText),
                  // Preserve existing tags until the tag editor lands (the use
                  // case replaces tags wholesale).
                  tags: existing.tags,
                );
      if (!context.mounted) return;
      saving.value = false;
      if (result.failure != null) {
        // Inline danger banner (mock `07`/`08` Save-failed) keeps the draft;
        // it replaces the failure snackbar.
        saveFailed.value = true;
        return;
      }
      // The app-level messenger keeps the snackbar visible after the pop.
      showMxSnackbar(
        context,
        message: _isEdit ? l10n.cardSavedSnack : l10n.cardCreatedSnack,
      );
      context.pop();
    }

    // Edit-mode danger zone (mock `08`): confirm → delete → leave the editor
    // (the card no longer exists).
    Future<void> delete() async {
      final Flashcard? existing = card;
      if (existing == null) return;
      final bool confirmed = await MxConfirmDialog.show(
        context,
        title: l10n.cardDeleteTitle,
        message: l10n.cardDeleteMessage,
        confirmLabel: l10n.cardDeleteConfirm,
        cancelLabel: l10n.commonCancel,
        destructive: true,
      );
      if (!confirmed) return;
      if (!context.mounted) return;
      final Result<void> result = await ref
          .read(flashcardActionControllerProvider.notifier)
          .delete(flashcardId: existing.id);
      if (!context.mounted) return;
      final Failure? failure = result.failure;
      if (failure != null) {
        showMxSnackbar(
          context,
          message: flashcardFailureMessage(l10n, failure),
          isError: true,
        );
        return;
      }
      showMxSnackbar(context, message: l10n.cardDeletedSnack);
      context.pop();
    }

    // A dirty draft requires a discard confirm on close / system back (mock
    // `07`/`08` Rules). `PopScope` guards the system back; the leading button
    // routes through `Navigator.maybePop` so it hits the same guard.
    return PopScope<Object?>(
      canPop: !dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) async {
        if (didPop) return;
        final bool discard = await confirmDiscard();
        if (!context.mounted) return;
        if (discard) context.pop();
      },
      child: MxScaffold(
        appBar: MxAppBar(
          automaticallyImplyLeading: false,
          // Edit is a sub-page (back arrow, mock `08`); create is a dismiss (X,
          // mock `07`).
          leading: MxIconButton(
            icon: _isEdit ? Icons.arrow_back : Icons.close,
            tooltip: l10n.commonCancel,
            onPressed: () => Navigator.maybePop(context),
          ),
          title: _isEdit ? l10n.cardEditTitle : l10n.cardCreateTitle,
          actions: <Widget>[
            // Edit-mode danger zone: a trash action before Save (mock `08`).
            if (_isEdit)
              MxIconButton(
                icon: Icons.delete_outline,
                tooltip: l10n.cardDeleteTooltip,
                onPressed: delete,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MxSpacing.space3,
                vertical: MxSpacing.space2,
              ),
              child: MxPrimaryButton(
                label: _isEdit ? l10n.cardEditConfirm : l10n.cardCreateConfirm,
                icon: Icons.check,
                size: MxButtonSize.xsmall,
                loading: saving.value,
                onPressed: canSubmit ? save : null,
              ),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: MxSpacing.space2),
              child: MxBreadcrumb(
                items: buildLibraryBreadcrumb(
                  context,
                  rootLabel: l10n.libraryRootLabel,
                  folders: breadcrumb,
                  currentLeafLabel: deck.name,
                ),
              ),
            ),
            if (saveFailed.value) ...<Widget>[
              _SaveErrorBanner(onRetry: save),
              const SizedBox(height: MxSpacing.space4),
            ],
            MxTextField(
              controller: front.controller,
              labelText: l10n.cardFrontLabel,
              autofocus: !_isEdit,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: MxSpacing.space4),
            MxTextField(
              controller: back.controller,
              labelText: l10n.cardBackLabel,
              textInputAction: detailsOpen.value
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: detailsOpen.value ? null : (_) => save(),
            ),
            const SizedBox(height: MxSpacing.space4),
            // Details expander (mock `07`/`08`): the optional content fields.
            // The mock's deck-selector is Future (deck retargeting,
            // `flashcard-management.md` §V1); the single "Note" maps to the
            // business model's example / pronunciation / hint fields.
            MxTappable(
              onTap: () => detailsOpen.value = !detailsOpen.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
                child: Row(
                  children: <Widget>[
                    Icon(
                      detailsOpen.value
                          ? Icons.expand_more
                          : Icons.chevron_right,
                      color: context.mxColors.textSecondary,
                    ),
                    const SizedBox(width: MxSpacing.space2),
                    MxText(l10n.cardDetailsLabel, role: MxTextRole.titleMedium),
                    const Spacer(),
                    // Collapsed shows "Optional"; expanded summarises the fields
                    // (mock `07` swaps the trailing label on open). Flexible +
                    // ellipsis so the longer open summary never overflows.
                    Flexible(
                      child: MxText(
                        detailsOpen.value
                            ? l10n.cardDetailsSummary
                            : l10n.cardDetailsOptional,
                        role: MxTextRole.bodySmall,
                        color: context.mxColors.textTertiary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (detailsOpen.value) ...<Widget>[
              const SizedBox(height: MxSpacing.space2),
              MxTextField(
                controller: example.controller,
                labelText: l10n.cardExampleLabel,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: MxSpacing.space4),
              MxTextField(
                controller: pronunciation.controller,
                labelText: l10n.cardPronunciationLabel,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: MxSpacing.space4),
              MxTextField(
                controller: hint.controller,
                labelText: l10n.cardHintLabel,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => save(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The inline save-failed banner (mock `07`/`08` Save-failed): a danger-tinted
/// strip with an alert glyph, message, and a Retry action. The draft is kept so
/// the user can resubmit. Replaces the failure snackbar.
class _SaveErrorBanner extends StatelessWidget {
  const _SaveErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.dangerSoft,
        borderRadius: MxRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MxSpacing.card,
          vertical: MxSpacing.space3,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              size: MxIconSize.md,
              color: colors.danger,
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: MxText(
                l10n.cardSaveFailedMessage,
                role: MxTextRole.bodyMedium,
                color: colors.danger,
              ),
            ),
            const SizedBox(width: MxSpacing.space2),
            MxPrimaryButton(
              label: l10n.commonRetryLabel,
              destructive: true,
              size: MxButtonSize.xsmall,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
