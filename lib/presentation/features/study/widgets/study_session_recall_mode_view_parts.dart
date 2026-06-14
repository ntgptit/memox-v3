part of 'study_session_recall_mode_view.dart';

class _StudySessionRecallErrorState extends StatelessWidget {
  const _StudySessionRecallErrorState({
    required this.error,
    required this.onBack,
  });

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String message}) copy = switch (error) {
      StudySessionRecallFailureException(:final failure) => switch (failure) {
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
        modeLabel: l10n.studySessionRecallModeLabel,
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

class _StudySessionRecallBody extends StatelessWidget {
  const _StudySessionRecallBody({
    required this.state,
    required this.onRevealAnswer,
    required this.onForgot,
    required this.onGotIt,
    required this.onEditCard,
    required this.onOpenCardActions,
    required this.onSpeakFront,
  });

  final StudySessionRecallState state;
  final VoidCallback onRevealAnswer;
  final Future<void> Function() onForgot;
  final Future<void> Function() onGotIt;
  final Future<void> Function(StudySessionReviewItem item) onEditCard;
  final Future<void> Function(StudySessionReviewItem item) onOpenCardActions;
  final void Function(StudySessionReviewItem item) onSpeakFront;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StudySessionReviewItem item = state.currentItem;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Widget? statusCallout = _buildStatusCallout(l10n);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: SpacingTokens.lg),
          _RecallFrontCard(
            item: item,
            onEditCard: () => onEditCard(item),
            onOpenCardActions: () => onOpenCardActions(item),
            onSpeakFront: () => onSpeakFront(item),
          ),
          const SizedBox(height: SpacingTokens.md),
          _RecallBackCard(
            back: item.flashcard.back,
            isVisible: state.isAnswerVisible,
            reduceMotion: reduceMotion,
          ),
          if (statusCallout != null) ...<Widget>[
            const SizedBox(height: SpacingTokens.md),
            statusCallout,
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
}

class _RecallFrontCard extends StatelessWidget {
  const _RecallFrontCard({
    required this.item,
    required this.onEditCard,
    required this.onOpenCardActions,
    required this.onSpeakFront,
  });

  final StudySessionReviewItem item;
  final VoidCallback onEditCard;
  final VoidCallback onOpenCardActions;
  final VoidCallback onSpeakFront;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool showSpeakAction =
        item.targetLanguage != TargetLanguage.unsupported;

    return MxCard(
      onLongPress: onOpenCardActions,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxl),
              child: Center(
                child: MxText(
                  item.flashcard.front,
                  role: MxTextRole.displaySmall,
                  color: context.colorScheme.onSurface,
                  fontWeight: TypographyTokens.semiBold,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: MxIconButton(
                icon: Icons.edit_outlined,
                tooltip: l10n.studySessionEditCardAction,
                size: MxIconButtonSize.compact,
                onPressed: onEditCard,
              ),
            ),
            if (showSpeakAction)
              Positioned(
                bottom: 0,
                right: 0,
                child: MxIconButton(
                  icon: Icons.volume_up_outlined,
                  tooltip: l10n.studySessionSpeakFrontAction,
                  size: MxIconButtonSize.compact,
                  onPressed: onSpeakFront,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecallBackCard extends StatelessWidget {
  const _RecallBackCard({
    required this.back,
    required this.isVisible,
    required this.reduceMotion,
  });

  final String back;
  final bool isVisible;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final Duration animationDuration = reduceMotion
        ? Duration.zero
        : DurationTokens.contentSwitch;
    return MxCard(
      child: AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: isVisible
            ? Semantics(
                liveRegion: true,
                child: Align(
                  key: const ValueKey<String>('recall-back-visible'),
                  alignment: Alignment.centerLeft,
                  child: MxText(
                    back,
                    role: MxTextRole.bodyLarge,
                    color: context.colorScheme.onSurface,
                    textAlign: TextAlign.left,
                  ),
                ),
              )
            : Center(
                key: const ValueKey<String>('recall-back-hidden'),
                child: Container(
                  width: SizeTokens.fab,
                  height: SizeTokens.bar,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurfaceVariant.withValues(
                      alpha: OpacityTokens.hover,
                    ),
                    borderRadius: RadiusTokens.brFull,
                  ),
                ),
              ),
      ),
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
  if (action == null) {
    return;
  }
  if (!context.mounted) {
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
  final StudySessionRecallController notifier = ref.read(
    studySessionRecallControllerProvider((
      sessionId: sessionId,
      studyMode: mode,
    )).notifier,
  );
  notifier.pauseCountdown();
  try {
    await context.pushFlashcardEdit(item.flashcard.deckId, item.flashcard.id);
  } finally {
    if (context.mounted) {
      final StudySessionRecallController refreshedNotifier = ref.read(
        studySessionRecallControllerProvider((
          sessionId: sessionId,
          studyMode: mode,
        )).notifier,
      );
      await refreshedNotifier.refreshReview();
      refreshedNotifier.resumeCountdown();
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
            studySessionRecallControllerProvider((
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
