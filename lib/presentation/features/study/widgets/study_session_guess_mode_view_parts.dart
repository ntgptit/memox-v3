part of 'study_session_guess_mode_view.dart';

class _StudySessionGuessErrorState extends StatelessWidget {
  const _StudySessionGuessErrorState({
    required this.error,
    required this.onBack,
  });

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String message}) copy = switch (error) {
      StudySessionGuessFailureException(:final failure) => switch (failure) {
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
        modeLabel: l10n.studySessionGuessModeLabel,
        current: 0,
        total: 0,
        onClose: onBack,
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

class _StudySessionGuessBody extends StatelessWidget {
  const _StudySessionGuessBody({
    required this.state,
    required this.onTapOption,
    required this.onOpenCardActions,
  });

  final StudySessionGuessState state;
  final void Function(GuessOption option) onTapOption;
  final Future<void> Function(GuessOption option) onOpenCardActions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Widget? statusCallout = _buildStatusCallout(l10n);
    final Widget? liveAnnouncement = _buildLiveAnnouncement(l10n);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: SpacingTokens.lg),
          _GuessPromptCard(front: state.currentItem.flashcard.front),
          if (statusCallout != null) ...<Widget>[
            const SizedBox(height: SpacingTokens.md),
            statusCallout,
          ],
          ?liveAnnouncement,
          const SizedBox(height: SpacingTokens.md),
          for (
            int index = 0;
            index < state.options.length;
            index++
          ) ...<Widget>[
            _GuessOptionCard(
              option: state.options[index],
              state: _optionStateFor(state.options[index]),
              letter: _guessOptionLetters[index],
              onTap: state.canChooseCurrentItem
                  ? () => onTapOption(state.options[index])
                  : null,
              onLongPress: state.canChooseCurrentItem
                  ? () => unawaited(onOpenCardActions(state.options[index]))
                  : null,
            ),
            if (index < state.options.length - 1)
              const SizedBox(height: SpacingTokens.sm),
          ],
          const SizedBox(height: SpacingTokens.xl),
        ],
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
    if (state.isSaving) {
      return MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionSavingAnswerMessage,
      );
    }
    return null;
  }

  Widget? _buildLiveAnnouncement(AppLocalizations l10n) {
    if (!state.didSelectOption) {
      return null;
    }
    final String label = state.isSelectionCorrect
        ? l10n.studySessionGuessCorrectAnnouncement
        : l10n.studySessionGuessWrongAnnouncement(state.correctOption.title);
    return Semantics(
      liveRegion: true,
      label: label,
      child: const SizedBox.shrink(),
    );
  }

  _GuessOptionVisualState _optionStateFor(GuessOption option) {
    if (!state.didSelectOption) {
      return _GuessOptionVisualState.idle;
    }
    if (option.flashcard.id == state.selectedOptionId &&
        state.selectedOptionIsCorrect) {
      return _GuessOptionVisualState.selectedCorrect;
    }
    if (option.flashcard.id == state.selectedOptionId &&
        !state.selectedOptionIsCorrect) {
      return _GuessOptionVisualState.selectedWrong;
    }
    if (option.isCorrect && !state.selectedOptionIsCorrect) {
      return _GuessOptionVisualState.revealedCorrect;
    }
    return _GuessOptionVisualState.dimmed;
  }
}
