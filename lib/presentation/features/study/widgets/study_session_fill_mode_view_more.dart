part of 'study_session_fill_mode_view.dart';

class _FillPromptCard extends StatelessWidget {
  const _FillPromptCard({
    required this.item,
    required this.onEditCard,
    required this.onOpenCardActions,
  });

  final StudySessionReviewItem item;
  final VoidCallback onEditCard;
  final VoidCallback onOpenCardActions;

  @override
  Widget build(BuildContext context) {
    final String promptText = _promptText(item);

    return MxCard(
      padding: EdgeInsets.zero,
      onLongPress: onOpenCardActions,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Semantics(
                label: promptText,
                child: Center(
                  child: MxText(
                    promptText,
                    role: MxTextRole.bodyMedium,
                    color: context.colorScheme.onSurface,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: MxIconButton(
              icon: Icons.edit_outlined,
              tooltip: AppLocalizations.of(context).studySessionEditCardAction,
              size: MxIconButtonSize.compact,
              onPressed: onEditCard,
            ),
          ),
        ],
      ),
    );
  }

  String _promptText(StudySessionReviewItem item) {
    final String back = StringUtils.trimmed(item.flashcard.back);
    final String? hint = StringUtils.trimmed(item.flashcard.hint ?? '').isEmpty
        ? null
        : StringUtils.trimmed(item.flashcard.hint!);
    if (hint == null) {
      return back;
    }
    return '$back ($hint)';
  }
}

class _FillAnswerCard extends StatelessWidget {
  const _FillAnswerCard({
    required this.state,
    required this.input,
    required this.inputFocusNode,
    required this.onChanged,
    required this.onTryAgain,
    required this.onSpeakFront,
    required this.reduceMotion,
  });

  final StudySessionFillState state;
  final MxTextSubmitState input;
  final FocusNode inputFocusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onTryAgain;
  final VoidCallback? onSpeakFront;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final Duration animationDuration = reduceMotion
        ? Duration.zero
        : DurationTokens.contentSwitch;

    return MxCard(
      padding: EdgeInsets.zero,
      child: AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: state.isTyping
            ? _TypingState(
                key: const ValueKey<String>('fill-typing'),
                state: state,
                input: input,
                inputFocusNode: inputFocusNode,
                onChanged: onChanged,
              )
            : _FeedbackState(
                key: ValueKey<String>(
                  'fill-feedback-${state.feedbackResult?.name ?? 'ready'}',
                ),
                state: state,
                onTryAgain: onTryAgain,
                onSpeakFront: onSpeakFront,
              ),
      ),
    );
  }
}

class _TypingState extends StatelessWidget {
  const _TypingState({
    super.key,
    required this.state,
    required this.input,
    required this.inputFocusNode,
    required this.onChanged,
  });

