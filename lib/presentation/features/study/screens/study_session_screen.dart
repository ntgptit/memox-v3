import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_controller.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/features/study/widgets/study_card_actions_sheet.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The active Review-mode study session (mock `12` / wireframe `13`).
///
/// The `✕` exit + a blue (recognition-family) progress bar + `{answered}/{total}`
/// count, and the card showing **both sides at once** (front-side label → front →
/// divider → back-side label → back → example pill) with no reveal step (WP-SR2).
/// **WP-SR3** grades by **swipe** (right → `perfect`, left → `forgot` via
/// `StudySessionController`) and advances; a swipe-hint shows for the first cards;
/// the last graded card → a Finish surface (finalize→result = WP-SR5). Exit-confirm
/// + card-actions = WP-SR4. The front/back labels fall back to FRONT/BACK — the
/// language labels (KOREAN/MEANING from `deck.target_language`) are WP-SR2b. WBS 4.5.3.
class StudySessionScreen extends ConsumerWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudySessionView> async = ref.watch(
      studySessionControllerProvider(sessionId),
    );
    return AppAsyncBuilder<StudySessionView>(
      value: async,
      loading: (_) => _shell(
        context,
        l10n,
        progress: null,
        body: MxLoadingState(message: l10n.studyPreparing),
      ),
      error: (_, _) => _shell(
        context,
        l10n,
        progress: null,
        body: _errorBody(context, ref, l10n),
      ),
      data: (StudySessionView view) {
        if (view.total == 0) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          progress: (view.answeredCount, view.total),
          body: view.isFinished
              ? _finishBody(context, ref, l10n)
              : _gradeBody(context, ref, view),
        );
      },
    );
  }

  /// The immersive session shell: `✕` exit + the blue progress bar (when known)
  /// + the `{answered}/{total}` count. No mode pill (Review is the default mode).
  Widget _shell(
    BuildContext context,
    AppLocalizations l10n, {
    required (int answered, int total)? progress,
    required Widget body,
  }) => MxScaffold(
    appBar: MxAppBar(
      automaticallyImplyLeading: false,
      leading: MxIconButton.toolbar(
        icon: Icons.close,
        tooltip: l10n.commonCancel,
        onPressed: () => _confirmExit(context, l10n, progress),
      ),
      // The app bar needs a title or titleWidget; the loading/error/empty shells
      // (no progress yet) fall back to the session title.
      title: progress == null ? l10n.studySessionTitle : null,
      titleWidget: progress == null
          ? null
          : MxLinearProgress(
              value: progress.$2 <= 0 ? 0 : progress.$1 / progress.$2,
            ),
      actions: <Widget>[
        if (progress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
            child: Center(
              child: MxText(
                '${progress.$1} / ${progress.$2}',
                role: MxTextRole.labelMedium,
              ),
            ),
          ),
      ],
    ),
    body: body,
  );

  /// Exit guard (wireframe `13` Rule "exit confirmation when answered > 0"):
  /// once any card is graded, `✕` confirms before leaving (progress is saved and
  /// resumable); with nothing graded yet it pops straight away.
  Future<void> _confirmExit(
    BuildContext context,
    AppLocalizations l10n,
    (int answered, int total)? progress,
  ) async {
    final int answered = progress?.$1 ?? 0;
    if (answered == 0) {
      context.pop();
      return;
    }
    final bool leave = await MxConfirmDialog.show(
      context,
      title: l10n.studyExitTitle,
      message: l10n.studyExitMessage,
      confirmLabel: l10n.studyExitConfirm,
      cancelLabel: l10n.studyExitCancel,
      barrierDismissible:
          false, // §exit-session: shared dialogs are modal-locked
    );
    if (!leave) return;
    if (!context.mounted) return;
    context.pop();
  }

  Widget _emptyBody(AppLocalizations l10n) => MxEmptyState(
    icon: Icons.style_outlined,
    title: l10n.studyReviewEmptyTitle,
    message: l10n.studyReviewEmptyMessage,
  );

  Widget _errorBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => MxErrorState(
    title: l10n.studyReviewLoadFailedTitle,
    message: l10n.studyReviewLoadFailedMessage,
    icon: Icons.cloud_off_outlined,
    action: MxSecondaryButton(
      label: l10n.commonRetryLabel,
      onPressed: () => ref.invalidate(studySessionReviewProvider(sessionId)),
    ),
  );

  /// Cards that still show the swipe hint before it fades out.
  static const int _swipeHintCards = 3;

  /// The gradeable card: swipe right → `perfect`, left → `forgot` (wireframe
  /// `13` Actions) → `StudySessionController.grade`, which advances to the next
  /// card. The swipe hint shows for the first few cards.
  Widget _gradeBody(
    BuildContext context,
    WidgetRef ref,
    StudySessionView view,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StudySessionReviewItem? item = view.currentItem;
    if (item == null) return const SizedBox.shrink();
    return Column(
      children: <Widget>[
        Expanded(
          child: Dismissible(
            key: ValueKey<String>('study-card-${item.sessionItemId}'),
            onDismissed: (DismissDirection direction) {
              final AttemptResult result =
                  direction == DismissDirection.startToEnd
                  ? AttemptResult.perfect
                  : AttemptResult.forgot;
              // Fire-and-forget: grade advances the card + persists in the
              // background (the gesture has already moved on).
              unawaited(
                ref
                    .read(studySessionControllerProvider(sessionId).notifier)
                    .grade(result),
              );
            },
            // a11y: announce the swipe-grade gesture on the card region
            // (wireframe `13` §Accessibility).
            child: Semantics(
              hint: l10n.studyReviewSwipeHint,
              // Long-press opens the card-actions sheet (Bury / Suspend).
              child: GestureDetector(
                onLongPress: () => _openCardActions(context, ref),
                child: _ReviewCard(item: item),
              ),
            ),
          ),
        ),
        if (view.currentIndex < _swipeHintCards)
          Padding(
            padding: const EdgeInsets.only(bottom: MxSpacing.space4),
            child: MxText(
              l10n.studyReviewSwipeHint,
              role: MxTextRole.bodySmall,
              color: context.mxColors.textTertiary,
            ),
          ),
      ],
    );
  }

  /// Long-press the card → the card-actions sheet (wireframe `13` Actions): Bury
  /// until tomorrow / Suspend card. Both remove the card from the session and
  /// re-queue (`StudySessionController`). Edit = WP-SR4b-2 (needs the deck id).
  Future<void> _openCardActions(BuildContext context, WidgetRef ref) async {
    final StudyCardAction? action = await showStudyCardActionsSheet(context);
    if (action == null) return;
    if (!context.mounted) return;
    final StudySessionController notifier = ref.read(
      studySessionControllerProvider(sessionId).notifier,
    );
    switch (action) {
      case StudyCardAction.buryUntilTomorrow:
        unawaited(notifier.buryCurrent());
      case StudyCardAction.suspend:
        unawaited(notifier.suspendCurrent());
    }
  }

  /// The end-of-session surface — every card graded. The Finish action
  /// finalizes the session (`FinalizeStudySessionUseCase` — applies the Leitner
  /// SRS transition + marks `completed`) then `pushReplacement`s to the result
  /// screen (WP-SR5a), so Back from the result returns to the caller, not here.
  Widget _finishBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => MxEmptyState(
    icon: Icons.celebration_outlined,
    title: l10n.studyReviewFinishTitle,
    message: l10n.studyReviewFinishMessage,
    action: MxPrimaryButton(
      label: l10n.studyReviewFinishAction,
      onPressed: () => unawaited(_finish(context, ref)),
    ),
  );

  /// Finalize then open the result screen. The finalize result is **not** gated
  /// on here — the user can always leave (wireframe `18` Forbidden); a finalize
  /// failure persists `failed_to_finalize`, which the result screen surfaces as
  /// the save-failed state (WP-SR5b).
  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    await ref
        .read(finalizeStudySessionUseCaseProvider)
        .call(sessionId: sessionId);
    if (!context.mounted) return;
    context.pushReplacementNamed(
      RouteNames.studyResult,
      pathParameters: <String, String>{RouteParams.sessionId: sessionId},
    );
  }
}

