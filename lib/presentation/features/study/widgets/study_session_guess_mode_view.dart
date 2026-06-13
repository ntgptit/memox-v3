import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/study/guess/guess_option.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_guess_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

class StudySessionGuessModeView extends ConsumerStatefulWidget {
  const StudySessionGuessModeView({
    required this.sessionId,
    required this.mode,
    required this.onBack,
    required this.onFinalized,
    super.key,
  });

  final String sessionId;
  final StudyMode? mode;
  final VoidCallback onBack;
  final VoidCallback onFinalized;

  @override
  ConsumerState<StudySessionGuessModeView> createState() =>
      _StudySessionGuessModeViewState();
}

class _StudySessionGuessModeViewState
    extends ConsumerState<StudySessionGuessModeView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(DurationTokens.fast, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionGuessControllerProvider((
      sessionId: widget.sessionId,
      studyMode: widget.mode,
    ));

    ref.listen<AsyncValue<StudySessionGuessState>>(provider, (
      AsyncValue<StudySessionGuessState>? previous,
      AsyncValue<StudySessionGuessState> next,
    ) {
      final bool didNavigateBefore =
          previous?.asData?.value.didFinalizeSuccessfully ?? false;
      final bool didNavigateNow =
          next.asData?.value.didFinalizeSuccessfully ?? false;
      if (!didNavigateBefore && didNavigateNow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onFinalized();
          }
        });
      }
    });

    final AsyncValue<StudySessionGuessState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionGuessState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionGuessModeLabel,
          current: 0,
          total: 0,
          onClose: widget.onBack,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionGuessState>(:final error) =>
        _StudySessionGuessErrorState(error: error, onBack: widget.onBack),
      AsyncData<StudySessionGuessState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionGuessModeLabel,
          current: value.answeredCount,
          total: value.review.items.length,
          onClose: widget.onBack,
        ),
        body: _StudySessionGuessBody(
          state: value,
          onTapOption: (GuessOption option) =>
              ref.read(provider.notifier).selectOption(option),
          onOpenCardActions: (GuessOption option) => _openCardActions(
            context,
            ref,
            widget.sessionId,
            widget.mode,
            option,
          ),
        ),
        bottomAction: _buildBottomAction(
          context: context,
          state: value,
          onRetryFinalize: () => ref.read(provider.notifier).retryFinalize(),
          onSkip: () => ref.read(provider.notifier).skipCountdown(),
        ),
      ),
    };
  }

  Widget? _buildBottomAction({
    required BuildContext context,
    required StudySessionGuessState state,
    required Future<void> Function() onRetryFinalize,
    required VoidCallback onSkip,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state.finalizeFailure != null && !state.isBusy) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: () async {
          await onRetryFinalize();
        },
        fullWidth: true,
      );
    }
    if (!state.isCountdownActive) {
      return null;
    }
    return _GuessCountdownFooter(
      countdownEndsAt: state.countdownEndsAt!,
      countdownDuration: state.countdownDuration!,
      onSkip: onSkip,
    );
  }
}

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
    final Color tone = switch (state) {
      _GuessOptionVisualState.selectedCorrect ||
      _GuessOptionVisualState.revealedCorrect => success,
      _GuessOptionVisualState.selectedWrong => scheme.error,
      _GuessOptionVisualState.idle ||
      _GuessOptionVisualState.dimmed => scheme.primary,
    };
    final bool isDimmed = state == _GuessOptionVisualState.dimmed;
    final double opacity = isDimmed ? OpacityTokens.hint : 1.0;
    final BorderSide borderSide = switch (state) {
      _GuessOptionVisualState.selectedCorrect ||
      _GuessOptionVisualState.revealedCorrect => BorderSide(
        color: success,
        width: BorderTokens.focusWidth,
      ),
      _GuessOptionVisualState.selectedWrong => BorderSide(
        color: scheme.error,
        width: BorderTokens.focusWidth,
      ),
      _GuessOptionVisualState.idle ||
      _GuessOptionVisualState.dimmed => BorderTokens.ghostSide(scheme.primary),
    };
    final Color background = switch (state) {
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
    final IconData? icon = switch (state) {
      _GuessOptionVisualState.selectedCorrect ||
      _GuessOptionVisualState.revealedCorrect => Icons.check_rounded,
      _GuessOptionVisualState.selectedWrong => Icons.close_rounded,
      _GuessOptionVisualState.idle || _GuessOptionVisualState.dimmed => null,
    };

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
              color: background,
              borderRadius: RadiusTokens.brLg,
              border: Border.fromBorderSide(borderSide),
            ),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
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
                        color: state == _GuessOptionVisualState.selectedWrong
                            ? scheme.error
                            : state ==
                                      _GuessOptionVisualState.selectedCorrect ||
                                  state ==
                                      _GuessOptionVisualState.revealedCorrect
                            ? success
                            : scheme.onSurface,
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
            ),
          ),
        ),
      ),
    );
  }

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
      context.pushFlashcardEdit(option.flashcard.deckId, option.flashcard.id);
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
