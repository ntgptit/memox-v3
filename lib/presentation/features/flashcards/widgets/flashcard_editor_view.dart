import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_body.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

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
    final AsyncValue<FlashcardListDetail> deckContextQuery = ref.watch(
      flashcardEditorContextQueryProvider(widget.deckId),
    );
    final AsyncValue<FlashcardDetail>? flashcardQuery = _isEditMode
        ? ref.watch(flashcardEditorDetailQueryProvider(widget.flashcardId!))
        : null;

    final FlashcardListDetail? deckDetail = deckContextQuery.asData?.value;
    final FlashcardDetail? flashcardDetail = flashcardQuery?.asData?.value;

    if (deckContextQuery.hasError || flashcardQuery?.hasError == true) {
      return _buildLoadErrorScaffold(context, l10n);
    }

    if (deckContextQuery.isLoading ||
        (flashcardQuery?.isLoading == true && _isEditMode)) {
      return _buildLoadingScaffold(context, l10n);
    }

    if (_isEditMode && flashcardDetail != null && !_didPrefillCard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (_didPrefillCard) {
          return;
        }
        _hydrateFromDetail(flashcardDetail);
      });
      return _buildLoadingScaffold(context, l10n);
    }

    if (deckDetail == null) {
      return _buildLoadingScaffold(context, l10n);
    }

    return _buildEditorScaffold(
      context,
      l10n,
      deckDetail: deckDetail,
      flashcardDetail: flashcardDetail,
    );
  }

  Widget _buildLoadingScaffold(
    BuildContext context,
    AppLocalizations l10n,
  ) => MxScaffold(
    appBar: MxAppBar(
      leading: MxIconButton(
        icon: Icons.close,
        tooltip: l10n.commonClose,
        onPressed: () async {
          await Navigator.of(context).maybePop();
        },
      ),
      titleText: _isEditMode ? l10n.flashcardsEditTitle : l10n.flashcardEditorTitle,
    ),
    body: const _FlashcardEditorLoadingState(),
  );

  Widget _buildLoadErrorScaffold(
    BuildContext context,
    AppLocalizations l10n,
  ) => MxScaffold(
    appBar: MxAppBar(
      leading: MxIconButton(
        icon: Icons.close,
        tooltip: l10n.commonClose,
        onPressed: () async {
          await Navigator.of(context).maybePop();
        },
      ),
      titleText: _isEditMode ? l10n.flashcardsEditTitle : l10n.flashcardEditorTitle,
    ),
    body: _FlashcardEditorLoadErrorState(
      title: l10n.flashcardsLoadErrorTitle,
      message: l10n.flashcardsLoadErrorMessage,
      backLabel: l10n.flashcardsLoadErrorBackAction,
      retryLabel: l10n.commonRetry,
      onBack: () async {
        await Navigator.of(context).maybePop();
      },
      onRetry: _retryLoad,
    ),
  );

  Widget _buildEditorScaffold(
    BuildContext context,
    AppLocalizations l10n, {
    required FlashcardListDetail deckDetail,
    required FlashcardDetail? flashcardDetail,
  }) => PopScope(
    canPop: !isSaving && !_hasUnsavedChanges,
    onPopInvokedWithResult: (bool didPop, Object? _) async {
      if (didPop || isSaving || !_hasUnsavedChanges) {
        return;
      }
      await _confirmDiscard();
    },
    child: MxFormScaffold(
      appBar: MxAppBar(
        leading: MxIconButton(
          icon: Icons.close,
          tooltip: l10n.commonClose,
          onPressed: isSaving ? null : _close,
        ),
        titleText: _isEditMode ? l10n.flashcardsEditTitle : l10n.flashcardEditorTitle,
        actions: <Widget>[
          FlashcardEditorSaveButton(
            label: l10n.commonSave,
            busy: isSaving,
            enabled: _canSave,
            showIcon: false,
            size: MxButtonSize.xsmall,
            onPressed: isSaving ? null : _save,
          ),
        ],
      ),
      bottomAction: FlashcardEditorBottomBar(
        cancelLabel: l10n.commonCancel,
        saveLabel: _isEditMode ? l10n.flashcardsSaveChanges : l10n.flashcardEditorSaveCardLabel,
        helperLabel: _isEditMode
            ? l10n.flashcardsEditSaveHelperText
            : l10n.flashcardEditorSaveHelperText,
        isSaving: isSaving,
        saveEnabled: _canSave,
        onCancel: isSaving ? null : _close,
        onSave: isSaving ? null : _save,
      ),
      body: Form(
        key: _formKey,
        child: FlashcardEditorBody(
          detail: deckDetail,
          isEditMode: _isEditMode,
          detailsOpen: _detailsOpen,
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
          onToggleDetails: _toggleDetails,
          onAddTag: _addTag,
          onRemoveTag: _removeTag,
          onDraftChanged: _handleDraftChanged,
          saveFailure: _saveFailure,
          onRetrySave: _save,
          isSaving: isSaving,
          showSaveAndAddAnother: !_isEditMode,
          saveAndAddAnother: _saveAndAddAnother,
          onSaveAndAddAnotherChanged: _toggleSaveAndAddAnother,
          showDangerZone: _isEditMode,
          onDelete: _confirmDelete,
          deleteReviewCount: flashcardDetail?.progress?.reviewCount ?? 0,
          saveFailureFallbackMessage: _isEditMode
              ? l10n.flashcardsEditSaveFailedMessage
              : l10n.flashcardEditorSaveFailedMessage,
          tagsLabel: l10n.flashcardEditorTagsLabel,
          tagsOptionalLabel: l10n.flashcardEditorTagsOptionalLabel,
          addTagLabel: l10n.flashcardEditorAddTagLabel,
          currentBreadcrumbLabel: _isEditMode
              ? l10n.flashcardsEditTitle
              : l10n.flashcardEditorBreadcrumbCurrent,
        ),
      ),
    ),
  );

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
      _detailsOpen = detail.flashcard.exampleSentence != null ||
          detail.flashcard.pronunciation != null ||
          detail.flashcard.hint != null ||
          detail.tags.isNotEmpty;
      _initialFront = StringUtils.trimmed(detail.flashcard.front);
      _initialBack = StringUtils.trimmed(detail.flashcard.back);
      _initialExample = StringUtils.trimmed(detail.flashcard.exampleSentence ?? '');
      _initialPronunciation = StringUtils.trimmed(detail.flashcard.pronunciation ?? '');
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
      final FlashcardProgressEditPolicy? policy = await _showProgressPolicyDialog(
        context,
        l10n,
      );
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
    if (!mounted) {
      return;
    }
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
    if (_isEditMode) {
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

  Future<FlashcardProgressEditPolicy?> _showProgressPolicyDialog(
    BuildContext context,
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
}

class _FlashcardEditorLoadingState extends StatelessWidget {
  const _FlashcardEditorLoadingState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      children: <Widget>[
        const MxSkeleton(height: 14, width: 180),
        const SizedBox(height: SpacingTokens.sm),
        const MxSkeleton(height: 10, width: 120),
        const SizedBox(height: SpacingTokens.lg),
        _skeletonField(),
        const SizedBox(height: SpacingTokens.md),
        _skeletonField(),
        const SizedBox(height: SpacingTokens.lg),
        _skeletonField(lines: 2),
        const SizedBox(height: SpacingTokens.lg),
        Row(
          children: <Widget>[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: RadiusTokens.brFull,
                ),
              ),
            const SizedBox(width: SpacingTokens.sm),
            const Expanded(child: MxSkeleton(height: 12)),
          ],
        ),
      ],
    );
  }

  Widget _skeletonField({int lines = 1}) {
    final List<Widget> children = <Widget>[
      const MxSkeleton(height: 12, width: 100),
      const SizedBox(height: SpacingTokens.sm),
    ];
    for (int index = 0; index < lines; index++) {
      children.add(const MxSkeleton(height: 56));
      if (index != lines - 1) {
        children.add(const SizedBox(height: SpacingTokens.sm));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _FlashcardEditorLoadErrorState extends StatelessWidget {
  const _FlashcardEditorLoadErrorState({
    required this.title,
    required this.message,
    required this.backLabel,
    required this.retryLabel,
    required this.onBack,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String backLabel;
  final String retryLabel;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.40),
                  borderRadius: RadiusTokens.brMd,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.cloud_off_outlined, color: scheme.error),
              ),
              const SizedBox(height: SpacingTokens.md),
              MxText(
                title,
                role: MxTextRole.titleMedium,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                message,
                role: MxTextRole.bodyMedium,
                color: scheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MxSecondaryButton(
                      label: backLabel,
                      onPressed: onBack,
                      variant: MxSecondaryVariant.outlined,
                      size: MxButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: MxPrimaryButton(
                      label: retryLabel,
                      onPressed: onRetry,
                      size: MxButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