/// The Review card: both sides on one surface (mock `12` / wireframe `13`) —
/// front-side label, front (display), divider, back-side label, back, and the
/// optional example pill. No reveal step. `note`/`pronunciation`/`hint` are not
/// shown in study session (Phase 1).
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item});

  final StudySessionReviewItem item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final String? example = item.exampleSentence;
    // The card fills the viewport (wireframe `13`: card occupies most of the
    // screen, grow:1) with the content centered vertically.
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space4),
      child: SizedBox.expand(
        child: MxCard(
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _SideLabel(text: l10n.studyReviewFrontLabel),
                const SizedBox(height: MxSpacing.space4),
                MxText(
                  item.front,
                  role: MxTextRole.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MxSpacing.space5),
                const MxDivider(),
                const SizedBox(height: MxSpacing.space5),
                _SideLabel(text: l10n.studyReviewBackLabel),
                const SizedBox(height: MxSpacing.space4),
                MxText(
                  item.back,
                  role: MxTextRole.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (example != null && example.isNotEmpty) ...<Widget>[
                  const SizedBox(height: MxSpacing.space5),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: MxRadius.mdAll,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MxSpacing.space4,
                          vertical: MxSpacing.space3,
                        ),
                        child: MxText(
                          example,
                          role: MxTextRole.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The uppercase caption above each side of the card.
class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => MxText(
    text,
    role: MxTextRole.labelSmall,
    color: context.mxColors.textTertiary,
  );
}
