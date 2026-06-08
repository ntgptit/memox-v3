import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
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
    final AsyncValue<StudySessionReview> value = ref.watch(
      studySessionReviewProvider(sessionId),
    );

    return switch (value) {
      AsyncLoading<StudySessionReview>() => const MxLoadingState(rows: 3),
      AsyncError<StudySessionReview>(:final error) => _StudySessionErrorState(
        error: error,
        onBack: onBack,
      ),
      AsyncData<StudySessionReview>(:final value) => _StudySessionBody(
        review: value,
        showAnswer: ref.watch(studySessionRevealAnswerProvider(sessionId)),
        onToggleAnswer: () {
          ref.read(
            studySessionRevealAnswerProvider(sessionId).notifier,
          ).toggle();
        },
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
    required this.review,
    required this.showAnswer,
    required this.onToggleAnswer,
  });

  final StudySessionReview review;
  final bool showAnswer;
  final VoidCallback onToggleAnswer;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final StudySessionReviewItem item = review.items.first;
    final int total = review.items.length;
    final TextTheme textTheme = theme.textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: SpacingTokens.xl),
            Text(
              l10n.studySessionProgressLabel(1, total),
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
              showBack: showAnswer,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxActionButton(
              intent: MxActionIntent.screenPrimary,
              label: showAnswer
                  ? l10n.studySessionHideAction
                  : l10n.studySessionShowAction,
              onPressed: onToggleAnswer,
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
