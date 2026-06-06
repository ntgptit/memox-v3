import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_body.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_form_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

class FlashcardEditorView extends ConsumerStatefulWidget {
  const FlashcardEditorView({required this.deckId, super.key});

  final String deckId;

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

  bool _detailsOpen = false;
  Failure? _saveFailure;

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

  bool get _hasUnsavedChanges =>
      _frontController.text.isNotEmpty ||
      _backController.text.isNotEmpty ||
      _exampleController.text.isNotEmpty ||
      _pronController.text.isNotEmpty ||
      _hintController.text.isNotEmpty ||
      _tags.isNotEmpty ||
      _detailsOpen;

  bool get _canSave =>
      !_isSaving &&
      StringUtils.trimmed(_frontController.text).isNotEmpty &&
      StringUtils.trimmed(_backController.text).isNotEmpty;

  bool get _isSaving => ref.read(flashcardEditorControllerProvider).isLoading;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FlashcardListDetail> contextQuery = ref.watch(
      flashcardEditorContextQueryProvider(widget.deckId),
    );
    final FlashcardListDetail? detail = contextQuery.asData?.value;
    final bool isSaving = ref
        .watch(flashcardEditorControllerProvider)
        .isLoading;

    if (contextQuery.hasError) {
      return _buildNotFoundScaffold(context, l10n);
    }

    return _buildEditorScaffold(context, l10n, detail, isSaving);
  }

  Widget _buildNotFoundScaffold(BuildContext context, AppLocalizations l10n) =>
      MxScaffold(
        appBar: MxAppBar(
          leading: MxIconButton(
            icon: Icons.close,
            tooltip: l10n.commonClose,
            onPressed: () async {
              await Navigator.of(context).maybePop();
            },
          ),
          titleText: l10n.flashcardEditorTitle,
        ),
        body: MxErrorState(
          title: l10n.errorNotFound,
          message: l10n.errorNotFound,
          retryLabel: l10n.commonBack,
          onRetry: () async {
            await Navigator.of(context).maybePop();
          },
        ),
      );

  Widget _buildEditorScaffold(
    BuildContext context,
    AppLocalizations l10n,
    FlashcardListDetail? detail,
    bool isSaving,
  ) => PopScope(
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
        titleText: l10n.flashcardEditorTitle,
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
        saveLabel: l10n.flashcardEditorSaveCardLabel,
        helperLabel: l10n.flashcardEditorSaveHelperText,
        isSaving: isSaving,
        saveEnabled: _canSave,
        onCancel: isSaving ? null : _close,
        onSave: isSaving ? null : _save,
      ),
      body: Form(
        key: _formKey,
        child: FlashcardEditorBody(
          detail: detail,
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
          tagsLabel: l10n.flashcardEditorTagsLabel,
          tagsOptionalLabel: l10n.flashcardEditorTagsOptionalLabel,
          addTagLabel: l10n.flashcardEditorAddTagLabel,
        ),
      ),
    ),
  );

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
        await Navigator.of(context).maybePop();
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
    _dismissEditor();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final Result<Flashcard> result = await ref
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
      showMxSnackbar(context, message: l10n.flashcardsCreatedMessage);
      _dismissEditor();
    });
  }

  void _dismissEditor() {
    final Route<Object?>? route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    Navigator.of(context).removeRoute(route);
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
}
