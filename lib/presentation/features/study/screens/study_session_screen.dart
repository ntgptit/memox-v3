import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/study/mx_flashcard.dart';

class StudySessionScreen extends StatelessWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.studySessionTitle,
        leading: MxIconButton.toolbar(
          icon: Icons.close,
          tooltip: l10n.commonClose,
          onPressed: () => _handleExit(context),
        ),
      ),
      body: _StudySessionReviewSection(
        sessionId: sessionId,
        onBack: () => _handleExit(context),
      ),
    );
  }

  void _handleExit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goLibrary();
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
      AsyncError<StudySessionReviewState>(:final error) => _StudySessionErrorState(
        error: error,
        onBack: onBack,
      ),
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
      ),
    };
  }
}

class _StudySessionErrorState extends StatelessWidget {
  const _StudySessionErrorState({
    required this.error,
    required this.onBack,
  });

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
  });

  final StudySessionReviewState state;
  final VoidCallback onToggleAnswer;
  final VoidCallback onForgot;
  final VoidCallback onGotIt;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final StudySessionReview review = state.review;
    final StudySessionReviewItem item = state.currentItem;
    final int total = review.items.length;
    final TextTheme textTheme = theme.textTheme;
    Widget? statusCallout;
    if (state.saveFailure != null) {
      statusCallout = MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.failureMessage(
          state.saveFailure!,
          fallback: l10n.studySessionRecordFailedMessage,
        ),
      );
    }
    if (statusCallout == null && state.isSaving) {
      statusCallout = MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionSavingAnswerMessage,
      );
    }
    if (statusCallout == null && state.allAnswered) {
      statusCallout = MxCallout(
        tone: MxCalloutTone.info,
        message: l10n.studySessionAllAnsweredMessage,
      );
    }

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
              onPressed: state.isSaving ? null : onToggleAnswer,
              fullWidth: true,
            ),
            const SizedBox(height: SpacingTokens.xl),
          ],
        ),
      ),
    );
  }
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
