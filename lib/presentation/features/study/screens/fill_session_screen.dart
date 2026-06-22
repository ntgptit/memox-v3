import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
import 'package:memox/presentation/features/study/controllers/fill_session_controller.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Fill-mode study surface (mock `16-study-fill` / wireframe `17`), reached
/// via the session route with `?mode=fill`.
///
/// **WP-FI1 = the typed-production loop:** the ✕ + blue progress + count, the hint
/// card (the back / definition), a free-text answer field, **Check** → a strict
/// trim-only match of the typed front (`perfect` / `forgot`); correct → ✓ + Next,
/// wrong → the CORRECT ANSWER card + Retry / Next → record + advance → the last
/// card finalizes → the result. **Mark correct → `recovered` is built (WP-FI2a)**;
/// the Hint char-reveal, the auto-advance countdown, and the edit / TTS
/// affordances remain deferred (WP-FI2).
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
        icon: Icons.close,
        tooltip: l10n.commonCancel,
        onPressed: () => unawaited(_confirmExit(context, l10n, progress)),
      ),
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
        _HintCard(prompt: l10n.studyFillPrompt, hint: item.back),
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
        return _TypingArea(
          label: l10n.studyFillAnswerLabel,
          controller: field.controller,
          // The Hint reveals leading characters of the front (WP-FI2b, S69).
          revealedHint: view.hintRevealed > 0
              ? _hintMask(item.front, view.hintRevealed)
              : null,
        );
      case FillPhase.correct:
        return _CorrectArea(answer: submitted);
      case FillPhase.wrong:
        return _WrongArea(
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
            _FillActionLink(label: l10n.studyFillHint, onTap: onHint),
          ],
        );
      case FillPhase.correct:
        return MxPrimaryButton(
          label: l10n.studyFillNext,
          fullWidth: true,
          onPressed: onNext,
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
            _FillActionLink(
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

/// A discreet accent text link for the Fill secondary actions the redesign mock
/// dropped — **Hint** (typing, WP-FI2b) and **Mark correct** (wrong, WP-FI2a) —
/// kept off the primary button row so it never crowds Check / Retry / Next.
class _FillActionLink extends StatelessWidget {
  const _FillActionLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: MxTappable(
      onTap: onTap,
      child: MxText(
        label,
        role: MxTextRole.labelMedium,
        color: context.mxColors.accent,
      ),
    ),
  );
}

/// The hint card: an overline + the back / definition (the prompt the learner
/// produces the front from).
class _HintCard extends StatelessWidget {
  const _HintCard({required this.prompt, required this.hint});

  final String prompt;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxCard(
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
            MxText(hint, role: MxTextRole.titleLarge),
          ],
        ),
      ),
    );
  }
}

/// The typing state: an overline label + the free-text answer field.
class _TypingArea extends StatelessWidget {
  const _TypingArea({
    required this.label,
    required this.controller,
    this.revealedHint,
  });

  final String label;
  final TextEditingController controller;

  /// The Hint mask (revealed prefix + `·` per hidden char), or null when no hint
  /// has been revealed for the current card (WP-FI2b).
  final String? revealedHint;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? hint = revealedHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxText(
          StringUtils.upperFold(label),
          role: MxTextRole.labelSmall,
          color: colors.textTertiary,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxTextField(controller: controller, autofocus: true),
        if (hint != null) ...<Widget>[
          const SizedBox(height: MxSpacing.space2),
          MxText(
            hint,
            role: MxTextRole.titleMedium,
            color: colors.textSecondary,
          ),
        ],
      ],
    );
  }
}

/// The correct-feedback state: the typed answer over a ✓ glyph (success family).
class _CorrectArea extends StatelessWidget {
  const _CorrectArea({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.successSoft,
            borderRadius: MxRadius.mdAll,
            border: Border.all(color: colors.success, width: MxStroke.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(answer, role: MxTextRole.titleLarge),
                const SizedBox(height: MxSpacing.space2),
                Icon(Icons.check, size: MxIconSize.lg, color: colors.success),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The wrong-feedback state: the typed answer in a red-bordered box, a "not
/// quite" message, and the correct answer in a green card.
class _WrongArea extends StatelessWidget {
  const _WrongArea({
    required this.submitted,
    required this.message,
    required this.correctLabel,
    required this.correct,
  });

  final String submitted;
  final String message;
  final String correctLabel;
  final String correct;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.dangerSoft,
              borderRadius: MxRadius.mdAll,
              border: Border.all(
                color: colors.danger,
                width: MxStroke.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space4),
              child: MxText(
                submitted,
                role: MxTextRole.titleLarge,
                color: colors.danger,
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space2),
          Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: MxIconSize.sm,
                color: colors.danger,
              ),
              const SizedBox(width: MxSpacing.space1),
              Flexible(
                child: MxText(
                  message,
                  role: MxTextRole.bodySmall,
                  color: colors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.successSoft,
              borderRadius: MxRadius.mdAll,
              border: Border.all(
                color: colors.success,
                width: MxStroke.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MxText(
                    StringUtils.upperFold(correctLabel),
                    role: MxTextRole.labelSmall,
                    color: colors.success,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  MxText(correct, role: MxTextRole.titleLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
