import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_view_parts.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

class FlashcardEditorView extends ConsumerStatefulWidget {
  const FlashcardEditorView({
    required this.deckId,
    this.flashcardId,
    super.key,
  });

  final String deckId;
  final String? flashcardId;

  @override
  ConsumerState<FlashcardEditorView> createState() => _FlashcardEditorShell();
}

class _FlashcardEditorShell extends ConsumerState<FlashcardEditorView> {
  static const int _frontMaxChars = 60;
  static const int _backMaxChars = 240;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _pronController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final List<String> _tags = <String>[];
  final FocusNode _frontFocusNode = FocusNode();
  final FocusNode _backFocusNode = FocusNode();
  final FocusNode _exampleFocusNode = FocusNode();
  final FocusNode _pronFocusNode = FocusNode();
  final FocusNode _hintFocusNode = FocusNode();

  String _initialFront = '';
  String _initialBack = '';
  String _initialExample = '';
  String _initialPronunciation = '';
  String _initialHint = '';
  List<String> _initialTags = <String>[];
  bool _detailsOpen = false;
  bool _saveAndAddAnother = false;
  bool _didPrefillCard = false;
  Failure? _saveFailure;

  bool get _isEditMode => widget.flashcardId?.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _frontController.addListener(_handleDraftChanged);
    _backController.addListener(_handleDraftChanged);
    _exampleController.addListener(_handleDraftChanged);
    _pronController.addListener(_handleDraftChanged);
    _hintController.addListener(_handleDraftChanged);
  }

  @override
  void dispose() {
    _frontController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _backController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _exampleController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _pronController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _hintController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
    _exampleFocusNode.dispose();
    _pronFocusNode.dispose();
    _hintFocusNode.dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    if (!mounted) {
      return;
    }
    setState(() => _saveFailure = null);
  }

  bool get _canSave =>
      !_isSaving &&
      StringUtils.trimmed(_frontController.text).isNotEmpty &&
      StringUtils.trimmed(_backController.text).isNotEmpty;

  bool get _isSaving => ref.read(flashcardEditorControllerProvider).isLoading;

  bool get isSaving => _isSaving;

  bool get _hasUnsavedChanges {
    final String front = StringUtils.trimmed(_frontController.text);
    final String back = StringUtils.trimmed(_backController.text);
    final String example = StringUtils.trimmed(_exampleController.text);
    final String pronunciation = StringUtils.trimmed(_pronController.text);
    final String hint = StringUtils.trimmed(_hintController.text);
    return front != _initialFront ||
        back != _initialBack ||
        example != _initialExample ||
        pronunciation != _initialPronunciation ||
        hint != _initialHint ||
        !_sameTags(_tags, _initialTags);
  }

  bool get _shouldPromptProgressPolicy =>
      _isEditMode &&
      _didPrefillCard &&
      _loadedDetail?.progress?.isFresh == false &&
      _frontBackChanged;

  bool get _frontBackChanged =>
      StringUtils.trimmed(_frontController.text) != _initialFront ||
      StringUtils.trimmed(_backController.text) != _initialBack;

  FlashcardDetail? _loadedDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return FlashcardEditorViewContent(
      deckId: widget.deckId,
      flashcardId: widget.flashcardId,
      isEditMode: _isEditMode,
      didPrefillCard: _didPrefillCard,
      onHydrateFromDetail: _hydrateFromDetail,
      isSaving: isSaving,
      canSave: _canSave,
      hasUnsavedChanges: _hasUnsavedChanges,
      detailsOpen: _detailsOpen,
      saveAndAddAnother: _saveAndAddAnother,
      formKey: _formKey,
      frontController: _frontController,
      backController: _backController,
      exampleController: _exampleController,
      pronunciationController: _pronController,
      hintController: _hintController,
      tags: _tags,
      frontFocusNode: _frontFocusNode,
      backFocusNode: _backFocusNode,
      exampleFocusNode: _exampleFocusNode,
      pronunciationFocusNode: _pronFocusNode,
      hintFocusNode: _hintFocusNode,
      frontMaxChars: _frontMaxChars,
      backMaxChars: _backMaxChars,
      onToggleSaveAndAddAnother: _toggleSaveAndAddAnother,
      onToggleDetails: _toggleDetails,
      onAddTag: _addTag,
      onRemoveTag: _removeTag,
      onDraftChanged: _handleDraftChanged,
      saveFailure: _saveFailure,
      onRetrySave: _retryLoad,
      onClose: _close,
      onSave: _save,
      onDelete: _confirmDelete,
      onConfirmDiscard: _confirmDiscard,
      saveFailureFallbackMessage: _isEditMode
          ? l10n.flashcardsEditSaveFailedMessage
          : l10n.flashcardEditorSaveFailedMessage,
      tagsLabel: l10n.flashcardEditorTagsLabel,
      tagsOptionalLabel: l10n.flashcardEditorTagsOptionalLabel,
      addTagLabel: l10n.flashcardEditorAddTagLabel,
      currentBreadcrumbLabel: _isEditMode
          ? l10n.flashcardsEditTitle
          : l10n.flashcardEditorBreadcrumbCurrent,
    );
  }

  void _hydrateFromDetail(FlashcardDetail detail) {
    setState(() {
      _loadedDetail = detail;
      _frontController.text = detail.flashcard.front;
      _backController.text = detail.flashcard.back;
      _exampleController.text = detail.flashcard.exampleSentence ?? '';
      _pronController.text = detail.flashcard.pronunciation ?? '';
      _hintController.text = detail.flashcard.hint ?? '';
      _tags
        ..clear()
        ..addAll(detail.tags);
      _detailsOpen =
          detail.flashcard.exampleSentence != null ||
          detail.flashcard.pronunciation != null ||
          detail.flashcard.hint != null ||
          detail.tags.isNotEmpty;
      _initialFront = StringUtils.trimmed(detail.flashcard.front);
      _initialBack = StringUtils.trimmed(detail.flashcard.back);
      _initialExample = StringUtils.trimmed(
        detail.flashcard.exampleSentence ?? '',
      );
      _initialPronunciation = StringUtils.trimmed(
        detail.flashcard.pronunciation ?? '',
      );
      _initialHint = StringUtils.trimmed(detail.flashcard.hint ?? '');
      _initialTags = List<String>.from(detail.tags);
      _saveFailure = null;
      _didPrefillCard = true;
    });
  }

  Future<void> _toggleDetails() async {
    if (!mounted) {
      return;
    }
    setState(() => _detailsOpen = !_detailsOpen);
  }

  Future<void> _addTag() async {
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
      if (!mounted) {
        return;
      }
      showMxSnackbar(
        context,
        message: _tagValidationMessage(l10n, validationFailure),
      );
      return;
    }

    final String displayTag = TagValidator.displayValue(rawTag);
    if (_tags.any(
      (String tag) => StringUtils.equalsIgnoreCase(tag, displayTag),
    )) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _tags.add(displayTag));
  }

  void _removeTag(String tag) {
    if (!mounted) {
      return;
    }
    setState(
      () => _tags.removeWhere(
        (String current) => StringUtils.equalsIgnoreCase(current, tag),
      ),
    );
  }

  Future<void> _close() async {
    if (_isSaving) {
      return;
    }
    if (!_hasUnsavedChanges) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    await _confirmDiscard();
  }

  Future<void> _confirmDiscard() async {
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
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_isEditMode && _shouldPromptProgressPolicy) {
      final FlashcardProgressEditPolicy? policy =
          await _showProgressPolicyDialog(l10n);
      if (policy == null) {
        return;
      }
      await _saveDraft(progressPolicy: policy, addAnother: false);
      return;
    }
    await _saveDraft(
      progressPolicy: FlashcardProgressEditPolicy.keepProgress,
      addAnother: _saveAndAddAnother,
    );
  }

  Future<void> _saveDraft({
    required FlashcardProgressEditPolicy progressPolicy,
    required bool addAnother,
  }) async {
    if (_isSaving) {
      return;
    }
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final Result<Flashcard> result = _isEditMode
        ? await ref
              .read(flashcardEditorControllerProvider.notifier)
              .updateFlashcard(
                flashcardId: widget.flashcardId!,
                front: _frontController.text,
                back: _backController.text,
                exampleSentence: _exampleController.text,
                pronunciation: _pronController.text,
                hint: _hintController.text,
                tags: _tags,
                progressPolicy: progressPolicy,
              )
        : await ref
              .read(flashcardEditorControllerProvider.notifier)
              .createFlashcard(
                deckId: widget.deckId,
                front: _frontController.text,
                back: _backController.text,
                exampleSentence: _exampleController.text,
                pronunciation: _pronController.text,
                hint: _hintController.text,
                tags: _tags,
              );

    if (!mounted) {
      return;
    }

    result.fold((Failure failure) => setState(() => _saveFailure = failure), (
      Flashcard _,
    ) {
      if (!_isEditMode && addAnother) {
        _resetDraftForAnotherCard();
        showMxSnackbar(context, message: l10n.flashcardsSavedMessage);
        return;
      }
      showMxSnackbar(
        context,
        message: _isEditMode
            ? l10n.flashcardsUpdatedMessage
            : l10n.flashcardsCreatedMessage,
      );
      Navigator.of(context).pop();
    });
  }

  void _resetDraftForAnotherCard() {
    setState(() {
      _frontController.clear();
      _backController.clear();
      _exampleController.clear();
      _pronController.clear();
      _hintController.clear();
      _tags.clear();
      _detailsOpen = false;
      _initialFront = '';
      _initialBack = '';
      _initialExample = '';
      _initialPronunciation = '';
      _initialHint = '';
      _initialTags = <String>[];
      _saveFailure = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      FocusScope.of(context).requestFocus(_frontFocusNode);
    });
  }

  void _toggleSaveAndAddAnother(bool value) {
    setState(() => _saveAndAddAnother = value);
  }

  Future<void> _confirmDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.flashcardsDeleteCardTitle,
      message:
          '${_loadedDetail?.flashcard.front ?? ''}\n'
          '${_loadedDetail?.flashcard.back ?? ''}\n\n'
          '${l10n.flashcardsDeleteCardMessage(_loadedDetail?.progress?.reviewCount ?? 0)}',
      cancelLabel: l10n.commonCancel,
      confirmLabel: l10n.flashcardsDeleteCardAction,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!mounted) {
      return;
    }

    final Result<void> result = await ref
        .read(flashcardEditorControllerProvider.notifier)
        .deleteFlashcard(flashcardId: widget.flashcardId!);
    if (!mounted) {
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

  Future<void> _retryLoad() async {
    ref.invalidate(flashcardEditorContextQueryProvider(widget.deckId));
    if (_isEditMode && widget.flashcardId != null) {
      ref.invalidate(flashcardEditorDetailQueryProvider(widget.flashcardId!));
      _didPrefillCard = false;
      _loadedDetail = null;
    }
    setState(() => _saveFailure = null);
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

  Future<FlashcardProgressEditPolicy?> _showProgressPolicyDialog(
    AppLocalizations l10n,
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

  bool _sameTags(List<String> current, List<String> original) {
    if (current.length != original.length) {
      return false;
    }
    for (int index = 0; index < current.length; index++) {
      if (!StringUtils.equalsIgnoreCase(current[index], original[index])) {
        return false;
      }
    }
    return true;
  }
}
