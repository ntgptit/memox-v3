import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

class StudySessionReviewModeView extends ConsumerWidget {
  const StudySessionReviewModeView({
    required this.sessionId,
    required this.mode,
    required this.onBack,
    super.key,
  });

  final String sessionId;
  final StudyMode? mode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudySessionReviewState> value = ref.watch(
      studySessionReviewControllerProvider((
        sessionId: sessionId,
        studyMode: mode,
      )),
    );

    return switch (value) {
      AsyncLoading<StudySessionReviewState>() => const MxScaffold(
        appBar: _StudySessionReviewAppBar(current: 0, total: 0, onClose: _noop),
        body: MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionReviewState>(:final error) =>
        _StudySessionReviewErrorState(error: error, onBack: onBack),
      AsyncData<StudySessionReviewState>(:final value) =>
        _StudySessionReviewBody(
          state: value,
          onBack: onBack,
          onOpenCardActions: (StudySessionReviewItem item) async {
            final MxStudySessionCardAction? action =
                await showStudySessionCardActions(
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
                context.pushFlashcardEdit(
                  item.flashcard.deckId,
                  item.flashcard.id,
                );
                return;
              case MxStudySessionCardAction.buryUntilTomorrow:
                await _applyCardAction(
                  context: context,
                  ref: ref,
                  sessionId: sessionId,
                  studyMode: mode,
                  successMessage: l10n.studySessionBurySuccessMessage,
                  failureMessage: l10n.studySessionCardActionFailedMessage,
                  call: () => ref
                      .read(study_di.buryStudySessionCardUseCaseProvider)
                      .call(
                        sessionId: sessionId,
                        flashcardId: item.flashcard.id,
                      ),
                );
                return;
              case MxStudySessionCardAction.suspend:
                await _applyCardAction(
                  context: context,
                  ref: ref,
                  sessionId: sessionId,
                  studyMode: mode,
                  successMessage: l10n.studySessionSuspendSuccessMessage,
                  failureMessage: l10n.studySessionCardActionFailedMessage,
                  call: () => ref
                      .read(study_di.suspendStudySessionCardUseCaseProvider)
                      .call(
                        sessionId: sessionId,
                        flashcardId: item.flashcard.id,
                      ),
                );
                return;
            }
          },
          onSwipeForgot: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .gradeForgot(),
          onSwipePerfect: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .gradePerfect(),
          onFinish: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .finishSession(),
          onFinalized: () => context.pushReplacementStudyResult(sessionId),
        ),
    };
  }
}

class _StudySessionReviewErrorState extends StatelessWidget {
  const _StudySessionReviewErrorState({
    required this.error,
    required this.onBack,
  });

  final Object error;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ({String title, String message}) copy = switch (error) {
      StudySessionFailureException(:final failure) => switch (failure) {
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

    return MxScaffold(
      appBar: _StudySessionReviewAppBar(current: 0, total: 0, onClose: onBack),
      body: MxErrorState(
        title: copy.title,
        message: copy.message,
        retryLabel: l10n.commonBack,
        onRetry: onBack,
      ),
    );
  }
}

class _StudySessionReviewBody extends StatelessWidget {
  const _StudySessionReviewBody({
    required this.state,
    required this.onBack,
    required this.onOpenCardActions,
    required this.onSwipeForgot,
    required this.onSwipePerfect,
    required this.onFinish,
    required this.onFinalized,
  });

