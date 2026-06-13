import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_recall_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

class StudySessionRecallModeView extends ConsumerStatefulWidget {
  const StudySessionRecallModeView({
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
  ConsumerState<StudySessionRecallModeView> createState() =>
      _StudySessionRecallModeViewState();
}

class _StudySessionRecallModeViewState
    extends ConsumerState<StudySessionRecallModeView> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionRecallControllerProvider((
      sessionId: widget.sessionId,
      studyMode: widget.mode,
    ));

    ref.listen<AsyncValue<StudySessionRecallState>>(provider, (
      AsyncValue<StudySessionRecallState>? previous,
      AsyncValue<StudySessionRecallState> next,
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

    final AsyncValue<StudySessionRecallState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionRecallState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionRecallModeLabel,
          current: 0,
          total: 0,
          onClose: widget.onBack,
          accent: context.customColors.success,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionRecallState>(:final error) =>
        _StudySessionRecallErrorState(error: error, onBack: widget.onBack),
      AsyncData<StudySessionRecallState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionRecallModeLabel,
          current: value.currentIndex + 1,
          total: value.review.items.length,
          onClose: widget.onBack,
          accent: context.customColors.success,
        ),
        body: _StudySessionRecallBody(
          state: value,
          onRevealAnswer: () => ref.read(provider.notifier).revealAnswer(),
          onForgot: () => ref.read(provider.notifier).gradeForgot(),
          onGotIt: () => ref.read(provider.notifier).gradeGotIt(),
          onEditCard: (StudySessionReviewItem item) =>
              _editCard(context, ref, widget.sessionId, widget.mode, item),
          onOpenCardActions: (StudySessionReviewItem item) => _openCardActions(
            context,
            ref,
            widget.sessionId,
            widget.mode,
            item,
          ),
          onSpeakFront: (StudySessionReviewItem item) => unawaited(
            SemanticsService.sendAnnouncement(
              View.of(context),
              item.flashcard.front,
              Directionality.of(context),
            ),
          ),
        ),
        bottomAction: _buildBottomAction(
          context: context,
          state: value,
          onRevealAnswer: () => ref.read(provider.notifier).revealAnswer(),
          onForgot: () => ref.read(provider.notifier).gradeForgot(),
          onGotIt: () => ref.read(provider.notifier).gradeGotIt(),
          onRetryFinalize: () => ref.read(provider.notifier).finishSession(),
        ),
      ),
    };
  }

  Widget? _buildBottomAction({
    required BuildContext context,
    required StudySessionRecallState state,
    required VoidCallback onRevealAnswer,
    required Future<void> Function() onForgot,
    required Future<void> Function() onGotIt,
    required Future<bool> Function() onRetryFinalize,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state.finalizeFailure != null && state.allAnswered) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: () async {
          final bool finished = await onRetryFinalize();
          if (!context.mounted || !finished) {
            return;
          }
          widget.onFinalized();
        },
        fullWidth: true,
      );
    }

    if (state.isAnswerVisible || state.isSaving || state.isFinalizing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.revealedByTimeout) ...<Widget>[
            Text(
              l10n.studySessionRecallTimeoutCaption,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          MxCardActions(
            secondary: MxActionButton(
              intent: MxActionIntent.cardSecondary,
              label: l10n.studyForgotAction,
              onPressed: state.canGradeCurrentItem
                  ? () async {
                      await onForgot();
                    }
                  : null,
            ),
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: l10n.studyGotItAction,
              onPressed: state.canGradeCurrentItem
                  ? () async {
                      await onGotIt();
                    }
                  : null,
            ),
          ),
        ],
      );
    }

    return MxActionButton(
      intent: MxActionIntent.screenPrimary,
      label: l10n.studySessionRecallShowAnswerAction(
        state.countdownRemainingSeconds,
      ),
      onPressed: onRevealAnswer,
      fullWidth: true,
    );
  }
}

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = context.colorScheme;
    final bool showSpeakAction =
        item.targetLanguage != TargetLanguage.unsupported;

    return MxCard(
      onLongPress: onOpenCardActions,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  item.flashcard.front,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: TypographyTokens.semiBold,
                  ),
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
    final ColorScheme scheme = context.colorScheme;
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
                  child: Text(
                    back,
                    textAlign: TextAlign.left,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                  ),
                ),
              )
            : Center(
                key: const ValueKey<String>('recall-back-hidden'),
                child: Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(
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
  if (!context.mounted || action == null) {
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
