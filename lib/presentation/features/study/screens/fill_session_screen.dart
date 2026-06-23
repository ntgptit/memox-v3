import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/app_motion.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/fill_session_controller.dart';
import 'package:memox/presentation/features/study/widgets/fill_session_areas.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The Fill-mode study surface (mock `16-study-fill` / wireframe `17`), reached
/// via the session route with `?mode=fill`.
///
/// **WP-FI1 = the typed-production loop:** the ✕ + blue progress + count, the hint
/// card (the back / definition), a free-text answer field, **Check** → a strict
/// trim-only match of the typed front (`perfect` / `forgot`); correct → ✓ + Next,
/// wrong → the CORRECT ANSWER card + Retry / Next → record + advance → the last
/// card finalizes → the result. **Mark correct (WP-FI2a) + Hint (WP-FI2b) →
/// `recovered`, and a correct answer auto-advances after a 0.8s countdown
/// (WP-FI2c) are built**; the last-card Finish callout, finalize-fail surface,
/// and edit / TTS affordances remain deferred (WP-FI2).
class FillSessionScreen extends HookConsumerWidget {
  const FillSessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxTextSubmitState field = useMxTextSubmitState();
    // The answer submitted for the current card — mirrored in the feedback states.
    final ValueNotifier<String> submitted = useState<String>('');
    final FillSessionController controller = ref.read(
      fillSessionControllerProvider(sessionId).notifier,
    );

    // The last card graded + advanced → finalize + route to the result.
    ref.listen<AsyncValue<FillView>>(fillSessionControllerProvider(sessionId), (
      AsyncValue<FillView>? prev,
      AsyncValue<FillView> next,
    ) {
      final bool wasFinished = prev?.value?.finished ?? false;
      if (!wasFinished && (next.value?.finished ?? false)) {
        unawaited(_finish(context, ref));
      }
    });

    void check() {
      // Read the live controller text (the hook snapshot can lag the tap).
      final String text = field.controller.text;
      submitted.value = text;
      controller.check(text);
    }

    void retry() {
      field.controller.clear();
      submitted.value = '';
      controller.retry();
    }

    void next() {
      field.controller.clear();
      submitted.value = '';
      unawaited(controller.next());
    }

    void markCorrect() => controller.markCorrect();

    void hint() => controller.hint();

    final AsyncValue<FillView> async = ref.watch(
      fillSessionControllerProvider(sessionId),
    );
    return AppAsyncBuilder<FillView>(
      value: async,
      loading: (_) => _shell(
        context,
        l10n,
        progress: null,
        body: MxLoadingState(message: l10n.studyPreparing),
      ),
      error: (_, _) =>
          _shell(context, l10n, progress: null, body: _errorBody(ref, l10n)),
      data: (FillView view) {
        final StudySessionReviewItem? item = view.currentItem;
        if (view.total == 0 || item == null) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          progress: (view.answeredCount, view.total),
          body: _cardBody(
            l10n,
            item,
            view,
            field: field,
            submitted: submitted.value,
            canCheck: field.canSubmit,
            onCheck: check,
            onRetry: retry,
            onNext: next,
            onMarkCorrect: markCorrect,
            onHint: hint,
          ),
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
  /// graded, otherwise pop straight away.
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
    AppLocalizations l10n,
    StudySessionReviewItem item,
    FillView view, {
    required MxTextSubmitState field,
    required String submitted,
    required bool canCheck,
    required VoidCallback onCheck,
    required VoidCallback onRetry,
    required VoidCallback onNext,
    required VoidCallback onMarkCorrect,
    required VoidCallback onHint,
  }) => Padding(
    padding: const EdgeInsets.all(MxSpacing.space5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FillHintCard(prompt: l10n.studyFillPrompt, hint: item.back),
        const SizedBox(height: MxSpacing.space4),
        Expanded(
          child: _answerArea(
            l10n,
            item,
            view,
            field: field,
            submitted: submitted,
          ),
        ),
        const SizedBox(height: MxSpacing.space3),
        _actions(
          l10n,
          view,
          canCheck: canCheck,
          onCheck: onCheck,
          onRetry: onRetry,
          onNext: onNext,
          onMarkCorrect: onMarkCorrect,
          onHint: onHint,
        ),
      ],
    ),
  );