  final StudySessionReviewState state;
  final VoidCallback onBack;
  final Future<void> Function(StudySessionReviewItem item) onOpenCardActions;
  final Future<void> Function() onSwipeForgot;
  final Future<void> Function() onSwipePerfect;
  final Future<bool> Function() onFinish;
  final VoidCallback onFinalized;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StudySessionReview review = state.review;
    final int total = review.items.length;
    final int answeredCount = review.items
        .where(
          (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
        )
        .length;
    final bool showSwipeHint =
        answeredCount < 3 && total > 0 && !state.allAnswered;
    final Widget? statusCallout = _buildStatusCallout(l10n);
    final VoidCallback? openActions = state.isBusy
        ? null
        : () => unawaited(onOpenCardActions(state.currentItem));

    return MxScaffold(
      appBar: _StudySessionReviewAppBar(
        current: answeredCount,
        total: total,
        onClose: onBack,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cardWidth = constraints.maxWidth >= 520
              ? 520
              : constraints.maxWidth;
          final double cardHeight = constraints.maxHeight >= 760
              ? 620
              : (constraints.maxHeight * 0.74).clamp(460, 620);

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: SpacingTokens.lg),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: SizedBox(
                      height: cardHeight,
                      child: _ReviewSwipeCard(
                        item: state.currentItem,
                        canSwipe: !state.isBusy && !state.allAnswered,
                        onLongPressCard: openActions,
                        onSwipeForgot: onSwipeForgot,
                        onSwipePerfect: onSwipePerfect,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                if (statusCallout != null) ...<Widget>[
                  statusCallout,
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (state.allAnswered) ...<Widget>[
                  _buildFinishButton(context, l10n),
                  const SizedBox(height: SpacingTokens.sm),
                ],
                if (showSwipeHint) ...<Widget>[
                  const SizedBox(height: SpacingTokens.sm),
                  Center(child: _SwipeHint(text: l10n.studySessionSwipeHint)),
                ],
                const SizedBox(height: SpacingTokens.xl),
              ],
            ),
          );
        },
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

class _ReviewSwipeCard extends StatefulWidget {
  const _ReviewSwipeCard({
    required this.item,
    required this.canSwipe,
    required this.onLongPressCard,
    required this.onSwipeForgot,
    required this.onSwipePerfect,
  });

  final StudySessionReviewItem item;
  final bool canSwipe;
  final VoidCallback? onLongPressCard;
  final Future<void> Function() onSwipeForgot;
  final Future<void> Function() onSwipePerfect;

  @override
  State<_ReviewSwipeCard> createState() => _ReviewSwipeCardState();
}

class _ReviewSwipeCardState extends State<_ReviewSwipeCard> {
  Offset? _dragStart;
  Offset? _dragLast;

  void _clearDrag() {
    _dragStart = null;
    _dragLast = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    _dragLast = event.position;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _dragLast = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    final Offset? start = _dragStart;
    final Offset end = _dragLast ?? event.position;
    _clearDrag();

    if (!widget.canSwipe || start == null) {
      return;
    }

    final double deltaX = end.dx - start.dx;
    final double deltaY = end.dy - start.dy;
    if (deltaX.abs() < 120 || deltaX.abs() <= deltaY.abs()) {
      return;
    }

    if (deltaX < 0) {
      unawaited(widget.onSwipeForgot());
      return;
    }
    unawaited(widget.onSwipePerfect());
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _clearDrag();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: MxCard(
        padding: EdgeInsets.zero,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: widget.onLongPressCard,
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StudySessionReviewLabel(
                  label: _languageLabel(l10n, widget.item.targetLanguage),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: MxText(
                        widget.item.flashcard.front,
                        role: MxTextRole.headlineMedium,
                        color: scheme.onSurface,
                        fontWeight: TypographyTokens.semiBold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Container(
                  height: BorderTokens.width,
                  color: scheme.outlineVariant,
                ),
                const SizedBox(height: SpacingTokens.lg),
                _StudySessionReviewLabel(label: l10n.studySessionMeaningLabel),
                const SizedBox(height: SpacingTokens.lg),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: MxText(
                            widget.item.flashcard.back,
                            role: MxTextRole.titleLarge,
                            color: scheme.onSurface,
                            fontWeight: TypographyTokens.semiBold,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (StringUtils.trimmed(
                          widget.item.flashcard.exampleSentence ?? '',
                        ).isNotEmpty) ...<Widget>[
                          const SizedBox(height: SpacingTokens.md),
                          _ExamplePill(
                            text: StringUtils.trimmed(
                              widget.item.flashcard.exampleSentence!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, TargetLanguage targetLanguage) =>
      switch (targetLanguage) {
        TargetLanguage.korean => l10n.flashcardListLanguageKorean,
        TargetLanguage.english => l10n.flashcardListLanguageEnglish,
        TargetLanguage.unsupported => l10n.flashcardListLanguageOther,
      };
}

class _StudySessionReviewLabel extends StatelessWidget {
  const _StudySessionReviewLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => MxText(
    StringUtils.uppercased(label),
    role: MxTextRole.labelSmall,
    color: context.colorScheme.onSurfaceVariant,
    fontWeight: TypographyTokens.bold,
  );
}

class _ExamplePill extends StatelessWidget {
  const _ExamplePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 280),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: OpacityTokens.hover,
        ),
        borderRadius: RadiusTokens.brFull,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        child: MxText(
          text,
          role: MxTextRole.labelLarge,
          textAlign: TextAlign.center,
          color: context.colorScheme.onSurface,
        ),
      ),
    ),
  );
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    hint: text,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.chevron_left,
          size: SizeTokens.iconMd,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: SpacingTokens.xs),
        MxText(
          text,
          role: MxTextRole.labelMedium,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    ),
  );
}

Future<void> _applyCardAction({
  required BuildContext context,
  required WidgetRef ref,
  required String sessionId,
  required StudyMode? studyMode,
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
        studySessionReviewControllerProvider((
          sessionId: sessionId,
          studyMode: studyMode,
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

class _StudySessionReviewAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _StudySessionReviewAppBar({
    required this.current,
    required this.total,
    required this.onClose,
  });

  final int current;
  final int total;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(SizeTokens.appbarLg);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = total <= 0 ? 0 : (current / total).clamp(0, 1);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: SizeTokens.appbarLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: Row(
                children: <Widget>[
                  MxIconButton.toolbar(
                    onPressed: onClose,
                    icon: Icons.close,
                    tooltip: AppLocalizations.of(context).commonClose,
                  ),
                  const Spacer(),
                  MxText(
                    total <= 0 ? '0 / 0' : '$current / $total',
                    role: MxTextRole.labelLarge,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: MxLinearProgress(
                value: progress,
                height: SpacingTokens.xs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}
