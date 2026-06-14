part of 'study_session_fill_mode_view.dart';

class _StudySessionFillErrorState extends StatelessWidget {
  const _StudySessionFillErrorState({
    required this.error,
    required this.onBack,
  });

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String message}) copy = switch (error) {
      StudySessionFillFailureException(:final failure) => switch (failure) {
        NotFoundFailure() => (
          title: l10n.studySessionNotFoundTitle,
          message: l10n.studySessionNotFoundMessage,
        ),
        _ => (
          title: l10n.studySessionLoadFailedTitle,
          message: l10n.studySessionLoadFailedMessage,
        ),
      },
      _ => (
        title: l10n.studySessionLoadFailedTitle,
        message: l10n.studySessionLoadFailedMessage,
      ),
    };

    return MxStudyScaffold(
      topBar: MxStudyTopBar(
        modeLabel: l10n.studySessionFillModeLabel,
        current: 0,
        total: 0,
        onClose: onBack,
        accent: context.customColors.success,
      ),
      body: MxErrorState(
        title: copy.title,
        message: copy.message,
        retryLabel: l10n.commonBack,
        onRetry: onBack,
      ),
    );
  }
}

class _StudySessionFillBody extends StatelessWidget {
  const _StudySessionFillBody({
    required this.state,
    required this.input,
    required this.inputFocusNode,
    required this.onChanged,
    required this.onHint,
    required this.onCheck,
    required this.onMarkCorrect,
    required this.onTryAgain,
    required this.onNext,
    required this.onFinish,
    required this.onEditCard,
    required this.onOpenCardActions,
    required this.onSpeakFront,
  });

  final StudySessionFillState state;
  final MxTextSubmitState input;
  final FocusNode inputFocusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onHint;
  final Future<void> Function() onCheck;
  final Future<void> Function() onMarkCorrect;
  final VoidCallback onTryAgain;
  final VoidCallback onNext;
  final Future<void> Function() onFinish;
  final Future<void> Function(StudySessionReviewItem item) onEditCard;
  final Future<void> Function(StudySessionReviewItem item) onOpenCardActions;
  final void Function(StudySessionReviewItem item) onSpeakFront;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StudySessionReviewItem item = state.currentItem;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Widget? statusCallout = _buildStatusCallout(l10n);
    final bool showSpeakAction =
        state.showSpeakAction &&
        item.targetLanguage != TargetLanguage.unsupported;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth >= 520
            ? 520
            : constraints.maxWidth;
        final double promptHeight = constraints.maxHeight >= 760
            ? 304
            : (constraints.maxHeight * 0.40).clamp(248, 304);
        final double answerHeight = constraints.maxHeight >= 760
            ? 296
            : (constraints.maxHeight * 0.39).clamp(240, 296);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: SpacingTokens.lg),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: SizedBox(
                      height: promptHeight,
                      child: _FillPromptCard(
                        item: item,
                        onEditCard: () => onEditCard(item),
                        onOpenCardActions: () => onOpenCardActions(item),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: SizedBox(
                      height: answerHeight,
                      child: _FillAnswerCard(
                        state: state,
                        input: input,
                        inputFocusNode: inputFocusNode,
                        onChanged: onChanged,
                        onTryAgain: onTryAgain,
                        onSpeakFront: showSpeakAction
                            ? () => onSpeakFront(item)
                            : null,
                        reduceMotion: reduceMotion,
                      ),
                    ),
                  ),
                ),
                if (statusCallout != null) ...<Widget>[
                  const SizedBox(height: SpacingTokens.md),
                  statusCallout,
                ],
                const SizedBox(height: SpacingTokens.sm),
                _buildActions(context, l10n),
                const SizedBox(height: SpacingTokens.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    if (state.readyToFinish) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: state.canFinish
            ? () async {
                await onFinish();
              }
            : null,
        fullWidth: true,
      );
    }

    if (state.isWrongFeedback && !state.feedbackCommitted) {
      return MxCardActions(
        secondary: MxActionButton(
          intent: MxActionIntent.cardSecondary,
          label: l10n.studySessionFillMarkCorrectAction,
          onPressed: state.canMarkCorrect ? () async => onMarkCorrect() : null,
        ),
        primary: MxActionButton(
          intent: MxActionIntent.cardPrimary,
          label: l10n.studySessionFillTryAgainAction,
          onPressed: state.canRetryCurrentItem ? onTryAgain : null,
        ),
      );
    }

    if (state.isFeedbackVisible) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyNextAction,
        onPressed: state.canAdvance ? onNext : null,
        fullWidth: true,
      );
    }

    return MxCardActions(
      secondary: MxActionButton(
        intent: MxActionIntent.cardSecondary,
        label: l10n.studySessionFillHintAction,
        onPressed: state.canRevealHint ? onHint : null,
      ),
      primary: MxActionButton(
        intent: MxActionIntent.cardPrimary,
        label: l10n.studySessionFillCheckAction,
        onPressed: state.canCheckCurrentItem
            ? () async {
                await onCheck();
              }
            : null,
      ),
    );
  }

  Widget? _buildStatusCallout(AppLocalizations l10n) {
    if (state.finalizeFailure != null) {
      return MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.failureMessage(
          state.finalizeFailure!,
          fallback: l10n.studySessionFinalizeFailedMessage,
        ),
      );
    }
    if (state.isFinalizing) {
      return MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionFinalizingMessage,
      );
    }
    if (state.saveFailure != null) {
      return MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.failureMessage(
          state.saveFailure!,
          fallback: l10n.studySessionRecordFailedMessage,
        ),
      );
    }
    if (state.readyToFinish) {
      return MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionFillReadyToFinishMessage,
      );
    }
    if (state.feedbackCommitted && state.isCorrectFeedback) {
      return MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionFillCorrectAnnouncement(
          state.currentItem.flashcard.front,
        ),
      );
    }
    if (state.isWrongFeedback) {
      final String input = StringUtils.trimmed(state.inputText);
      final String front = state.currentItem.flashcard.front;
      return MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.studySessionFillWrongAnnouncement(input, front),
      );
    }
    return null;
  }
}
