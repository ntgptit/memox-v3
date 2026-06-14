part of 'study_session_guess_mode_view.dart';

class _GuessPromptCard extends StatelessWidget {
  const _GuessPromptCard({required this.front});

  final String front;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxText(
            StringUtils.uppercased(l10n.studySessionGuessPromptLabel),
            role: MxTextRole.labelSmall,
            color: scheme.onSurfaceVariant,
            fontWeight: TypographyTokens.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.lg),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: MxText(
              front,
              role: MxTextRole.displaySmall,
              color: scheme.onSurface,
              fontWeight: TypographyTokens.semiBold,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuessOptionCard extends StatelessWidget {
  const _GuessOptionCard({
    required this.option,
    required this.state,
    required this.letter,
    required this.onTap,
    required this.onLongPress,
  });

  final GuessOption option;
  final _GuessOptionVisualState state;
  final String letter;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color success = context.customColors.success;
    final Color tone = _toneFor(scheme, success);
    final bool isDimmed = state == _GuessOptionVisualState.dimmed;
    final double opacity = isDimmed ? OpacityTokens.hint : 1.0;

    return Semantics(
      button: true,
      selected:
          state == _GuessOptionVisualState.selectedCorrect ||
          state == _GuessOptionVisualState.selectedWrong,
      label: _semanticsLabel(context),
      child: AnimatedOpacity(
        duration: DurationTokens.stateChange,
        opacity: opacity,
        child: MxTappable(
          key: ValueKey<String>('guess-option-${option.flashcard.id}'),
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: RadiusTokens.brLg,
          child: AnimatedContainer(
            duration: DurationTokens.stateChange,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _backgroundFor(scheme, success),
              borderRadius: RadiusTokens.brLg,
              border: Border.fromBorderSide(_borderSideFor(scheme, success)),
            ),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: _buildContent(scheme, success, tone),
          ),
        ),
      ),
    );
  }

  Color _toneFor(ColorScheme scheme, Color success) => switch (state) {
    _GuessOptionVisualState.selectedCorrect ||
    _GuessOptionVisualState.revealedCorrect => success,
    _GuessOptionVisualState.selectedWrong => scheme.error,
    _GuessOptionVisualState.idle ||
    _GuessOptionVisualState.dimmed => scheme.primary,
  };

  BorderSide _borderSideFor(ColorScheme scheme, Color success) =>
      switch (state) {
        _GuessOptionVisualState.selectedCorrect ||
        _GuessOptionVisualState.revealedCorrect => BorderSide(
          color: success,
          width: BorderTokens.focusWidth,
        ),
        _GuessOptionVisualState.selectedWrong => BorderSide(
          color: scheme.error,
          width: BorderTokens.focusWidth,
        ),
        _GuessOptionVisualState.idle || _GuessOptionVisualState.dimmed =>
          BorderTokens.ghostSide(scheme.primary),
      };

  Color _backgroundFor(ColorScheme scheme, Color success) => switch (state) {
    _GuessOptionVisualState.selectedCorrect ||
    _GuessOptionVisualState.revealedCorrect => success.withValues(
      alpha: OpacityTokens.softTint,
    ),
    _GuessOptionVisualState.selectedWrong => scheme.error.withValues(
      alpha: OpacityTokens.softTint,
    ),
    _GuessOptionVisualState.idle ||
    _GuessOptionVisualState.dimmed => scheme.surfaceContainerLowest,
  };

  Widget _buildContent(ColorScheme scheme, Color success, Color tone) {
    final IconData? icon = switch (state) {
      _GuessOptionVisualState.selectedCorrect ||
      _GuessOptionVisualState.revealedCorrect => Icons.check_rounded,
      _GuessOptionVisualState.selectedWrong => Icons.close_rounded,
      _GuessOptionVisualState.idle || _GuessOptionVisualState.dimmed => null,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _OptionLetter(letter: letter, tone: tone),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(
                option.title,
                role: MxTextRole.titleMedium,
                color: _titleColor(scheme, success),
                fontWeight: TypographyTokens.semiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                option.description,
                role: MxTextRole.bodyMedium,
                color: scheme.onSurfaceVariant,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (icon != null) ...<Widget>[
          const SizedBox(width: SpacingTokens.sm),
          Icon(icon, size: SizeTokens.iconSm, color: tone),
        ],
      ],
    );
  }

  Color _titleColor(ColorScheme scheme, Color success) => switch (state) {
    _GuessOptionVisualState.selectedWrong => scheme.error,
    _GuessOptionVisualState.selectedCorrect ||
    _GuessOptionVisualState.revealedCorrect => success,
    _GuessOptionVisualState.idle ||
    _GuessOptionVisualState.dimmed => scheme.onSurface,
  };

