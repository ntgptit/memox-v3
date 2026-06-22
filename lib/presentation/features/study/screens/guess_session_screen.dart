import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/guess_option.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/guess_session_controller.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Guess-mode study surface (mock `14-study-guess` / wireframe `15`), reached
/// via the session route with `?mode=guess`.
///
/// **WP-SG1 = the shell:** the ✕ + blue progress + `{answered}/{total}` count, the
/// prompt card (the front + reading), and a **static** list of lettered option
/// cards (the multiple-choice backs from `GuessSessionController`). The
/// select-to-grade reveal (correct green / wrong red), the `RecordStudySessionAnswerUseCase`
/// wiring, auto-advance, and finalize → result are **WP-SG2**.
class GuessSessionScreen extends ConsumerWidget {
  const GuessSessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<GuessView> async = ref.watch(
      guessSessionControllerProvider(sessionId),
    );
    return AppAsyncBuilder<GuessView>(
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
      data: (GuessView view) {
        final StudySessionReviewItem? item = view.currentItem;
        if (view.total == 0 || item == null) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          progress: (view.answeredCount, view.total),
          body: _questionBody(context, l10n, item, view.options),
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
  /// answered, else pop straight away.
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

  Widget _questionBody(
    BuildContext context,
    AppLocalizations l10n,
    StudySessionReviewItem item,
    List<GuessOption> options,
  ) => Padding(
    padding: const EdgeInsets.all(MxSpacing.space5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _PromptCard(prompt: l10n.studyGuessPrompt, item: item),
        const SizedBox(height: MxSpacing.space5),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: MxSpacing.space3),
            itemBuilder: (BuildContext context, int index) => _OptionRow(
              letter: String.fromCharCode(65 + index), // A, B, C…
              option: options[index],
            ),
          ),
        ),
      ],
    ),
  );

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
          ref.invalidate(guessSessionControllerProvider(sessionId)),
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
            MxText(item.front, role: MxTextRole.displayLarge),
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

/// One multiple-choice option row — a letter badge + the candidate back.
/// WP-SG1 renders the idle (unselected) state; the correct/wrong reveal is WP-SG2.
class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.letter, required this.option});

  final String letter;
  final GuessOption option;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return ConstrainedBox(
      // Spec minimum row height so short backs keep the option-card rhythm.
      constraints: const BoxConstraints(minHeight: MxSpacing.space12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: MxRadius.mdAll,
          border: Border.all(color: colors.border, width: MxStroke.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MxSpacing.space4),
          child: Row(
            children: <Widget>[
              _LetterBadge(letter: letter),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: MxText(
                  option.back,
                  role: MxTextRole.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      width: MxSpacing.space6,
      height: MxSpacing.space6,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: MxStroke.hairline),
      ),
      child: MxText(
        letter,
        role: MxTextRole.labelMedium,
        color: colors.textSecondary,
      ),
    );
  }
}
