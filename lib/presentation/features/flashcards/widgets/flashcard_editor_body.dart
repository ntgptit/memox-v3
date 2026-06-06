import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_sections.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_tags_section.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorBody extends StatelessWidget {
  const FlashcardEditorBody({
    required this.detail,
    required this.detailsOpen,
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
    required this.onToggleDetails,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onDraftChanged,
    required this.saveFailure,
    required this.onRetrySave,
    required this.isSaving,
    required this.tagsLabel,
    required this.tagsOptionalLabel,
    required this.addTagLabel,
    super.key,
  });

  final FlashcardListDetail? detail;
  final bool detailsOpen;
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
  final VoidCallback onToggleDetails;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;
  final VoidCallback onDraftChanged;
  final Failure? saveFailure;
  final VoidCallback onRetrySave;
  final bool isSaving;
  final String tagsLabel;
  final String tagsOptionalLabel;
  final String addTagLabel;

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
          _buildHeader(context, l10n),
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
            pronunciationTrailingIcon: Icons.volume_up_outlined,
            onToggle: onToggleDetails,
            onChanged: (_) => onDraftChanged(),
          ),
          const SizedBox(height: SpacingTokens.lg),
          FlashcardEditorTagsSection(
            title: tagsLabel,
            optionalLabel: tagsOptionalLabel,
            addTagLabel: addTagLabel,
            tags: tags,
            onAddTag: onAddTag,
            onRemoveTag: onRemoveTag,
          ),
          ..._buildSaveFailureWidgets(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) => Column(
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
                detail?.deck.name ?? l10n.flashcardEditorDestinationDeckLabel,
          ),
          const SizedBox(width: SpacingTokens.sm),
          FlashcardEditorRequiredMarker(
            label: l10n.flashcardEditorRequiredWord,
          ),
        ],
      ),
    ],
  );

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

class FlashcardEditorBottomBar extends StatelessWidget {
  const FlashcardEditorBottomBar({
    required this.cancelLabel,
    required this.saveLabel,
    required this.helperLabel,
    required this.isSaving,
    required this.saveEnabled,
    required this.onCancel,
    required this.onSave,
    super.key,
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
          FlashcardEditorSaveButton(
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

class FlashcardEditorSaveButton extends StatelessWidget {
  const FlashcardEditorSaveButton({
    required this.label,
    required this.busy,
    required this.enabled,
    required this.showIcon,
    required this.size,
    required this.onPressed,
    super.key,
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