  Widget _answerArea(
    AppLocalizations l10n,
    StudySessionReviewItem item,
    FillView view, {
    required MxTextSubmitState field,
    required String submitted,
  }) {
    switch (view.phase) {
      case FillPhase.typing:
        return FillTypingArea(
          label: l10n.studyFillAnswerLabel,
          controller: field.controller,
          // The Hint reveals leading characters of the front (WP-FI2b, S69).
          revealedHint: view.hintRevealed > 0
              ? _hintMask(item.front, view.hintRevealed)
              : null,
        );
      case FillPhase.correct:
        return FillCorrectArea(answer: submitted);
      case FillPhase.wrong:
        return FillWrongArea(
          submitted: submitted,
          message: l10n.studyFillWrongMessage,
          correctLabel: l10n.studyFillCorrectLabel,
          correct: item.front,
        );
    }
  }

  /// The Hint mask: the first [revealed] characters of [front] + a `·` per
  /// hidden character (e.g. front "yama", revealed 2 → "ya··").
  String _hintMask(String front, int revealed) {
    final String trimmed = StringUtils.trimmed(front);
    final int shown = revealed.clamp(0, trimmed.length);
    return trimmed.substring(0, shown) + ('·' * (trimmed.length - shown));
  }

  Widget _actions(
    AppLocalizations l10n,
    FillView view, {
    required bool canCheck,
    required VoidCallback onCheck,
    required VoidCallback onRetry,
    required VoidCallback onNext,
    required VoidCallback onMarkCorrect,
    required VoidCallback onHint,
  }) {
    switch (view.phase) {
      case FillPhase.typing:
        // Full-width Check (mock); the Hint affordance (→ taint, S69) is a discreet
        // link below it — the mock has no Hint button (variance, PRECEDENCE #1).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MxPrimaryButton(
              label: l10n.studyFillCheck,
              icon: Icons.check,
              fullWidth: true,
              // Disabled until the answer is non-empty (wireframe `17`).
              onPressed: canCheck ? onCheck : null,
            ),
            const SizedBox(height: MxSpacing.space2),
            FillActionLink(label: l10n.studyFillHint, onTap: onHint),
          ],
        );
      case FillPhase.correct:
        // A depleting countdown bar (auto-advances after 0.8s, S68) over the
        // Next button (tap to skip — wireframe `17` "Next ▸ tappable to skip").
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: 0),
              duration: AppMotion.fillAutoAdvance,
              // Auto-advance when the bar depletes (S68); Next taps to skip early.
              onEnd: onNext,
              builder: (_, double value, _) => MxLinearProgress(value: value),
            ),
            const SizedBox(height: MxSpacing.space3),
            MxPrimaryButton(
              label: l10n.studyFillNext,
              fullWidth: true,
              onPressed: onNext,
            ),
          ],
        );
      case FillPhase.wrong:
        // Mock `16-study-fill--wrong` shows Retry / Next; the **Mark correct**
        // override (→ `recovered`, decision S72) is added as a discreet link
        // below the row (wireframe `17`; not in the mock — documented variance).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: MxSecondaryButton(
                    label: l10n.studyFillRetry,
                    icon: Icons.refresh,
                    onPressed: onRetry,
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: MxPrimaryButton(
                    label: l10n.studyFillNext,
                    fullWidth: true,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MxSpacing.space2),
            FillActionLink(
              label: l10n.studyFillMarkCorrect,
              onTap: onMarkCorrect,
            ),
          ],
        );
    }
  }

  /// Last card graded → finalize (one-terminal-attempt path) then `pushReplacement`
  /// to the shared result screen (mirrors WP-SR5a/SG2/RC1).
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

  Widget _errorBody(WidgetRef ref, AppLocalizations l10n) => MxErrorState(
    title: l10n.studyReviewLoadFailedTitle,
    message: l10n.studyReviewLoadFailedMessage,
    icon: Icons.cloud_off_outlined,
    action: MxSecondaryButton(
      label: l10n.commonRetryLabel,
      onPressed: () => ref.invalidate(fillSessionControllerProvider(sessionId)),
    ),
  );
}
