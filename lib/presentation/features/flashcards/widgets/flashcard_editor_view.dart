import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_sections.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_form_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

class FlashcardEditorView extends ConsumerStatefulWidget {
  const FlashcardEditorView({required this.deckId, super.key});

  final String deckId;

  @override
  ConsumerState<FlashcardEditorView> createState() =>
      _FlashcardEditorViewState();
}

class _FlashcardEditorViewState extends ConsumerState<FlashcardEditorView> {
  static const int _frontMaxChars = 60;
  static const int _backMaxChars = 240;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _pronunciationController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  final FocusNode _frontFocusNode = FocusNode();
  final FocusNode _backFocusNode = FocusNode();
  final FocusNode _exampleFocusNode = FocusNode();
  final FocusNode _pronunciationFocusNode = FocusNode();
  final FocusNode _hintFocusNode = FocusNode();

  bool _detailsOpen = false;
  Failure? _saveFailure;

  @override
  void initState() {
    super.initState();
    _frontController.addListener(_handleDraftChanged);
    _backController.addListener(_handleDraftChanged);
    _exampleController.addListener(_handleDraftChanged);
    _pronunciationController.addListener(_handleDraftChanged);
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
    _pronunciationController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _hintController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
    _exampleFocusNode.dispose();
    _pronunciationFocusNode.dispose();
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
      _pronunciationController.text.isNotEmpty ||
      _hintController.text.isNotEmpty ||
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
    final bool isSaving =
        ref.watch(flashcardEditorControllerProvider).isLoading;

    if (contextQuery.hasError) {
      return _buildNotFoundScaffold(context, l10n);
    }

    return _buildEditorScaffold(context, l10n, detail, isSaving);
  }

