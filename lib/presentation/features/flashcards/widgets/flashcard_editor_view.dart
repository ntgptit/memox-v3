import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/hooks/flashcard_editor_draft_hook.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_view_parts.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

class FlashcardEditorView extends HookConsumerWidget {
  const FlashcardEditorView({
    required this.deckId,
    this.flashcardId,
    super.key,
  });

  final String deckId;
  final String? flashcardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isEditMode = flashcardId?.isNotEmpty == true;
    final FlashcardEditorDraft draft = useFlashcardEditorDraft();
    final AsyncValue<void> actionState = ref.watch(
      flashcardEditorControllerProvider,
    );
    final bool isSaving = actionState.isLoading;

    return FlashcardEditorViewContent(
      deckId: deckId,
      flashcardId: flashcardId,
      isEditMode: isEditMode,
      didPrefillCard: draft.didPrefillCard,
      onHydrateFromDetail: draft.hydrateFromDetail,
      isSaving: isSaving,
      canSave: draft.canSave,
      hasUnsavedChanges: draft.hasUnsavedChanges,
      detailsOpen: draft.detailsOpen,
      saveAndAddAnother: draft.saveAndAddAnother,
      formKey: draft.formKey,
      frontController: draft.frontController,
      backController: draft.backController,
      exampleController: draft.exampleController,
      pronunciationController: draft.pronunciationController,
      hintController: draft.hintController,
      tags: draft.tags,
      frontFocusNode: draft.frontFocusNode,
      backFocusNode: draft.backFocusNode,
      exampleFocusNode: draft.exampleFocusNode,
      pronunciationFocusNode: draft.pronunciationFocusNode,
      hintFocusNode: draft.hintFocusNode,
      frontMaxChars: _frontMaxChars,
      backMaxChars: _backMaxChars,
      onToggleSaveAndAddAnother: draft.toggleSaveAndAddAnother,
      onToggleDetails: draft.toggleDetails,
      onAddTag: () => _addTag(context, draft),
      onRemoveTag: draft.removeTag,
      onDraftChanged: draft.markDraftChanged,
      saveFailure: draft.saveFailure,
      onRetrySave: () => _retryLoad(ref, deckId, flashcardId, draft),
      onClose: () => _close(context, draft),
      onSave: () => _save(
        context: context,
        ref: ref,
        draft: draft,
        deckId: deckId,
        flashcardId: flashcardId,
        isEditMode: isEditMode,
      ),
      onDelete: () => _confirmDelete(
        context: context,
        ref: ref,
        draft: draft,
        flashcardId: flashcardId,
      ),
      onConfirmDiscard: () => _confirmDiscard(context),
      saveFailureFallbackMessage: isEditMode
          ? l10n.flashcardsEditSaveFailedMessage
          : l10n.flashcardEditorSaveFailedMessage,
      tagsLabel: l10n.flashcardEditorTagsLabel,
      tagsOptionalLabel: l10n.flashcardEditorTagsOptionalLabel,
      addTagLabel: l10n.flashcardEditorAddTagLabel,
      currentBreadcrumbLabel: isEditMode
          ? l10n.flashcardsEditTitle
          : l10n.flashcardEditorBreadcrumbCurrent,
    );
  }
}

const int _frontMaxChars = 60;
const int _backMaxChars = 240;

Future<void> _addTag(BuildContext context, FlashcardEditorDraft draft) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? rawTag = await showMxNameDialog(
    context,
    title: l10n.flashcardsTagsSheetTitle,
    fieldLabel: l10n.flashcardsFieldTagsLabel,
    confirmLabel: l10n.flashcardsTagsConfirmAction,
    cancelLabel: l10n.commonCancel,
  );
  if (rawTag == null) {
    return;
  }

  final Failure? validationFailure = TagValidator.validate(rawTag);
  if (validationFailure != null) {
    if (!context.mounted) {
      return;
    }
    showMxSnackbar(
      context,
      message: _tagValidationMessage(l10n, validationFailure),
    );
    return;
  }

  final String displayTag = TagValidator.displayValue(rawTag);
  if (draft.tags.any(
    (String tag) => StringUtils.equalsIgnoreCase(tag, displayTag),
  )) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  draft.addTag(displayTag);
}

Future<void> _close(BuildContext context, FlashcardEditorDraft draft) async {
  if (!draft.hasUnsavedChanges) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    return;
  }
  await _confirmDiscard(context);
}

Future<void> _confirmDiscard(BuildContext context) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await showMxConfirmDialog(
    context,
    title: l10n.flashcardsDiscardChangesTitle,
    message: l10n.flashcardsDiscardChangesMessage,
    confirmLabel: l10n.flashcardsDiscardChangesAction,
    cancelLabel: l10n.flashcardsKeepEditingAction,
    destructive: true,
  );
  if (!confirmed) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pop();
}

