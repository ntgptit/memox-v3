import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_fill_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

class StudySessionFillModeView extends HookConsumerWidget {
  const StudySessionFillModeView({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionFillControllerProvider((
      sessionId: sessionId,
      studyMode: mode,
    ));
    final MxTextSubmitState input = useMxTextSubmitState();
    final FocusNode inputFocusNode = useFocusNode();

    ref.listen<AsyncValue<StudySessionFillState>>(provider, (
      AsyncValue<StudySessionFillState>? previous,
      AsyncValue<StudySessionFillState> next,
    ) {
      final bool didNavigateBefore =
          previous?.asData?.value.didFinalizeSuccessfully ?? false;
      final bool didNavigateNow =
          next.asData?.value.didFinalizeSuccessfully ?? false;
      if (!didNavigateBefore && didNavigateNow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            onFinalized();
          }
        });
      }

      final StudySessionFillState? state = next.asData?.value;
      if (state == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        _syncInputController(input.controller, state);
      });
    });

    final AsyncValue<StudySessionFillState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionFillState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionFillModeLabel,
          current: 0,
          total: 0,
          onClose: onBack,
          accent: context.customColors.success,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionFillState>(:final error) =>
        _StudySessionFillErrorState(error: error, onBack: onBack),
      AsyncData<StudySessionFillState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionFillModeLabel,
          current: value.currentIndex + 1,
          total: value.review.items.length,
          onClose: onBack,
          accent: context.customColors.success,
        ),
        body: _StudySessionFillBody(
          state: value,
          input: input,
          inputFocusNode: inputFocusNode,
          onChanged: (String text) =>
              ref.read(provider.notifier).updateInput(text),
          onHint: () => ref.read(provider.notifier).revealHint(),
          onCheck: () => ref.read(provider.notifier).checkAnswer(),
          onMarkCorrect: () => ref.read(provider.notifier).markCorrect(),
          onTryAgain: () => ref.read(provider.notifier).tryAgain(),
          onNext: () => ref.read(provider.notifier).next(),
          onFinish: () => ref.read(provider.notifier).finishSession(),
          onEditCard: (StudySessionReviewItem item) =>
              _editCard(context, ref, sessionId, mode, item),
          onOpenCardActions: (StudySessionReviewItem item) =>
              _openCardActions(context, ref, sessionId, mode, item),
          onSpeakFront: (StudySessionReviewItem item) => unawaited(
            SemanticsService.sendAnnouncement(
              View.of(context),
              item.flashcard.front,
              Directionality.of(context),
            ),
          ),
        ),
      ),
    };
  }

  void _syncInputController(
    TextEditingController inputController,
    StudySessionFillState state,
  ) {
    if (inputController.text == state.inputText) {
      return;
    }

    inputController.value = TextEditingValue(
      text: state.inputText,
      selection: TextSelection.collapsed(offset: state.inputText.length),
    );
  }
}

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = context.colorScheme;
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
                  child: Text(
                    promptText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = context.colorScheme;
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
                theme: theme,
                scheme: scheme,
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
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = context.colorScheme;
    final TextStyle? textStyle = theme.textTheme.displaySmall?.copyWith(
      color: scheme.onSurface,
      fontWeight: TypographyTokens.semiBold,
    );
    final TextStyle? hintStyle = theme.textTheme.displaySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: TypographyTokens.semiBold,
    );

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      child: Semantics(
        liveRegion: true,
        label: state.hasHint
            ? state.hintedFront
            : StringUtils.trimmed(state.inputText),
        child: Center(
          child: TextField(
            controller: input.controller,
            focusNode: inputFocusNode,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            style: textStyle,
            cursorColor: scheme.primary,
            cursorWidth: 2,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              hintText: state.hasHint ? state.hintedFront : null,
              hintStyle: hintStyle,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    super.key,
    required this.state,
    required this.theme,
    required this.scheme,
    required this.onTryAgain,
    required this.onSpeakFront,
  });

  final StudySessionFillState state;
  final ThemeData theme;
  final ColorScheme scheme;
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
              Text(
                StringUtils.trimmed(state.inputText),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.error,
                  fontWeight: TypographyTokens.semiBold,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                state.currentItem.flashcard.front,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: TypographyTokens.semiBold,
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                StringUtils.trimmed(state.inputText),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: TypographyTokens.semiBold,
                ),
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
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ColorScheme scheme = context.colorScheme;
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Result<void> result = await call();
  if (!context.mounted) {
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