  String _semanticsLabel(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return l10n.studySessionGuessOptionSemanticsLabel(
      letter,
      option.title,
      option.description,
    );
  }
}

class _OptionLetter extends StatelessWidget {
  const _OptionLetter({required this.letter, required this.tone});

  final String letter;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      width: SizeTokens.controlMd,
      height: SizeTokens.controlMd,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: OpacityTokens.hover),
        shape: BoxShape.circle,
        border: Border.all(
          color: tone.withValues(alpha: OpacityTokens.borderSubtle),
          width: BorderTokens.width,
        ),
      ),
      alignment: Alignment.center,
      child: MxText(
        letter,
        role: MxTextRole.labelMedium,
        color: scheme.onSurface,
        fontWeight: TypographyTokens.bold,
      ),
    );
  }
}

class _GuessCountdownFooter extends StatelessWidget {
  const _GuessCountdownFooter({
    required this.countdownEndsAt,
    required this.countdownDuration,
    required this.onSkip,
  });

  final DateTime countdownEndsAt;
  final Duration countdownDuration;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final Duration remaining = countdownEndsAt.difference(DateTime.now());
    final Duration safeRemaining = remaining.isNegative
        ? Duration.zero
        : remaining;
    final double progress = countdownDuration.inMilliseconds <= 0
        ? 0
        : (safeRemaining.inMilliseconds / countdownDuration.inMilliseconds)
              .clamp(0, 1)
              .toDouble();
    final String label = l10n.studySessionGuessNextCardInLabel(
      _formatSeconds(safeRemaining),
    );

    return Semantics(
      button: true,
      label: l10n.studySessionGuessSkipAction,
      value: label,
      child: MxCard(
        padding: EdgeInsets.zero,
        onTap: onSkip,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MxText(
                StringUtils.uppercased(label),
                role: MxTextRole.labelLarge,
                color: scheme.onSurfaceVariant,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.sm),
              MxLinearProgress(
                value: progress,
                color: scheme.primary,
                height: SpacingTokens.xs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSeconds(Duration value) {
    final double seconds = value.inMilliseconds / 1000;
    return seconds.toStringAsFixed(1);
  }
}

enum _GuessOptionVisualState {
  idle,
  dimmed,
  selectedCorrect,
  selectedWrong,
  revealedCorrect,
}

const List<String> _guessOptionLetters = <String>['A', 'B', 'C', 'D', 'E'];

Future<void> _openCardActions(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
  StudyMode? mode,
  GuessOption option,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final MxStudySessionCardAction? action = await showStudySessionCardActions(
    context,
    front: option.flashcard.front,
  );
  if (!context.mounted) {
    return;
  }
  if (action == null) {
    return;
  }

  switch (action) {
    case MxStudySessionCardAction.edit:
      unawaited(
        context.pushFlashcardEdit(option.flashcard.deckId, option.flashcard.id),
      );
      return;
    case MxStudySessionCardAction.buryUntilTomorrow:
      await _applyCardAction(
        context: context,
        ref: ref,
        sessionId: sessionId,
        mode: mode,
        successMessage: l10n.studySessionBurySuccessMessage,
        failureMessage: l10n.studySessionCardActionFailedMessage,
        call: () => ref
            .read(study_di.buryStudySessionCardUseCaseProvider)
            .call(sessionId: sessionId, flashcardId: option.flashcard.id),
      );
      return;
    case MxStudySessionCardAction.suspend:
      await _applyCardAction(
        context: context,
        ref: ref,
        sessionId: sessionId,
        mode: mode,
        successMessage: l10n.studySessionSuspendSuccessMessage,
        failureMessage: l10n.studySessionCardActionFailedMessage,
        call: () => ref
            .read(study_di.suspendStudySessionCardUseCaseProvider)
            .call(sessionId: sessionId, flashcardId: option.flashcard.id),
      );
      return;
  }
}

Future<void> _applyCardAction({
  required BuildContext context,
  required WidgetRef ref,
  required String sessionId,
  required StudyMode? mode,
  required String successMessage,
  required String failureMessage,
  required Future<Result<void>> Function() call,
}) async {
  final Result<void> result = await call();
  if (!context.mounted) {
    return;
  }

  switch (result) {
    case Ok<void>():
      ref.invalidate(
        studySessionGuessControllerProvider((
          sessionId: sessionId,
          studyMode: mode,
        )),
      );
      showMxSnackbar(context, message: successMessage);
      return;
    case Err<void>(:final failure):
      showMxSnackbar(
        context,
        message: AppLocalizations.of(
          context,
        ).failureMessage(failure, fallback: failureMessage),
        isError: true,
      );
      return;
  }
}
