import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/study/study_entry_route_input.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Controlled resume-required state for the Study Entry gate.
class StudyEntryResumeRequiredState extends ConsumerStatefulWidget {
  const StudyEntryResumeRequiredState({
    required this.request,
    required this.sessionId,
    super.key,
  });

  final StudyEntryRouteInput request;
  final String sessionId;

  @override
  ConsumerState<StudyEntryResumeRequiredState> createState() =>
      _StudyEntryResumeRequiredStateState();
}

class _StudyEntryResumeRequiredStateState
    extends ConsumerState<StudyEntryResumeRequiredState> {
  bool _isWorking = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: SpacingTokens.lg),
          MxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: SpacingTokens.xs),
                const Icon(Icons.history, size: SizeTokens.iconLg),
                const SizedBox(height: SpacingTokens.md),
                MxText(
                  l10n.studyEntryResumeRequiredTitle,
                  role: MxTextRole.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingTokens.xs),
                MxText(
                  l10n.studyEntryResumeRequiredMessage,
                  role: MxTextRole.bodyMedium,
                  textAlign: TextAlign.center,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: SpacingTokens.lg),
                MxSectionHeader(label: l10n.studyEntryResumeRequiredHeader),
                const SizedBox(height: SpacingTokens.md),
                if (_isWorking) ...<Widget>[
                  const MxLoadingState(rows: 2),
                ] else ...<Widget>[
                  MxActionButton(
                    intent: MxActionIntent.screenPrimary,
                    label: l10n.studyEntryResumeRequiredResumeAction,
                    onPressed: _handleResume,
                    fullWidth: true,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  MxSecondaryButton(
                    label: l10n.studyEntryResumeRequiredStartOverAction,
                    onPressed: _handleStartOver,
                    fullWidth: true,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  MxSecondaryButton(
                    variant: MxSecondaryVariant.text,
                    label: l10n.commonBack,
                    onPressed: _handleBack,
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }

  void _handleResume() {
    context.pushReplacementStudySession(widget.sessionId);
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goLibrary();
  }

  Future<void> _handleStartOver() async {
    if (_isWorking) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.studyEntryResumeRequiredStartOverConfirmTitle,
      message: l10n.studyEntryResumeRequiredStartOverConfirmMessage,
      confirmLabel: l10n.studyEntryResumeRequiredStartOverConfirmAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isWorking = true;
    });

    final Result<void> result = await ref
        .read(cancelStudySessionUseCaseProvider)
        .call(sessionId: widget.sessionId);
    if (!mounted) {
      return;
    }
    if (result is Err<void>) {
      setState(() {
        _isWorking = false;
      });
      showMxSnackbar(
        context,
        message: l10n.studyEntryResumeRequiredStartOverFailed,
        isError: true,
      );
      return;
    }

    ref.invalidate(studyEntryProvider(widget.request));
  }
}
