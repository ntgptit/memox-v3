import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Deck import route for `/library/deck/:deckId/import`.
///
/// V1 now supports CSV paste preview and transactional commit of valid rows
/// only. File picker, Excel, and structured text remain deferred.
class DeckImportScreen extends HookConsumerWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasDeckId = StringUtils.trimmed(deckId).isNotEmpty;
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final MxTextSubmitState csvState = useMxTextSubmitState();
    final FocusNode csvFocusNode = useFocusNode();
    final ValueNotifier<DeckImportPreview?> preview =
        useState<DeckImportPreview?>(null);
    final ValueNotifier<bool> isCommitting = useState<bool>(false);

    void onBack() => Navigator.of(context).pop();

    void previewCsv() {
      if (isCommitting.value) {
        return;
      }
      final FormState? formState = formKey.currentState;
      if (formState != null && !formState.validate()) {
        return;
      }

      final DeckImportPreview nextPreview = ref
          .read(parseDeckImportCsvUseCaseProvider)
          .call(rawCsv: csvState.controller.text);
      preview.value = nextPreview;
    }

    void clearPreviewOnEdit() {
      if (isCommitting.value || preview.value == null) {
        return;
      }
      preview.value = null;
    }

    Future<void> commitPreview() async {
      final DeckImportPreview? currentPreview = preview.value;
      if (isCommitting.value ||
          currentPreview == null ||
          !currentPreview.canCommit) {
        return;
      }

      isCommitting.value = true;

      final Result<int> result = await ref
          .read(commitDeckImportUseCaseProvider)
          .call(deckId: deckId, preview: currentPreview);
      if (!context.mounted) {
        return;
      }

      isCommitting.value = false;

      final AppLocalizations currentL10n = AppLocalizations.of(context);
      result.fold(
        (Failure failure) => showMxSnackbar(
          context,
          message: currentL10n.failureMessage(
            failure,
            fallback: currentL10n.importFailedMessage,
          ),
          isError: true,
        ),
        (int committedCount) {
          showMxSnackbar(
            context,
            message: currentL10n.importSuccessMessage(committedCount),
          );
          unawaited(Navigator.of(context).maybePop());
        },
      );
    }

    return MxScaffold(
      appBar: MxAppBar(
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: l10n.commonBack,
          onPressed: onBack,
        ),
        titleText: l10n.flashcardsImportTitle,
      ),
      body: hasDeckId
          ? _DeckImportBody(
              l10n: l10n,
              formKey: formKey,
              csvState: csvState,
              csvFocusNode: csvFocusNode,
              preview: preview.value,
              isCommitting: isCommitting.value,
              onPreview: previewCsv,
              onCommit: commitPreview,
              onCsvChanged: (_) => clearPreviewOnEdit(),
            )
          : _DeckImportMissingDeckState(l10n: l10n, onBack: onBack),
    );
  }
}

