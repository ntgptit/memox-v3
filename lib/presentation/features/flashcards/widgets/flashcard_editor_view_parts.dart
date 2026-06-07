import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_body.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_view_states.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorViewContent extends ConsumerWidget {
  const FlashcardEditorViewContent({
    required this.deckId,
    required this.flashcardId,
    required this.isEditMode,
    required this.didPrefillCard,
    required this.onHydrateFromDetail,
    required this.isSaving,
    required this.canSave,
    required this.hasUnsavedChanges,
    required this.detailsOpen,
    required this.saveAndAddAnother,
    required this.formKey,
    required this.frontController,
    required this.backController,
    required this.exampleController,
    required this.pronunciationController,
    required this.hintController,
    required this.tags,
    required this.frontFocusNode,
    required this.backFocusNode,
    required this.exampleFocusNode,
    required this.pronunciationFocusNode,
    required this.hintFocusNode,
    required this.frontMaxChars,
    required this.backMaxChars,
    required this.onToggleSaveAndAddAnother,
    required this.onToggleDetails,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onDraftChanged,
    required this.saveFailure,
    required this.onRetrySave,
    required this.onClose,
    required this.onSave,
    required this.onDelete,
    required this.onConfirmDiscard,
    required this.saveFailureFallbackMessage,
    required this.tagsLabel,
    required this.tagsOptionalLabel,
    required this.addTagLabel,
    required this.currentBreadcrumbLabel,
    super.key,
  });

  final String deckId;
  final String? flashcardId;
  final bool isEditMode;
  final bool didPrefillCard;
  final void Function(FlashcardDetail detail) onHydrateFromDetail;
  final bool isSaving;
  final bool canSave;
  final bool hasUnsavedChanges;
  final bool detailsOpen;
  final bool saveAndAddAnother;
  final GlobalKey<FormState> formKey;
  final TextEditingController frontController;
  final TextEditingController backController;
  final TextEditingController exampleController;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final List<String> tags;
  final FocusNode frontFocusNode;
  final FocusNode backFocusNode;
  final FocusNode exampleFocusNode;
  final FocusNode pronunciationFocusNode;
  final FocusNode hintFocusNode;
  final int frontMaxChars;
  final int backMaxChars;
  final ValueChanged<bool> onToggleSaveAndAddAnother;
  final VoidCallback onToggleDetails;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onDraftChanged;
  final Failure? saveFailure;
  final VoidCallback onRetrySave;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final Future<void> Function() onConfirmDiscard;
  final String saveFailureFallbackMessage;
  final String tagsLabel;
  final String tagsOptionalLabel;
  final String addTagLabel;
  final String currentBreadcrumbLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _buildFlashcardEditorView(
        context: context,
        ref: ref,
        deckId: deckId,
        flashcardId: flashcardId,
        isEditMode: isEditMode,
        didPrefillCard: didPrefillCard,
        onHydrateFromDetail: onHydrateFromDetail,
        isSaving: isSaving,
        canSave: canSave,
        hasUnsavedChanges: hasUnsavedChanges,
        detailsOpen: detailsOpen,
        saveAndAddAnother: saveAndAddAnother,
        formKey: formKey,
        frontController: frontController,
        backController: backController,
        exampleController: exampleController,
        pronunciationController: pronunciationController,
        hintController: hintController,
        tags: tags,
        frontFocusNode: frontFocusNode,
        backFocusNode: backFocusNode,
        exampleFocusNode: exampleFocusNode,
        pronunciationFocusNode: pronunciationFocusNode,
        hintFocusNode: hintFocusNode,
        frontMaxChars: frontMaxChars,
        backMaxChars: backMaxChars,
        onToggleSaveAndAddAnother: onToggleSaveAndAddAnother,
        onToggleDetails: onToggleDetails,
        onAddTag: onAddTag,
        onRemoveTag: onRemoveTag,
        onDraftChanged: onDraftChanged,
        saveFailure: saveFailure,
        onRetrySave: onRetrySave,
        onClose: onClose,
        onSave: onSave,
        onDelete: onDelete,
        onConfirmDiscard: onConfirmDiscard,
        saveFailureFallbackMessage: saveFailureFallbackMessage,
        tagsLabel: tagsLabel,
        tagsOptionalLabel: tagsOptionalLabel,
        addTagLabel: addTagLabel,
        currentBreadcrumbLabel: currentBreadcrumbLabel,
      );
}

