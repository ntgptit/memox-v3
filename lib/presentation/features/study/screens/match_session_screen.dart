import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
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

/// The Match-mode study surface (mock `13-study-match--matching` / wireframe
/// `14`), reached via the session route with `?mode=match` (WP-SM3).
///
/// **WP-SM3 = the board shell, aligned to the mock** (PRECEDENCE #2 — mock wins
/// for visual; wireframe-14 reconciled): the immersive ✕ + blue progress +
/// `{matched}/{total}` count, the "Match the pairs" title + prompt subtitle, a
/// **static** 2×5 board grid (the first board's front/back cells), and the
/// "{matched} matched · {left} left" status line, over the
/// `studySessionReviewProvider` items batched into boards of 5.
///
/// Deferred: the tap-pair state machine (select → match / wrong-flash), the
/// Fisher-Yates shuffle, the **Shuffle & restart** bar, the
/// `RecordMatchEvaluationUseCase` wiring, and board progression = **WP-SM4**;
/// finalize → result (reusing SR5) = **WP-SM5**.
class MatchSessionScreen extends ConsumerWidget {
  const MatchSessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  /// Cards per board (wireframe `14` §Board composition: 5 pairs = 10 cells).
  static const int _boardSize = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudySessionReview> async = ref.watch(
      studySessionReviewProvider(sessionId),
    );
    return AppAsyncBuilder<StudySessionReview>(
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
      data: (StudySessionReview review) {
        if (review.total == 0) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          // WP-SM3: no pairs are matched yet (the tap interaction is WP-SM4).
          progress: (0, review.total),
          body: _boardBody(context, l10n, review),
        );
      },
    );
  }

  /// The immersive Match shell: ✕ exit + blue progress + the `{matched}/{total}`
  /// count (mock `13-study-match` app bar — no mode pill).
  Widget _shell(
    BuildContext context,
    AppLocalizations l10n, {
    required (int matched, int total)? progress,
    required Widget body,
  }) => MxScaffold(
    appBar: MxAppBar(
      automaticallyImplyLeading: false,
      leading: MxIconButton.toolbar(
        icon: Icons.close,
        tooltip: l10n.commonCancel,
        onPressed: () => _confirmExit(context, l10n, progress),
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

  /// Exit guard (shared with Review §exit-session): once any pair is matched,
  /// confirm before leaving; with nothing matched yet, pop straight away.
  Future<void> _confirmExit(
    BuildContext context,
    AppLocalizations l10n,
    (int matched, int total)? progress,
  ) async {
    final int matched = progress?.$1 ?? 0;
    if (matched == 0) {
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

  Widget _boardBody(
    BuildContext context,
    AppLocalizations l10n,
    StudySessionReview review,
  ) {
    final List<StudySessionReviewItem> board = review.items
        .take(_boardSize)
        .toList();
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxText(
            l10n.studyMatchTitle,
            role: MxTextRole.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MxSpacing.space1),
          _Subtitle(text: l10n.studyMatchSubtitle),
          const SizedBox(height: MxSpacing.space5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // WP-SM3 renders the first board's pairs row-aligned (front |
                  // back). The Fisher-Yates shuffle + tap selection are WP-SM4.
                  for (final StudySessionReviewItem item in board) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: _MatchCell(text: item.front)),
                        const SizedBox(width: MxSpacing.space3),
                        Expanded(child: _MatchCell(text: item.back)),
                      ],
                    ),
                    const SizedBox(height: MxSpacing.space3),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          _ProgressLine(text: l10n.studyMatchProgress(0, board.length)),
        ],
      ),
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
      onPressed: () => ref.invalidate(studySessionReviewProvider(sessionId)),
    ),
  );
}

/// The prompt subtitle under the title ("Tap a term, then its meaning.").
class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => MxText(
    text,
    role: MxTextRole.bodySmall,
    color: context.mxColors.textSecondary,
    textAlign: TextAlign.center,
  );
}

/// The "{matched} matched · {left} left" status line below the grid.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: MxText(
      text,
      role: MxTextRole.labelMedium,
      color: context.mxColors.textSecondary,
    ),
  );
}

/// One board cell — a front or back face (non-interactive in WP-SM3).
class _MatchCell extends StatelessWidget {
  const _MatchCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => MxCard(
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space4),
      child: Center(
        child: MxText(
          text,
          role: MxTextRole.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}