  Widget _buildNotFoundScaffold(
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
          _SaveButton(
            label: l10n.commonSave,
            busy: isSaving,
            enabled: _canSave,
            showIcon: false,
            size: MxButtonSize.xsmall,
            onPressed: isSaving ? null : _save,
          ),
        ],
      ),
      bottomAction: _EditorBottomBar(
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
        child: _EditorBody(
          detail: detail,
          detailsOpen: _detailsOpen,
          frontController: _frontController,
          backController: _backController,
          exampleController: _exampleController,
          pronunciationController: _pronunciationController,
          hintController: _hintController,
          frontFocusNode: _frontFocusNode,
          backFocusNode: _backFocusNode,
          exampleFocusNode: _exampleFocusNode,
          pronunciationFocusNode: _pronunciationFocusNode,
          hintFocusNode: _hintFocusNode,
          frontMaxChars: _frontMaxChars,
          backMaxChars: _backMaxChars,
          onToggleDetails: _toggleDetails,
          onDraftChanged: _handleDraftChanged,
          saveFailure: _saveFailure,
          onRetrySave: _save,
          isSaving: isSaving,
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
          pronunciation: _pronunciationController.text,
          hint: _hintController.text,
        );

    if (!mounted) {
      return;
    }

    result.fold(
      (Failure failure) => setState(() => _saveFailure = failure),
      (Flashcard _) {
        showMxSnackbar(
          context,
          message: l10n.flashcardsCreatedMessage,
        );
        _dismissEditor();
      },
    );
  }

  void _dismissEditor() {
    final Route<Object?>? route = ModalRoute.of(context);
    if (route == null) {
      return;
    }
    Navigator.of(context).removeRoute(route);
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.detail,
    required this.detailsOpen,
    required this.frontController,
    required this.backController,
    required this.exampleController,
    required this.pronunciationController,
    required this.hintController,
    required this.frontFocusNode,
    required this.backFocusNode,
    required this.exampleFocusNode,
    required this.pronunciationFocusNode,
    required this.hintFocusNode,
    required this.frontMaxChars,
    required this.backMaxChars,
    required this.onToggleDetails,
    required this.onDraftChanged,
    required this.saveFailure,
    required this.onRetrySave,
    required this.isSaving,
  });

  final FlashcardListDetail? detail;
  final bool detailsOpen;
  final TextEditingController frontController;
  final TextEditingController backController;
  final TextEditingController exampleController;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final FocusNode frontFocusNode;
  final FocusNode backFocusNode;
  final FocusNode exampleFocusNode;
  final FocusNode pronunciationFocusNode;
  final FocusNode hintFocusNode;
  final int frontMaxChars;
  final int backMaxChars;
  final VoidCallback onToggleDetails;
  final VoidCallback onDraftChanged;
  final Failure? saveFailure;
  final VoidCallback onRetrySave;
  final bool isSaving;

  List<MxBreadcrumbSegment> _buildBreadcrumbSegments(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (detail == null) {
      return <MxBreadcrumbSegment>[
        MxBreadcrumbSegment(label: l10n.flashcardEditorBreadcrumbFolder),
      ];
    }
    return detail!.breadcrumb
        .map(
          (FolderBreadcrumbSegment seg) => MxBreadcrumbSegment(
            label: seg.name,
            onTap: () => context.pushFolderDetail(seg.id),
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedOpacity(
      opacity: isSaving ? 0.92 : 1,
      duration: DurationTokens.fast,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxBreadcrumb(
            segments: <MxBreadcrumbSegment>[
              MxBreadcrumbSegment(
                label: l10n.libraryTitle,
                onTap: () => context.goLibrary(),
              ),
              ..._buildBreadcrumbSegments(context, l10n),
              MxBreadcrumbSegment(
                label: detail?.deck.name ?? l10n.flashcardEditorBreadcrumbDeck,
              ),
              MxBreadcrumbSegment(label: l10n.flashcardEditorBreadcrumbCurrent),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlashcardEditorDeckChip(
                label:
                    detail?.deck.name ??
                    l10n.flashcardEditorDestinationDeckLabel,
              ),
              const SizedBox(width: SpacingTokens.sm),
              FlashcardEditorRequiredMarker(
                label: l10n.flashcardEditorRequiredWord,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          FlashcardEditorFieldSection(
            title: l10n.flashcardEditorFrontHeading,
            requiredLabel: l10n.flashcardEditorRequiredWord,
            countLabel:
                '${StringUtils.trimmed(frontController.text).length} / $frontMaxChars',
            placeholder: l10n.flashcardEditorFrontPlaceholder,
            controller: frontController,
            focusNode: frontFocusNode,
            validator: (String? value) {
              final String trimmed = StringUtils.trimmed(value ?? '');
              return trimmed.isEmpty ? l10n.flashcardEditorFrontError : null;
            },
            trailingIcon: Icons.mic_none_outlined,
            autofocus: true,
            minLines: 4,
            onChanged: (_) => onDraftChanged(),
          ),
          const SizedBox(height: SpacingTokens.md),
          FlashcardEditorFieldSection(
            title: l10n.flashcardEditorBackHeading,
            requiredLabel: l10n.flashcardEditorRequiredWord,
            countLabel:
                '${StringUtils.trimmed(backController.text).length} / $backMaxChars',
            placeholder: l10n.flashcardEditorBackPlaceholder,
            controller: backController,
            focusNode: backFocusNode,
            validator: (String? value) {
              final String trimmed = StringUtils.trimmed(value ?? '');
              return trimmed.isEmpty ? l10n.flashcardEditorBackError : null;
            },
            trailingIcon: Icons.mic_none_outlined,
            minLines: 4,
            onChanged: (_) => onDraftChanged(),
          ),
          const SizedBox(height: SpacingTokens.lg),
          FlashcardEditorDetailsSection(
            title: l10n.flashcardEditorMoreFieldsLabel,
            subtitle: l10n.flashcardEditorMoreFieldsSummary,
            expanded: detailsOpen,
            exampleLabel: l10n.flashcardEditorExampleLabel,
            examplePlaceholder: l10n.flashcardEditorSampleExample,
            pronunciationLabel: l10n.flashcardEditorPronunciationLabel,
            pronunciationPlaceholder: l10n.flashcardEditorSamplePronunciation,
            hintLabel: l10n.flashcardEditorHintLabel,
            hintPlaceholder: l10n.flashcardEditorSampleHint,
            exampleController: exampleController,
            pronunciationController: pronunciationController,
            hintController: hintController,
            exampleFocusNode: exampleFocusNode,
            pronunciationFocusNode: pronunciationFocusNode,
            hintFocusNode: hintFocusNode,
            onToggle: onToggleDetails,
            onChanged: (_) => onDraftChanged(),
          ),
          ..._buildSaveFailureWidgets(context),
        ],
      ),
    );
  }

  List<Widget> _buildSaveFailureWidgets(BuildContext context) {
    final Failure? failure = saveFailure;
    if (failure == null) {
      return const <Widget>[];
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    return <Widget>[
      const SizedBox(height: SpacingTokens.lg),
      FlashcardEditorSaveFailedBanner(
        message: l10n.failureMessage(
          failure,
          fallback: l10n.flashcardEditorSaveFailedMessage,
        ),
        retryLabel: l10n.commonRetry,
        onRetry: onRetrySave,
      ),
    ];
  }
}

class _EditorBottomBar extends StatelessWidget {
  const _EditorBottomBar({
    required this.cancelLabel,
    required this.saveLabel,
    required this.helperLabel,
    required this.isSaving,
    required this.saveEnabled,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final String helperLabel;
  final bool isSaving;
  final bool saveEnabled;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Row(
        children: <Widget>[
          MxSecondaryButton(
            label: cancelLabel,
            onPressed: onCancel,
            variant: MxSecondaryVariant.outlined,
            size: MxButtonSize.medium,
          ),
          const Spacer(),
          _SaveButton(
            label: saveLabel,
            busy: isSaving,
            enabled: saveEnabled,
            showIcon: true,
            size: MxButtonSize.medium,
            onPressed: onSave,
          ),
        ],
      ),
      const SizedBox(height: SpacingTokens.sm),
      FlashcardEditorBottomHelperText(label: helperLabel),
    ],
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.busy,
    required this.enabled,
    required this.showIcon,
    required this.size,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final bool enabled;
  final bool showIcon;
  final MxButtonSize size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => MxPrimaryButton(
    label: label,
    icon: showIcon ? (busy ? Icons.hourglass_top : Icons.check) : null,
    onPressed: enabled ? onPressed : null,
    size: size,
  );
}