Widget _buildFlashcardEditorView({
  required BuildContext context,
  required WidgetRef ref,
  required String deckId,
  required String? flashcardId,
  required bool isEditMode,
  required bool didPrefillCard,
  required void Function(FlashcardDetail detail) onHydrateFromDetail,
  required bool isSaving,
  required bool canSave,
  required bool hasUnsavedChanges,
  required bool detailsOpen,
  required bool saveAndAddAnother,
  required GlobalKey<FormState> formKey,
  required TextEditingController frontController,
  required TextEditingController backController,
  required TextEditingController exampleController,
  required TextEditingController pronunciationController,
  required TextEditingController hintController,
  required List<String> tags,
  required FocusNode frontFocusNode,
  required FocusNode backFocusNode,
  required FocusNode exampleFocusNode,
  required FocusNode pronunciationFocusNode,
  required FocusNode hintFocusNode,
  required int frontMaxChars,
  required int backMaxChars,
  required ValueChanged<bool> onToggleSaveAndAddAnother,
  required VoidCallback onToggleDetails,
  required VoidCallback onAddTag,
  required ValueChanged<String> onRemoveTag,
  required VoidCallback onDraftChanged,
  required Failure? saveFailure,
  required VoidCallback onRetrySave,
  required VoidCallback onClose,
  required VoidCallback onSave,
  required VoidCallback onDelete,
  required Future<void> Function() onConfirmDiscard,
  required String saveFailureFallbackMessage,
  required String tagsLabel,
  required String tagsOptionalLabel,
  required String addTagLabel,
  required String currentBreadcrumbLabel,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final AsyncValue<FlashcardListDetail> deckContextQuery = ref.watch(
    flashcardEditorContextQueryProvider(deckId),
  );
  final AsyncValue<FlashcardDetail>? flashcardQuery = isEditMode
      ? ref.watch(flashcardEditorDetailQueryProvider(flashcardId!))
      : null;

  final FlashcardListDetail? deckDetail = deckContextQuery.asData?.value;
  final FlashcardDetail? flashcardDetail = flashcardQuery?.asData?.value;

  if (deckContextQuery.hasError || flashcardQuery?.hasError == true) {
    return _buildFlashcardEditorLoadErrorScaffold(
      context: context,
      l10n: l10n,
      isEditMode: isEditMode,
      onBack: onClose,
      onRetry: onRetrySave,
    );
  }

  if (deckContextQuery.isLoading ||
      (flashcardQuery?.isLoading == true && isEditMode)) {
    return _buildFlashcardEditorLoadingScaffold(
      context: context,
      l10n: l10n,
      isEditMode: isEditMode,
      onClose: onClose,
    );
  }

  if (isEditMode && flashcardDetail != null && !didPrefillCard) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onHydrateFromDetail(flashcardDetail);
    });
    return _buildFlashcardEditorLoadingScaffold(
      context: context,
      l10n: l10n,
      isEditMode: isEditMode,
      onClose: onClose,
    );
  }

  if (deckDetail == null) {
    return _buildFlashcardEditorLoadingScaffold(
      context: context,
      l10n: l10n,
      isEditMode: isEditMode,
      onClose: onClose,
    );
  }

  return _buildFlashcardEditorScaffold(
    context: context,
    l10n: l10n,
    isEditMode: isEditMode,
    isSaving: isSaving,
    canSave: canSave,
    hasUnsavedChanges: hasUnsavedChanges,
    detailsOpen: detailsOpen,
    saveAndAddAnother: saveAndAddAnother,
    formKey: formKey,
    deckDetail: deckDetail,
    flashcardDetail: flashcardDetail,
    frontController: frontController,
    backController: backController,
    exampleController: exampleController,
    pronunciationController: pronunciationController,
    hintController: hintController,
    tags: tags,
    frontFocusNode: frontFocusNode,
    backFocusNode: backFocusNode,
    exampleFocusNode: exampleFocusNode,
    pronunciationFocusNode: pronunciationFocusNode,
    hintFocusNode: hintFocusNode,
    frontMaxChars: frontMaxChars,
    backMaxChars: backMaxChars,
    onToggleSaveAndAddAnother: onToggleSaveAndAddAnother,
    onToggleDetails: onToggleDetails,
    onAddTag: onAddTag,
    onRemoveTag: onRemoveTag,
    onDraftChanged: onDraftChanged,
    saveFailure: saveFailure,
    onRetrySave: onRetrySave,
    onClose: onClose,
    onSave: onSave,
    onDelete: onDelete,
    onConfirmDiscard: onConfirmDiscard,
    deleteReviewCount: flashcardDetail?.progress?.reviewCount ?? 0,
    saveFailureFallbackMessage: saveFailureFallbackMessage,
    tagsLabel: tagsLabel,
    tagsOptionalLabel: tagsOptionalLabel,
    addTagLabel: addTagLabel,
    currentBreadcrumbLabel: currentBreadcrumbLabel,
  );
}

Widget _buildFlashcardEditorLoadingScaffold({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool isEditMode,
  required VoidCallback onClose,
}) => MxScaffold(
  appBar: MxAppBar(
    leading: MxIconButton(
      icon: Icons.close,
      tooltip: l10n.commonClose,
      onPressed: onClose,
    ),
    titleText: isEditMode
        ? l10n.flashcardsEditTitle
        : l10n.flashcardEditorTitle,
  ),
  body: const FlashcardEditorLoadingState(),
);

