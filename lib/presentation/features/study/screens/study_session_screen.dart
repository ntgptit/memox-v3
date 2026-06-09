import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/study/mx_flashcard.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  bool _isExitDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) {
          return;
        }
        unawaited(_handleExit(context));
      },
      child: MxScaffold(
        appBar: MxAppBar(
          titleText: l10n.studySessionTitle,
          leading: MxIconButton.toolbar(
            icon: Icons.close,
            tooltip: l10n.commonClose,
            onPressed: () => _handleExit(context),
          ),
        ),
        body: _StudySessionReviewSection(
          sessionId: widget.sessionId,
          onBack: () => _handleExit(context),
        ),
      ),
    );
  }

  Future<void> _handleExit(BuildContext context) async {
    if (_isExitDialogOpen) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final GoRouter router = GoRouter.of(context);
    final bool canPop = context.canPop();
    _isExitDialogOpen = true;
    try {
      final AppLocalizations l10n = AppLocalizations.of(context);
      final bool confirmed = await showMxConfirmDialog(
        context,
        title: l10n.studySessionExitConfirmTitle,
        message: l10n.studySessionExitConfirmMessage,
        confirmLabel: l10n.studySessionExitConfirmAction,
        cancelLabel: l10n.studySessionExitKeepStudyingAction,
      );
      if (!mounted) {
        return;
      }
      if (!confirmed) {
        return;
      }
      if (canPop) {
        navigator.pop();
        return;
      }
      router.goNamed(RouteNames.library);
    } finally {
      if (mounted) {
        _isExitDialogOpen = false;
      }
    }
  }
}

class _StudySessionReviewSection extends ConsumerWidget {
  const _StudySessionReviewSection({
    required this.sessionId,
    required this.onBack,
  });

  final String sessionId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StudySessionReviewState> value = ref.watch(
      studySessionReviewControllerProvider(sessionId),
    );

    return switch (value) {
      AsyncLoading<StudySessionReviewState>() => const MxLoadingState(rows: 3),
      AsyncError<StudySessionReviewState>(:final error) =>
        _StudySessionErrorState(error: error, onBack: onBack),
      AsyncData<StudySessionReviewState>(:final value) => _StudySessionBody(
        state: value,
        onToggleAnswer: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .toggleAnswer(),
        onForgot: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .gradeForgot(),
        onGotIt: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .gradeGotIt(),
        onPrevious: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .previous(),
        onNext: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .next(),
        onFinish: () => ref
            .read(studySessionReviewControllerProvider(sessionId).notifier)
            .finishSession(),
        onFinalized: () => context.pushReplacementStudyResult(sessionId),
      ),
    };
  }
}

class _StudySessionErrorState extends StatelessWidget {
  const _StudySessionErrorState({required this.error, required this.onBack});

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Failure? failure = switch (error) {
      StudySessionFailureException(:final failure) => failure,
      _ => null,
    };
    final ({String title, String message}) copy = switch (failure) {
      NotFoundFailure() => (
        title: l10n.studySessionNotFoundTitle,
        message: l10n.studySessionNotFoundMessage,
      ),
      StorageFailure() => (
        title: l10n.studySessionLoadFailedTitle,
        message: l10n.studySessionLoadFailedMessage,
      ),
      _ => (
        title: l10n.studySessionLoadFailedTitle,
        message: l10n.studySessionLoadFailedMessage,
      ),
    };

    return MxErrorState(
      title: copy.title,
      message: copy.message,
      retryLabel: l10n.commonBack,
      onRetry: onBack,
    );
  }
}

class _StudySessionBody extends StatelessWidget {
  const _StudySessionBody({
    required this.state,
    required this.onToggleAnswer,
    required this.onForgot,
    required this.onGotIt,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
    required this.onFinalized,
  });

  final StudySessionReviewState state;
  final VoidCallback onToggleAnswer;
  final VoidCallback onForgot;
  final VoidCallback onGotIt;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<bool> Function() onFinish;
  final VoidCallback onFinalized;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final StudySessionReview review = state.review;
    final StudySessionReviewItem item = state.currentItem;
    final int total = review.items.length;
    final TextTheme textTheme = theme.textTheme;
    final Widget? statusCallout = _buildStatusCallout(l10n);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: SpacingTokens.xl),
            Text(
              l10n.studySessionProgressLabel(state.currentIndex + 1, total),
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxFlashcard(
              front: _StudySessionFace(
                label: l10n.studySessionFrontLabel,
                value: item.flashcard.front,
              ),
              back: _StudySessionFace(
                label: l10n.studySessionBackLabel,
                value: item.flashcard.back,
              ),
              showBack: state.isAnswerVisible,
            ),
            const SizedBox(height: SpacingTokens.lg),
            if (statusCallout != null) ...<Widget>[
              statusCallout,
              const SizedBox(height: SpacingTokens.md),
            ],
            if (state.isAnswerVisible || state.isSaving) ...<Widget>[
              MxCardActions(
                secondary: MxActionButton(
                  intent: MxActionIntent.cardSecondary,
                  label: l10n.studyForgotAction,
                  onPressed: state.canGradeCurrentItem ? onForgot : null,
                ),
                primary: MxActionButton(
                  intent: MxActionIntent.cardPrimary,
                  label: l10n.studyGotItAction,
                  onPressed: state.canGradeCurrentItem ? onGotIt : null,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
            if (state.allAnswered) ...<Widget>[
              _buildFinishButton(context, l10n),
              const SizedBox(height: SpacingTokens.sm),
            ],
            MxCardActions(
              secondary: MxActionButton(
                intent: MxActionIntent.cardSecondary,
                label: l10n.studyPreviousAction,
                onPressed: state.canGoPrevious ? onPrevious : null,
              ),
              primary: MxActionButton(
                intent: MxActionIntent.cardPrimary,
                label: l10n.studyNextAction,
                onPressed: state.canGoNext ? onNext : null,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxActionButton(
              intent: MxActionIntent.screenPrimary,
              label: state.isAnswerVisible
                  ? l10n.studySessionHideAction
                  : l10n.studySessionShowAction,
              onPressed: state.isBusy ? null : onToggleAnswer,
              fullWidth: true,
            ),
            const SizedBox(height: SpacingTokens.xl),
          ],
        ),
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
    if (state.allAnswered) {
      return MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionAllAnsweredMessage,
      );
    }
    return null;
  }

  Widget _buildFinishButton(BuildContext context, AppLocalizations l10n) =>
      MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: state.isBusy
            ? null
            : () async {
                final bool finished = await onFinish();
                if (!context.mounted) return;
                if (!finished) return;
                onFinalized();
              },
        fullWidth: true,
      );
}

class _StudySessionFace extends StatelessWidget {
  const _StudySessionFace({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          value,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
      ],
    );
  }
}