Future<void> _save({
  required BuildContext context,
  required WidgetRef ref,
  required FlashcardEditorDraft draft,
  required String deckId,
  required String? flashcardId,
  required bool isEditMode,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool addAnother = !isEditMode && draft.saveAndAddAnother;
  if (isEditMode && draft.shouldPromptProgressPolicy) {
    final FlashcardProgressEditPolicy? policy = await _showProgressPolicyDialog(
      l10n,
      context,
    );
    if (policy == null) {
      return;
    }
    final Result<Flashcard>? result = await _performSave(
      ref: ref,
      draft: draft,
      deckId: deckId,
      flashcardId: flashcardId,
      isEditMode: true,
      progressPolicy: policy,
    );
    if (result == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    result.fold((Failure failure) => draft.setSaveFailure(failure), (
      Flashcard _,
    ) {
      if (addAnother) {
        draft.resetForAnotherCard();
        showMxSnackbar(context, message: l10n.flashcardsSavedMessage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          FocusScope.of(context).requestFocus(draft.frontFocusNode);
        });
        return;
      }
      showMxSnackbar(
        context,
        message: isEditMode
            ? l10n.flashcardsUpdatedMessage
            : l10n.flashcardsCreatedMessage,
      );
      Navigator.of(context).pop();
    });
    return;
  }

  final Result<Flashcard>? result = await _performSave(
    ref: ref,
    draft: draft,
    deckId: deckId,
    flashcardId: flashcardId,
    isEditMode: isEditMode,
    progressPolicy: FlashcardProgressEditPolicy.keepProgress,
  );
  if (result == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  result.fold((Failure failure) => draft.setSaveFailure(failure), (
    Flashcard _,
  ) {
    if (addAnother) {
      draft.resetForAnotherCard();
      showMxSnackbar(context, message: l10n.flashcardsSavedMessage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        FocusScope.of(context).requestFocus(draft.frontFocusNode);
      });
      return;
    }
    showMxSnackbar(
      context,
      message: isEditMode
          ? l10n.flashcardsUpdatedMessage
          : l10n.flashcardsCreatedMessage,
    );
    Navigator.of(context).pop();
  });
}

Future<Result<Flashcard>?> _performSave({
  required WidgetRef ref,
  required FlashcardEditorDraft draft,
  required String deckId,
  required String? flashcardId,
  required bool isEditMode,
  required FlashcardProgressEditPolicy progressPolicy,
}) async {
  if (ref.read(flashcardEditorControllerProvider).isLoading) {
    return null;
  }

  final FormState? formState = draft.formKey.currentState;
  if (formState != null && !formState.validate()) {
    return null;
  }

  return isEditMode
      ? ref
            .read(flashcardEditorControllerProvider.notifier)
            .updateFlashcard(
              flashcardId: flashcardId!,
              front: draft.frontController.text,
              back: draft.backController.text,
              exampleSentence: draft.exampleController.text,
              pronunciation: draft.pronunciationController.text,
              hint: draft.hintController.text,
              tags: draft.tags,
              progressPolicy: progressPolicy,
            )
      : ref
            .read(flashcardEditorControllerProvider.notifier)
            .createFlashcard(
              deckId: deckId,
              front: draft.frontController.text,
              back: draft.backController.text,
              exampleSentence: draft.exampleController.text,
              pronunciation: draft.pronunciationController.text,
              hint: draft.hintController.text,
              tags: draft.tags,
            );
}

Future<void> _confirmDelete({
  required BuildContext context,
  required WidgetRef ref,
  required FlashcardEditorDraft draft,
  required String? flashcardId,
}) async {
  if (flashcardId == null) {
    return;
  }
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await showMxConfirmDialog(
    context,
    title: l10n.flashcardsDeleteCardTitle,
    message:
        '${draft.loadedDetail?.flashcard.front ?? ''}\n'
        '${draft.loadedDetail?.flashcard.back ?? ''}\n\n'
        '${l10n.flashcardsDeleteCardMessage(draft.loadedDetail?.progress?.reviewCount ?? 0)}',
    cancelLabel: l10n.commonCancel,
    confirmLabel: l10n.flashcardsDeleteCardAction,
    destructive: true,
  );
  if (!confirmed) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  final Result<void> result = await ref
      .read(flashcardEditorControllerProvider.notifier)
      .deleteFlashcard(flashcardId: flashcardId);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        fallback: l10n.flashcardDeletedOneMessage,
      ),
    ),
    (void _) {
      showMxSnackbar(context, message: l10n.flashcardDeletedOneMessage);
      Navigator.of(context).pop();
    },
  );
}

void _retryLoad(
  WidgetRef ref,
  String deckId,
  String? flashcardId,
  FlashcardEditorDraft draft,
) {
  ref.invalidate(flashcardEditorContextQueryProvider(deckId));
  if (flashcardId != null) {
    ref.invalidate(flashcardEditorDetailQueryProvider(flashcardId));
  }
  draft.resetForRetry();
}

Future<FlashcardProgressEditPolicy?> _showProgressPolicyDialog(
  AppLocalizations l10n,
  BuildContext context,
) async {
  final bool resetProgress = await showMxConfirmDialog(
    context,
    title: l10n.flashcardsLearningContentChangedTitle,
    message: l10n.flashcardsLearningContentChangedMessage,
    cancelLabel: l10n.flashcardsKeepProgressAction,
    confirmLabel: l10n.flashcardsResetProgressAction,
  );
  return resetProgress
      ? FlashcardProgressEditPolicy.resetProgress
      : FlashcardProgressEditPolicy.keepProgress;
}

String _tagValidationMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      ValidationFailure(code: ValidationCode.empty) =>
        l10n.flashcardsTagErrorEmpty,
      ValidationFailure(code: ValidationCode.invalidCharacter) =>
        l10n.flashcardsTagErrorComma,
      ValidationFailure(code: ValidationCode.tooLong) =>
        l10n.flashcardsTagErrorTooLong,
      _ => l10n.flashcardsTagErrorEmpty,
    };
