import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/study/match/match_board.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_match_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/study/mx_match_tile.dart';

class StudySessionMatchModeView extends ConsumerStatefulWidget {
  const StudySessionMatchModeView({
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
  ConsumerState<StudySessionMatchModeView> createState() =>
      _StudySessionMatchModeViewState();
}

class _StudySessionMatchModeViewState
    extends ConsumerState<StudySessionMatchModeView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(DurationTokens.slower, (_) {
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
    final provider = studySessionMatchControllerProvider((
      sessionId: widget.sessionId,
      studyMode: widget.mode,
    ));

    ref.listen<AsyncValue<StudySessionMatchState>>(provider, (
      AsyncValue<StudySessionMatchState>? previous,
      AsyncValue<StudySessionMatchState> next,
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

    final AsyncValue<StudySessionMatchState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionMatchState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionMatchModeLabel,
          current: 0,
          total: 0,
          onClose: widget.onBack,
          accent: context.colorScheme.primary,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionMatchState>(:final error) =>
        _StudySessionMatchErrorState(error: error, onBack: widget.onBack),
      AsyncData<StudySessionMatchState>(:final value) => _StudySessionMatchBody(
        state: value,
        sessionId: widget.sessionId,
        mode: widget.mode,
        onBack: widget.onBack,
        onOpenCardActions: (MatchBoardCell cell) => _openCardActions(
          context,
          ref,
          value,
          widget.sessionId,
          widget.mode,
          cell,
        ),
        onTapCell: (MatchBoardCell cell) =>
            ref.read(provider.notifier).tapCell(cell),
        onRetryFinalize: () => ref.read(provider.notifier).retryFinalize(),
      ),
    };
  }
}

class _StudySessionMatchErrorState extends StatelessWidget {
  const _StudySessionMatchErrorState({
    required this.error,
    required this.onBack,
  });

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String message}) copy = switch (error) {
      StudySessionMatchFailureException(:final failure) => (
        title: switch (failure) {
          NotFoundFailure() => l10n.studySessionNotFoundTitle,
          _ => l10n.studySessionLoadFailedTitle,
        },
        message: switch (failure) {
          NotFoundFailure() => l10n.studySessionNotFoundMessage,
          _ => l10n.studySessionLoadFailedMessage,
        },
      ),
      _ => (
        title: l10n.studySessionLoadFailedTitle,
        message: l10n.studySessionLoadFailedMessage,
      ),
    };

    return MxStudyScaffold(
      topBar: MxStudyTopBar(
        modeLabel: l10n.studySessionMatchModeLabel,
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

class _StudySessionMatchBody extends StatelessWidget {
  const _StudySessionMatchBody({
    required this.state,
    required this.sessionId,
    required this.mode,
    required this.onBack,
    required this.onOpenCardActions,
    required this.onTapCell,
    required this.onRetryFinalize,
  });

  final StudySessionMatchState state;
  final String sessionId;
  final StudyMode? mode;
  final VoidCallback onBack;
  final Future<void> Function(MatchBoardCell cell) onOpenCardActions;
  final void Function(MatchBoardCell cell) onTapCell;
  final Future<void> Function() onRetryFinalize;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final Widget? statusCallout = _buildStatusCallout(l10n, state);
    final Widget? retryButton = state.finalizeFailure != null && !state.isBusy
        ? MxActionButton(
            intent: MxActionIntent.screenPrimary,
            label: l10n.studyFinalizeAction,
            onPressed: () async {
              await onRetryFinalize();
            },
            fullWidth: true,
          )
        : null;

    return MxStudyScaffold(
      topBar: MxStudyTopBar(
        modeLabel: l10n.studySessionMatchModeLabel,
        current: state.matchedCount,
        total: state.totalCards,
        onClose: onBack,
        accent: scheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedOpacity(
              duration: DurationTokens.contentSwitch,
              opacity: state.isAdvancing || state.isFinalizing ? 0.0 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: SpacingTokens.xs),
                  Center(
                    child: MxText(
                      l10n.studySessionMatchBoardIndicator(
                        state.visibleBoardIndex + 1,
                        state.totalBoards,
                        state.pairsLeft,
                      ),
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  _StudySessionMatchBoard(
                    state: state,
                    onTapCell: onTapCell,
                    onOpenCardActions: onOpenCardActions,
                  ),
                ],
              ),
            ),
            if (statusCallout != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.md),
              statusCallout,
            ],
            if (retryButton != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.md),
              retryButton,
            ],
          ],
        ),
      ),
      bottomAction: _StudySessionMatchFooter(state: state),
    );
  }

  Widget? _buildStatusCallout(
    AppLocalizations l10n,
    StudySessionMatchState state,
  ) {
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

class _StudySessionMatchBoard extends StatelessWidget {
  const _StudySessionMatchBoard({
    required this.state,
    required this.onTapCell,
    required this.onOpenCardActions,
  });

  final StudySessionMatchState state;
  final void Function(MatchBoardCell cell) onTapCell;
  final Future<void> Function(MatchBoardCell cell) onOpenCardActions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final MatchBoard board = state.currentBoard;
      const double crossAxisSpacing = SpacingTokens.sm;
      final double tileWidth = (constraints.maxWidth - crossAxisSpacing) / 2;
      const double cellAspectRatio = 1.7;
      final double tileHeight = tileWidth / cellAspectRatio;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: SpacingTokens.sm,
          crossAxisSpacing: SpacingTokens.sm,
          childAspectRatio: cellAspectRatio,
        ),
        itemCount: board.cells.length,
        itemBuilder: (BuildContext context, int index) {
          final MatchBoardCell cell = board.cells[index];
          final MxMatchState visualState = switch (true) {
            true when state.wrongFlashCellIds.contains(cell.id) =>
              MxMatchState.wrong,
            true when state.selectedCellId == cell.id => MxMatchState.selected,
            true when state.isCellMatched(cell.id) => MxMatchState.matched,
            _ => MxMatchState.idle,
          };

          return GestureDetector(
            onLongPress: state.isBusy
                ? null
                : () => unawaited(onOpenCardActions(cell)),
            child: MxMatchTile(
              label: cell.text,
              state: visualState,
              onTap: state.isBusy ? null : () => onTapCell(cell),
              height: tileHeight,
            ),
          );
        },
      );
    },
  );
}