Widget _buildFlashcardEditorLoadErrorScaffold({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool isEditMode,
  required VoidCallback onBack,
  required VoidCallback onRetry,
}) => MxScaffold(
  appBar: MxAppBar(
    leading: MxIconButton(
      icon: Icons.close,
      tooltip: l10n.commonClose,
      onPressed: onBack,
    ),
    titleText: isEditMode
        ? l10n.flashcardsEditTitle
        : l10n.flashcardEditorTitle,
  ),
  body: FlashcardEditorLoadErrorState(
    title: l10n.flashcardsLoadErrorTitle,
    message: l10n.flashcardsLoadErrorMessage,
    backLabel: l10n.flashcardsLoadErrorBackAction,
    retryLabel: l10n.commonRetry,
    onBack: onBack,
    onRetry: onRetry,
  ),
);

Widget _buildFlashcardEditorScaffold({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool isEditMode,
  required bool isSaving,
  required bool canSave,
  required bool hasUnsavedChanges,
  required bool detailsOpen,
  required bool saveAndAddAnother,
  required GlobalKey<FormState> formKey,
  required FlashcardListDetail deckDetail,
  required FlashcardDetail? flashcardDetail,
  required TextEditingController frontController,
  required TextEditingController backController,
  required TextEditingController exampleController,
  required TextEditingController pronunciationController,
  required TextEditingController hintController,
  required List<String> tags,
  required FocusNode frontFocusNode,
  required FocusNode backFocusNode,
  required FocusNode exampleFocusNode,
  required FocusNode pronunciationFocusNode,
  required FocusNode hintFocusNode,
  required int frontMaxChars,
  required int backMaxChars,
  required ValueChanged<bool> onToggleSaveAndAddAnother,
  required VoidCallback onToggleDetails,
  required VoidCallback onAddTag,
  required ValueChanged<String> onRemoveTag,
  required VoidCallback onDraftChanged,
  required Failure? saveFailure,
  required VoidCallback onRetrySave,
  required VoidCallback onClose,
  required VoidCallback onSave,
  required VoidCallback onDelete,
  required Future<void> Function() onConfirmDiscard,
  required int deleteReviewCount,
  required String saveFailureFallbackMessage,
  required String tagsLabel,
  required String tagsOptionalLabel,
  required String addTagLabel,
  required String currentBreadcrumbLabel,
}) => PopScope(
  canPop: !isSaving && !hasUnsavedChanges,
  onPopInvokedWithResult: (bool didPop, Object? _) async {
    if (didPop || isSaving || !hasUnsavedChanges) {
      return;
    }
    await onConfirmDiscard();
  },
  child: MxFormScaffold(
    appBar: MxAppBar(
      leading: MxIconButton(
        icon: Icons.close,
        tooltip: l10n.commonClose,
        onPressed: isSaving ? null : onClose,
      ),
      titleText: isEditMode
          ? l10n.flashcardsEditTitle
          : l10n.flashcardEditorTitle,
      actions: <Widget>[
        FlashcardEditorSaveButton(
          label: l10n.commonSave,
          busy: isSaving,
          enabled: canSave,
          showIcon: false,
          size: MxButtonSize.xsmall,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    ),
    bottomAction: FlashcardEditorBottomBar(
      cancelLabel: l10n.commonCancel,
      saveLabel: isEditMode
          ? l10n.flashcardsSaveChanges
          : l10n.flashcardEditorSaveCardLabel,
      helperLabel: isEditMode
          ? l10n.flashcardsEditSaveHelperText
          : l10n.flashcardEditorSaveHelperText,
      isSaving: isSaving,
      saveEnabled: canSave,
      onCancel: isSaving ? null : onClose,
      onSave: isSaving ? null : onSave,
    ),
    body: Form(
      key: formKey,
      child: FlashcardEditorBody(
        detail: deckDetail,
        isEditMode: isEditMode,
        detailsOpen: detailsOpen,
        frontController: frontController,
        backController: backController,
        exampleController: exampleController,
        pronunciationController: pronunciationController,
        hintController: hintController,
        tags: tags,
        frontFocusNode: frontFocusNode,
        backFocusNode: backFocusNode,
        exampleFocusNode: exampleFocusNode,
        pronunciationFocusNode: pronunciationFocusNode,
        hintFocusNode: hintFocusNode,
        frontMaxChars: frontMaxChars,
        backMaxChars: backMaxChars,
        onToggleDetails: onToggleDetails,
        onAddTag: onAddTag,
        onRemoveTag: onRemoveTag,
        onDraftChanged: onDraftChanged,
        saveFailure: saveFailure,
        onRetrySave: onRetrySave,
        isSaving: isSaving,
        showSaveAndAddAnother: !isEditMode,
        saveAndAddAnother: saveAndAddAnother,
        onSaveAndAddAnotherChanged: onToggleSaveAndAddAnother,
        showDangerZone: isEditMode,
        onDelete: onDelete,
        deleteReviewCount:
            flashcardDetail?.progress?.reviewCount ?? deleteReviewCount,
        saveFailureFallbackMessage: saveFailureFallbackMessage,
        tagsLabel: tagsLabel,
        tagsOptionalLabel: tagsOptionalLabel,
        addTagLabel: addTagLabel,
        currentBreadcrumbLabel: currentBreadcrumbLabel,
      ),
    ),
  ),
);
