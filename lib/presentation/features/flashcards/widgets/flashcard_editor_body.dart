import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_sections.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_editor_tags_section.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorBody extends StatelessWidget {
  const FlashcardEditorBody({
    required this.detail,
    required this.isEditMode,
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
    required this.isSaving,
    required this.showSaveAndAddAnother,
    required this.saveAndAddAnother,
    required this.onSaveAndAddAnotherChanged,
    required this.showDangerZone,
    required this.onDelete,
    required this.deleteReviewCount,
    required this.tagsLabel,
    required this.tagsOptionalLabel,
    required this.addTagLabel,
    required this.currentBreadcrumbLabel,
    this.metaLastEditedAt,
    super.key,
  });

  final FlashcardListDetail? detail;
  final bool isEditMode;
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
  final bool isSaving;
  final bool showSaveAndAddAnother;
  final bool saveAndAddAnother;
  final ValueChanged<bool> onSaveAndAddAnotherChanged;
  final bool showDangerZone;
  final VoidCallback onDelete;
  final int deleteReviewCount;
  final String tagsLabel;
  final String tagsOptionalLabel;
  final String addTagLabel;
  final String currentBreadcrumbLabel;

  /// Edit-mode only: the card's `updated_at`, rendered as a real
  /// "Last edited … · N reviews" meta strip (mock 08). Null in create mode and
  /// when no card is loaded; recall-rate and the History link in the mock are
  /// Future/unavailable and intentionally omitted.
  final DateTime? metaLastEditedAt;

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
            collapsible: !isEditMode,
            staticHeading: l10n.flashcardEditorOptionalDetailsHeading,
            expanded: detailsOpen,
            exampleLabel: l10n.flashcardEditorExampleLabel,
            examplePlaceholder: l10n.flashcardEditorSampleExample,
            pronunciationLabel: l10n.flashcardEditorPronunciationLabel,
            pronunciationPlaceholder: l10n.flashcardEditorSamplePronunciation,
            hintLabel: l10n.flashcardEditorHintLabel,
            hintPlaceholder: l10n.flashcardEditorSampleHint,
            optionalLabel: l10n.flashcardEditorTagsOptionalLabel,
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
          if (showSaveAndAddAnother) ...<Widget>[
            const SizedBox(height: SpacingTokens.sm),
            MxCheckboxRow(
              label: l10n.flashcardsSaveAndAddNextTooltip,
              value: saveAndAddAnother,
              onChanged: onSaveAndAddAnotherChanged,
            ),
          ],
          if (showDangerZone) ...<Widget>[
            const SizedBox(height: SpacingTokens.lg),
            FlashcardEditorDangerZoneSection(
              zoneLabel: l10n.flashcardsEditDangerZoneLabel,
              title: l10n.flashcardsDeleteCardTitle,
              message: l10n.flashcardsDeleteCardMessage(deleteReviewCount),
              actionLabel: l10n.flashcardsDeleteCardAction,
              onAction: onDelete,
            ),
          ],
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
          MxBreadcrumbSegment(label: currentBreadcrumbLabel),
        ],
      ),
      if (isEditMode && metaLastEditedAt != null) ...<Widget>[
        const SizedBox(height: SpacingTokens.sm),
        _FlashcardEditMetaStrip(
          lastEditedAt: metaLastEditedAt!,
          reviewCount: deleteReviewCount,
        ),
      ],
      const SizedBox(height: SpacingTokens.sm),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlashcardEditorDeckChip(
            label:
                detail?.deck.name ?? l10n.flashcardEditorDestinationDeckLabel,
            showChevron: !isEditMode,
          ),
          const SizedBox(width: SpacingTokens.sm),
          FlashcardEditorRequiredMarker(
            label: l10n.flashcardEditorRequiredWord,
          ),
        ],
      ),
    ],
  );
}

/// Edit-mode meta strip (mock 08): a real "Last edited … · N reviews" summary
/// from `updated_at` + the progress review count. Recall-rate and the History
/// link in the mock are Future/unavailable and are not rendered.
class _FlashcardEditMetaStrip extends StatelessWidget {
  const _FlashcardEditMetaStrip({
    required this.lastEditedAt,
    required this.reviewCount,
  });

  final DateTime lastEditedAt;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final RelativeTime relativeTime = RelativeTime.between(
      lastEditedAt,
      DateTime.now(),
    );
    final String relativeLabel = l10n.relativeTimeAgo(
      relativeTime.unit.name,
      relativeTime.count,
    );
    return Container(
      key: const ValueKey<String>('flashcard_edit_meta_strip'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RadiusTokens.brFull,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.schedule_outlined,
            size: SizeTokens.iconXs,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(
            child: MxText(
              l10n.flashcardsEditMeta(reviewCount, relativeLabel),
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardEditorBottomBar extends StatelessWidget {
  const FlashcardEditorBottomBar({
    required this.cancelLabel,
    required this.saveLabel,
    required this.saveIcon,
    required this.helperLabel,
    required this.isSaving,
    required this.saveEnabled,
    required this.onCancel,
    required this.onSave,
    this.banner,
    super.key,
  });

  final String cancelLabel;
  final String saveLabel;
  final IconData saveIcon;
  final String helperLabel;
  final bool isSaving;
  final bool saveEnabled;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  /// Optional save-failure banner rendered just above the action row (mock
  /// 07/08 save-failed).
  final Widget? banner;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      if (banner != null) ...<Widget>[
        banner!,
        const SizedBox(height: SpacingTokens.sm),
      ],
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
            icon: saveIcon,
            enabled: saveEnabled,
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
    required this.enabled,
    required this.size,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final bool enabled;
  final MxButtonSize size;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => MxPrimaryButton(
    label: label,
    icon: icon,
    onPressed: enabled ? onPressed : null,
    size: size,
  );
}