class _DeckImportBody extends StatelessWidget {
  const _DeckImportBody({
    required this.l10n,
    required this.formKey,
    required this.csvState,
    required this.csvFocusNode,
    required this.preview,
    required this.isCommitting,
    required this.onPreview,
    required this.onCommit,
    required this.onCsvChanged,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final MxTextSubmitState csvState;
  final FocusNode csvFocusNode;
  final DeckImportPreview? preview;
  final bool isCommitting;
  final VoidCallback onPreview;
  final VoidCallback onCommit;
  final ValueChanged<String> onCsvChanged;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      MxCallout(message: l10n.flashcardsImportRouteIntroMessage),
      const SizedBox(height: SpacingTokens.lg),
      MxSectionHeader(label: l10n.importSourceTitle),
      const SizedBox(height: SpacingTokens.sm),
      MxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(l10n.importCsvContentLabel, role: MxTextRole.titleSmall),
            const SizedBox(height: SpacingTokens.xs),
            MxText(
              l10n.importCsvRulesText,
              role: MxTextRole.bodyMedium,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.md),
            AbsorbPointer(
              absorbing: isCommitting,
              child: Form(
                key: formKey,
                child: MxTextField(
                  controller: csvState.controller,
                  focusNode: csvFocusNode,
                  hintText: l10n.importCsvHint,
                  minLines: 10,
                  maxLines: 12,
                  validator: (String? value) {
                    final String trimmed = StringUtils.trimmed(value ?? '');
                    if (trimmed.isEmpty) {
                      return l10n.importCsvEmptyMessage;
                    }
                    return null;
                  },
                  onChanged: onCsvChanged,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            MxPrimaryButton(
              label: l10n.importPreviewAction,
              fullWidth: true,
              onPressed: isCommitting ? null : onPreview,
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxSecondaryButton(
              label: preview == null
                  ? l10n.commonImport
                  : l10n.importCommitCardsAction(preview!.rows.length),
              variant: MxSecondaryVariant.outlined,
              fullWidth: true,
              onPressed: preview?.canCommit == true && !isCommitting
                  ? onCommit
                  : null,
            ),
            if (isCommitting) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              MxCallout(message: l10n.importCommittingMessage),
            ],
            if (preview != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.sm),
              MxCallout(
                tone: preview!.canCommit
                    ? MxCalloutTone.info
                    : MxCalloutTone.warning,
                message: preview!.canCommit
                    ? l10n.importPreviewCommitReadyMessage
                    : l10n.importValidationIssuesSubtitle,
              ),
            ],
          ],
        ),
      ),
      if (preview != null) ...<Widget>[
        const SizedBox(height: SpacingTokens.lg),
        MxSectionHeader(label: l10n.importPreviewTitle),
        const SizedBox(height: SpacingTokens.sm),
        MxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(
                l10n.importPreviewSubtitle(preview!.rows.length),
                role: MxTextRole.titleSmall,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                l10n.importPreviewSummary(
                  preview!.rows.length,
                  preview!.issues.length,
                ),
                role: MxTextRole.bodyMedium,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (preview!.issues.isNotEmpty) ...<Widget>[
          MxSectionHeader(label: l10n.importValidationIssuesTitle),
          const SizedBox(height: SpacingTokens.xs),
          MxCallout(
            tone: MxCalloutTone.warning,
            message: l10n.importValidationIssuesSubtitle,
          ),
          const SizedBox(height: SpacingTokens.sm),
          MxCard(
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < preview!.issues.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(height: SpacingTokens.sm),
                  _PreviewIssueTile(issue: preview!.issues[index]),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        if (preview!.rows.isNotEmpty) ...<Widget>[
          MxSectionHeader(label: l10n.importPreviewRowsTitle),
          const SizedBox(height: SpacingTokens.xs),
          MxCard(
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < preview!.rows.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(height: SpacingTokens.sm),
                  _PreviewRowTile(row: preview!.rows[index]),
                ],
              ],
            ),
          ),
        ],
        if (preview!.rows.isEmpty && preview!.issues.isEmpty)
          MxEmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.importNothingTitle,
            message: l10n.importNothingMessage,
          ),
      ],
    ],
  );
}

class _DeckImportMissingDeckState extends StatelessWidget {
  const _DeckImportMissingDeckState({required this.l10n, required this.onBack});

  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.flashcardsImportMissingDeckMessage,
      ),
      const SizedBox(height: SpacingTokens.lg),
      MxSecondaryButton(
        label: l10n.commonBack,
        variant: MxSecondaryVariant.outlined,
        size: MxButtonSize.medium,
        fullWidth: true,
        onPressed: onBack,
      ),
    ],
  );
}

class _PreviewRowTile extends StatelessWidget {
  const _PreviewRowTile({required this.row});

  final DeckImportPreviewRow row;

  @override
  Widget build(BuildContext context) => MxListTile(
    leading: MxText(
      AppLocalizations.of(context).importValidationIssueLine(row.lineNumber),
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
    title: row.front,
    subtitle: row.back,
  );
}

class _PreviewIssueTile extends StatelessWidget {
  const _PreviewIssueTile({required this.issue});

  final DeckImportIssue issue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxListTile(
      leading: Icon(Icons.error_outline, color: context.colorScheme.error),
      title: l10n.importValidationIssueLine(issue.lineNumber),
      subtitle: _issueMessage(l10n, issue),
    );
  }
}

String _issueMessage(AppLocalizations l10n, DeckImportIssue issue) =>
    switch (issue.code) {
      DeckImportIssueCode.frontAndBackRequired =>
        l10n.importCsvFrontAndBackRequiredMessage,
      DeckImportIssueCode.frontRequired => l10n.flashcardEditorFrontError,
      DeckImportIssueCode.backRequired => l10n.flashcardEditorBackError,
    };
