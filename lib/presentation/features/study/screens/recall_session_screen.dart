import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/recall_session_controller.dart';
import 'package:memox/presentation/features/study/widgets/study_speak_button.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Recall-mode study surface (mock `15-study-recall` / wireframe `16`),
/// reached via the session route with `?mode=recall`.
///
/// **WP-RC1 = the flip-card self-grade loop:** the ✕ + blue progress + count, the
/// prompt card (front + reading), a hidden "say it in your head" placeholder, the
/// **Show answer** CTA that reveals the back (green ANSWER card), then the binary
/// **Missed / Got it** grade row → record + advance → the last card finalizes →
/// the result. The front-prompt TTS speaker + auto-play on reveal are built (WBS
/// 8.4.3). The Show-answer countdown + auto-reveal-on-timeout (S63/S64) and the
/// edit affordance are deferred (WP-RC2/RC3).
class RecallSessionScreen extends ConsumerWidget {
  const RecallSessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // The last card graded + advanced → finalize + route to the result.
    ref.listen<AsyncValue<RecallView>>(
      recallSessionControllerProvider(sessionId),
      (AsyncValue<RecallView>? prev, AsyncValue<RecallView> next) {
        final bool wasFinished = prev?.value?.finished ?? false;
        if (!wasFinished && (next.value?.finished ?? false)) {
          unawaited(_finish(context, ref));
        }
      },
    );
    final AsyncValue<RecallView> async = ref.watch(
      recallSessionControllerProvider(sessionId),
    );
    return AppAsyncBuilder<RecallView>(
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
      data: (RecallView view) {
        final StudySessionReviewItem? item = view.currentItem;
        if (view.total == 0 || item == null) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          progress: (view.answeredCount, view.total),
          body: _cardBody(context, ref, l10n, item, view),
        );
      },
    );
  }

  Widget _shell(
    BuildContext context,
    AppLocalizations l10n, {
    required (int answered, int total)? progress,
    required Widget body,
  }) => MxScaffold(
    appBar: MxAppBar(
      automaticallyImplyLeading: false,
      leading: MxIconButton.toolbar(
        key: const ValueKey<String>('mx-node:study-session/exit'),
        icon: Icons.close,
        tooltip: l10n.commonCancel,
        onPressed: () => unawaited(_confirmExit(context, l10n, progress)),
      ),
      title: progress == null ? l10n.studySessionTitle : null,
      titleWidget: progress == null
          ? null
          : MxLinearProgress(
              key: const ValueKey<String>('mx-node:study-session/progress'),
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

  /// Exit guard (shared with Review §exit-session): confirm once any card is
  /// graded, else pop straight away.
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
      barrierDismissible: false,
    );
    if (!leave) return;
    if (!context.mounted) return;
    context.pop();
  }

  Widget _cardBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    StudySessionReviewItem item,
    RecallView view,
  ) {
    final RecallSessionController controller = ref.read(
      recallSessionControllerProvider(sessionId).notifier,
    );
    return StudyTtsAutoPlay(
      item: item,
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _PromptCard(prompt: l10n.studyRecallPrompt, item: item),
            const SizedBox(height: MxSpacing.space4),
            Expanded(
              child: view.revealed
                  ? _AnswerCard(
                      label: l10n.studyRecallAnswerLabel,
                      back: item.back,
                    )
                  : _HiddenHint(message: l10n.studyRecallHint),
            ),
            const SizedBox(height: MxSpacing.space3),
            view.revealed
                ? _GradeRow(
                    caption: l10n.studyRecallGradePrompt,
                    missedLabel: l10n.studyRecallMissed,
                    gotItLabel: l10n.studyRecallGotIt,
                    onMissed: () => unawaited(controller.grade(gotIt: false)),
                    onGotIt: () => unawaited(controller.grade(gotIt: true)),
                  )
                : MxPrimaryButton(
                    key: const ValueKey<String>('mx-node:study-session/action'),
                    label: l10n.studyRecallShowAnswer,
                    icon: Icons.visibility_outlined,
                    fullWidth: true,
                    onPressed: controller.reveal,
                  ),
          ],
        ),
      ),
    );
  }

  /// Last card graded → finalize (binary one-terminal-attempt path) then
  /// `pushReplacement` to the shared result screen (mirrors WP-SR5a/SG2).
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
      onPressed: () =>
          ref.invalidate(recallSessionControllerProvider(sessionId)),
    ),
  );
}

/// The prompt card: an overline + the front (target term) + its reading.
class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt, required this.item});

  final String prompt;
  final StudySessionReviewItem item;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? reading = item.pronunciation;
    return MxCard(
      key: const ValueKey<String>('mx-node:study-session/content-card'),
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(
              StringUtils.upperFold(prompt),
              role: MxTextRole.labelSmall,
              color: colors.textTertiary,
            ),
            const SizedBox(height: MxSpacing.space2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: MxText(item.front, role: MxTextRole.displayLarge),
                ),
                StudySpeakButton(item: item),
              ],
            ),
            if (reading != null && reading.isNotEmpty) ...<Widget>[
              const SizedBox(height: MxSpacing.space1),
              MxText(
                reading,
                role: MxTextRole.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The hidden-answer placeholder shown before **Show answer** — a calm prompt to
/// retrieve the meaning before revealing.
class _HiddenHint extends StatelessWidget {
  const _HiddenHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.psychology_outlined,
            size: MxIconSize.lg,
            color: colors.textTertiary,
          ),
          const SizedBox(height: MxSpacing.space2),
          MxText(
            message,
            role: MxTextRole.bodyLarge,
            color: colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// The revealed back, in a soft green "ANSWER" card (success family).
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.label, required this.back});

  final String label;
  final String back;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Align(
      alignment: Alignment.topCenter,
      // Full width, hug height, top-aligned (the card sits below the prompt, not
      // stretched to fill the gap before the grade row).
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.successSoft,
            borderRadius: MxRadius.mdAll,
            border: Border.all(color: colors.success, width: MxStroke.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  StringUtils.upperFold(label),
                  role: MxTextRole.labelSmall,
                  color: colors.success,
                ),
                const SizedBox(height: MxSpacing.space2),
                MxText(back, role: MxTextRole.titleLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The binary self-grade row: a caption + Missed (red) / Got it (green) chips
/// (decision S66 — binary; the mock's middle "Partial" is a documented conflict
/// not in the V1 BE).
class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.caption,
    required this.missedLabel,
    required this.gotItLabel,
    required this.onMissed,
    required this.onGotIt,
  });

  final String caption;
  final String missedLabel;
  final String gotItLabel;
  final VoidCallback onMissed;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxText(
          StringUtils.upperFold(caption),
          role: MxTextRole.labelSmall,
          color: colors.textTertiary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: MxSpacing.space3),
        Row(
          children: <Widget>[
            Expanded(
              child: _GradeButton(
                icon: Icons.close,
                label: missedLabel,
                tint: colors.selfMissed,
                background: colors.dangerSoft,
                onTap: onMissed,
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: _GradeButton(
                icon: Icons.check,
                label: gotItLabel,
                tint: colors.selfGot,
                background: colors.successSoft,
                onTap: onGotIt,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One soft-tinted grade chip (icon over label, centered) — the Missed / Got it
/// buttons of the recall grade row.
class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.icon,
    required this.label,
    required this.tint,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MxTappable(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: MxRadius.mdAll,
        border: Border.all(color: tint, width: MxStroke.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: MxIconSize.md, color: tint),
            const SizedBox(height: MxSpacing.space1),
            MxText(label, role: MxTextRole.labelMedium, color: tint),
          ],
        ),
      ),
    ),
  );
}