class _StudySessionMatchFooter extends StatelessWidget {
  const _StudySessionMatchFooter({required this.state});

  final StudySessionMatchState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Duration elapsed = DateTime.now().difference(state.boardStartedAt);
    final String timerLabel = _formatElapsed(elapsed);
    final String mistakesLabel = l10n.studySessionMatchMistakesLabel(
      state.evaluations
          .where((StudyMatchEvaluation evaluation) => !evaluation.isCorrect)
          .length,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _FooterPill(icon: Icons.timer_outlined, label: timerLabel),
        MxText(
          mistakesLabel,
          role: MxTextRole.labelLarge,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _FooterPill extends StatelessWidget {
  const _FooterPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: SizeTokens.iconSm, color: scheme.onSurfaceVariant),
        const SizedBox(width: SpacingTokens.xs),
        MxText(
          label,
          role: MxTextRole.labelLarge,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

String _formatElapsed(Duration elapsed) {
  final int minutes = elapsed.inMinutes;
  final int seconds = elapsed.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

Future<void> _openCardActions(
  BuildContext context,
  WidgetRef ref,
  StudySessionMatchState state,
  String sessionId,
  StudyMode? mode,
  MatchBoardCell cell,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final reviewItem = state.review.items.firstWhere(
    (item) => item.flashcard.id == cell.flashcardId,
  );
  final MxStudySessionCardAction? action = await showStudySessionCardActions(
    context,
    front: reviewItem.flashcard.front,
  );
  if (!context.mounted) {
    return;
  }
  if (action == null) {
    return;
  }

  switch (action) {
    case MxStudySessionCardAction.edit:
      context.pushFlashcardEdit(
        reviewItem.flashcard.deckId,
        reviewItem.flashcard.id,
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
            .call(sessionId: sessionId, flashcardId: cell.flashcardId),
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
            .call(sessionId: sessionId, flashcardId: cell.flashcardId),
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
        studySessionMatchControllerProvider((
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