  final StudySessionFillState state;
  final MxTextSubmitState input;
  final FocusNode inputFocusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(SpacingTokens.xl),
    child: Semantics(
      liveRegion: true,
      label: state.hasHint
          ? state.hintedFront
          : StringUtils.trimmed(state.inputText),
      child: Center(
        child: MxInlineTextField(
          controller: input.controller,
          focusNode: inputFocusNode,
          autofocus: true,
          textInputAction: TextInputAction.done,
          hintText: state.hasHint ? state.hintedFront : null,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    super.key,
    required this.state,
    required this.onTryAgain,
    required this.onSpeakFront,
  });

  final StudySessionFillState state;
  final VoidCallback onTryAgain;
  final VoidCallback? onSpeakFront;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isWrong = state.isWrongFeedback;
    final bool showSpeakAction = onSpeakFront != null;
    final Widget answer = isWrong
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxText(
                StringUtils.trimmed(state.inputText),
                role: MxTextRole.displaySmall,
                color: context.colorScheme.error,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              MxText(
                state.currentItem.flashcard.front,
                role: MxTextRole.displaySmall,
                color: context.colorScheme.onSurface,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxText(
                StringUtils.trimmed(state.inputText),
                role: MxTextRole.displaySmall,
                color: context.colorScheme.onSurface,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              const Icon(Icons.check_rounded, size: SizeTokens.iconLg),
            ],
          );

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Semantics(
            liveRegion: true,
            label: isWrong
                ? l10n.studySessionFillWrongAnnouncement(
                    StringUtils.trimmed(state.inputText),
                    state.currentItem.flashcard.front,
                  )
                : l10n.studySessionFillCorrectAnnouncement(
                    state.currentItem.flashcard.front,
                  ),
            child: Stack(
              children: <Widget>[
                Center(child: answer),
                if (showSpeakAction)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: MxIconButton(
                      icon: Icons.volume_up_outlined,
                      tooltip: l10n.studySessionFillSpeakCorrectAnswerAction,
                      size: MxIconButtonSize.compact,
                      onPressed: onSpeakFront,
                    ),
                  ),
                if (isWrong && !state.feedbackCommitted)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: MxIconButton(
                      icon: Icons.rotate_left_outlined,
                      tooltip: l10n.studySessionFillTryAgainAction,
                      size: MxIconButtonSize.compact,
                      onPressed: state.canRetryCurrentItem ? onTryAgain : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openCardActions(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
  StudyMode? mode,
  StudySessionReviewItem item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final MxStudySessionCardAction? action = await showStudySessionCardActions(
    context,
    front: item.flashcard.front,
  );
  if (!context.mounted) {
    return;
  }
  if (action == null) {
    return;
  }

  switch (action) {
    case MxStudySessionCardAction.edit:
      await _editCard(context, ref, sessionId, mode, item);
      return;
    case MxStudySessionCardAction.buryUntilTomorrow:
      await _applyCardAction(
        context: context,
        ref: ref,
        mode: mode,
        sessionId: sessionId,
        item: item,
        successMessage: l10n.studySessionBurySuccessMessage,
        failureMessage: l10n.studySessionCardActionFailedMessage,
        call: () => ref
            .read(study_di.buryStudySessionCardUseCaseProvider)
            .call(sessionId: sessionId, flashcardId: item.flashcard.id),
      );
      return;
    case MxStudySessionCardAction.suspend:
      await _applyCardAction(
        context: context,
        ref: ref,
        mode: mode,
        sessionId: sessionId,
        item: item,
        successMessage: l10n.studySessionSuspendSuccessMessage,
        failureMessage: l10n.studySessionCardActionFailedMessage,
        call: () => ref
            .read(study_di.suspendStudySessionCardUseCaseProvider)
            .call(sessionId: sessionId, flashcardId: item.flashcard.id),
      );
      return;
  }
}

Future<void> _editCard(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
  StudyMode? mode,
  StudySessionReviewItem item,
) async {
  final StudySessionFillController notifier = ref.read(
    studySessionFillControllerProvider((
      sessionId: sessionId,
      studyMode: mode,
    )).notifier,
  );
  notifier.pauseAdvance();
  try {
    await context.pushFlashcardEdit(item.flashcard.deckId, item.flashcard.id);
  } finally {
    if (context.mounted) {
      final StudySessionFillController refreshedNotifier = ref.read(
        studySessionFillControllerProvider((
          sessionId: sessionId,
          studyMode: mode,
        )).notifier,
      );
      await refreshedNotifier.refreshReview();
      refreshedNotifier.resumeAdvance();
    }
  }
}

Future<void> _applyCardAction({
  required BuildContext context,
  required WidgetRef ref,
  required StudyMode? mode,
  required String sessionId,
  required StudySessionReviewItem item,
  required String successMessage,
  required String failureMessage,
  required Future<Result<void>> Function() call,
}) async {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  final ColorScheme scheme = context.colorScheme;
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Result<void> result = await call();
  if (!context.mounted) {
    return;
  }
  if (messenger == null) {
    return;
  }

  switch (result) {
    case Ok<void>():
      await ref
          .read(
            studySessionFillControllerProvider((
              sessionId: sessionId,
              studyMode: mode,
            )).notifier,
          )
          .refreshReview();
      showMxSnackbarWithScheme(messenger, scheme, message: successMessage);
      return;
    case Err<void>(:final failure):
      showMxSnackbarWithScheme(
        messenger,
        scheme,
        message: l10n.failureMessage(failure, fallback: failureMessage),
        isError: true,
      );
      return;
  }
}
