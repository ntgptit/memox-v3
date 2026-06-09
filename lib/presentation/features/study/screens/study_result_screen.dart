import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_result_viewmodel.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_stat_display.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

class StudyResultScreen extends StatelessWidget {
  const StudyResultScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(titleText: l10n.studyResultTitle),
      useShell: false,
      body: MxContentShell(child: _StudyResultBody(sessionId: sessionId)),
    );
  }
}

class _StudyResultBody extends ConsumerWidget {
  const _StudyResultBody({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudyResultScreenState> value = ref.watch(
      studyResultControllerProvider(sessionId),
    );

    return AppAsyncBuilder<StudyResultScreenState>(
      value: value,
      loading: (BuildContext context) => const MxLoadingState(rows: 3),
      error: (Object error, StackTrace? stackTrace) =>
          const _StudyResultLoadError(),
      data: (StudyResultScreenState data) => switch (data) {
        InvalidSessionId() => _StudyResultFailureState(
          icon: Icons.link_off,
          title: l10n.studyResultInvalidTitle,
          message: l10n.studyResultInvalidMessage,
          actionLabel: l10n.studyResultBackToLibraryAction,
          onAction: context.goLibrary,
        ),
        NotFound() => _StudyResultFailureState(
          icon: Icons.search_off,
          title: l10n.studySessionNotFoundTitle,
          message: l10n.studySessionNotFoundMessage,
          actionLabel: l10n.studyResultBackToLibraryAction,
          onAction: context.goLibrary,
        ),
        NotCompleted(:final status) => _StudyResultNotCompletedState(
          status: status,
          onBackToLibrary: context.goLibrary,
        ),
        Success(:final result) => _StudyResultSuccessState(
          result: result,
          onBackToLibrary: context.goLibrary,
          onBackToHome: context.goHome,
        ),
        StudyResultScreenState() => const SizedBox.shrink(),
      },
    );
  }
}

class _StudyResultLoadError extends StatelessWidget {
  const _StudyResultLoadError();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxErrorState(
      title: l10n.studySessionLoadFailedTitle,
      message: l10n.studySessionLoadFailedMessage,
      retryLabel: l10n.studyResultBackToLibraryAction,
      onRetry: context.goLibrary,
    );
  }
}

class _StudyResultFailureState extends StatelessWidget {
  const _StudyResultFailureState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => MxErrorState(
    icon: icon,
    title: title,
    message: message,
    retryLabel: actionLabel,
    onRetry: onAction,
  );
}

class _StudyResultNotCompletedState extends StatelessWidget {
  const _StudyResultNotCompletedState({
    required this.status,
    required this.onBackToLibrary,
  });

  final SessionStatus status;
  final VoidCallback onBackToLibrary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String statusLabel = switch (status) {
      SessionStatus.draft => l10n.studyResultDraft,
      SessionStatus.inProgress => l10n.studyResultInProgress,
      SessionStatus.completed => l10n.studyResultCompleted,
      SessionStatus.cancelled => l10n.studyResultCancelled,
      SessionStatus.failedToFinalize => l10n.studyResultFailedFinalize,
    };

    return MxEmptyState(
      icon: Icons.hourglass_empty,
      title: l10n.studyResultNotCompleteTitle,
      message: l10n.studyResultNotCompleteMessageWithStatus(statusLabel),
      actionLabel: l10n.studyResultBackToLibraryAction,
      onAction: onBackToLibrary,
    );
  }
}

class _StudyResultSuccessState extends StatelessWidget {
  const _StudyResultSuccessState({
    required this.result,
    required this.onBackToLibrary,
    required this.onBackToHome,
  });

  final StudySessionResult result;
  final VoidCallback onBackToLibrary;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) => _StudyResultSuccessContent(
    result: result,
    onBackToLibrary: onBackToLibrary,
    onBackToHome: onBackToHome,
  );
}

class _StudyResultSuccessContent extends StatelessWidget {
  const _StudyResultSuccessContent({
    required this.result,
    required this.onBackToLibrary,
    required this.onBackToHome,
  });

  final StudySessionResult result;
  final VoidCallback onBackToLibrary;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SpacingTokens.lg),
        _StudyResultSuccessHeader(result: result),
        const SizedBox(height: SpacingTokens.lg),
        _StudyResultBreakdownCard(result: result),
        const SizedBox(height: SpacingTokens.lg),
        _StudyResultSuccessActions(
          onBackToLibrary: onBackToLibrary,
          onBackToHome: onBackToHome,
        ),
        const SizedBox(height: SpacingTokens.lg),
      ],
    ),
  );
}

class _StudyResultSuccessHeader extends StatelessWidget {
  const _StudyResultSuccessHeader({required this.result});

  final StudySessionResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SpacingTokens.xs),
        Icon(
          Icons.celebration,
          size: SizeTokens.iconLg,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          l10n.studyResultCompleted,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          l10n.studyResultCardsCompleted(
            result.answeredCount,
            result.totalCount,
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StudyResultBreakdownCard extends StatelessWidget {
  const _StudyResultBreakdownCard({required this.result});

  final StudySessionResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxSectionHeader(label: l10n.studyResultBreakdownTitle),
          const SizedBox(height: SpacingTokens.md),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wide = constraints.maxWidth >= 600;
              final double itemWidth = wide
                  ? (constraints.maxWidth - SpacingTokens.md) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.md,
                children: <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: _StudyResultStat(
                      value: result.totalCount.toString(),
                      label: l10n.studyResultCards,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _StudyResultStat(
                      value: result.answeredCount.toString(),
                      label: l10n.studyResultAnswered,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _StudyResultStat(
                      value: result.passedCount.toString(),
                      label: l10n.studyResultPassed,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _StudyResultStat(
                      value: result.forgotCount.toString(),
                      label: l10n.studyResultForgot,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudyResultSuccessActions extends StatelessWidget {
  const _StudyResultSuccessActions({
    required this.onBackToLibrary,
    required this.onBackToHome,
  });

  final VoidCallback onBackToLibrary;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxActionButton(
          intent: MxActionIntent.screenPrimary,
          label: l10n.studyResultBackToLibraryAction,
          onPressed: onBackToLibrary,
          fullWidth: true,
        ),
        const SizedBox(height: SpacingTokens.sm),
        MxSecondaryButton(
          label: l10n.studyResultBackToHomeAction,
          onPressed: onBackToHome,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _StudyResultStat extends StatelessWidget {
  const _StudyResultStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.all(SpacingTokens.md),
    child: MxStatDisplay(value: value, caption: label),
  );
}
