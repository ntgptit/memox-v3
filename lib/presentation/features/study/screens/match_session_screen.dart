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
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/match_board_controller.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The Match-mode study surface (mock `13-study-match` / wireframe `14`), reached
/// via the session route with `?mode=match`.
///
/// **WP-SM4 = the playable board:** the tap-pair state machine over
/// `MatchBoardController` — one selection at a time → a valid pair locks green,
/// a wrong pair flashes red then deselects; every pair (right/wrong) persists via
/// `RecordMatchEvaluationUseCase`. The ✕ + blue progress + `{matched}/{total}`
/// count + "Match the pairs" title + "{matched} matched · {left} left" line stay
/// from the shell (WP-SM3). **Deferred:** the Shuffle & restart bar + mistake
/// counter + count-up timer = WP-SM4b; board progression + finalize→result = WP-SM5.
class MatchSessionScreen extends ConsumerWidget {
  const MatchSessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // When the last board clears, finalize + route to the result (WP-SM5).
    ref.listen<AsyncValue<MatchBoardView>>(
      matchBoardControllerProvider(sessionId),
      (AsyncValue<MatchBoardView>? prev, AsyncValue<MatchBoardView> next) {
        final bool wasFinished = prev?.value?.finished ?? false;
        if (!wasFinished && (next.value?.finished ?? false)) {
          unawaited(_finish(context, ref));
        }
      },
    );
    final AsyncValue<MatchBoardView> async = ref.watch(
      matchBoardControllerProvider(sessionId),
    );
    return AppAsyncBuilder<MatchBoardView>(
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
      data: (MatchBoardView board) {
        if (board.cells.isEmpty) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        return _shell(
          context,
          l10n,
          progress: (board.matchedCount, board.sessionTotal),
          body: _boardBody(context, ref, l10n, board),
        );
      },
    );
  }

  Widget _shell(
    BuildContext context,
    AppLocalizations l10n, {
    required (int matched, int total)? progress,
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

  /// All boards cleared → finalize (the Match branch derives terminals from the
  /// evaluations, WP-SM2) then `pushReplacement` to the shared result screen.
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

  Widget _boardBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    MatchBoardView board,
  ) {
    final MatchBoardController controller = ref.read(
      matchBoardControllerProvider(sessionId).notifier,
    );
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
          MxText(
            l10n.studyMatchSubtitle,
            role: MxTextRole.bodySmall,
            color: context.mxColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MxSpacing.space5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                key: const ValueKey<String>('mx-node:13-study-match/board'),
                children: <Widget>[
                  // Boards are 10 cells (always even); the right column is the
                  // odd-index cell, or an empty filler defensively.
                  for (int i = 0; i < board.cells.length; i += 2) ...<Widget>[
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: _MatchCell(
                              cell: board.cells[i],
                              onTap: () => unawaited(
                                controller.select(board.cells[i].id),
                              ),
                            ),
                          ),
                          const SizedBox(width: MxSpacing.space3),
                          Expanded(
                            child: i + 1 < board.cells.length
                                ? _MatchCell(
                                    cell: board.cells[i + 1],
                                    onTap: () => unawaited(
                                      controller.select(board.cells[i + 1].id),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: MxSpacing.space3),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space3),
          Center(
            // Per-board status (resets each board); the app-bar count is
            // session-wide (`matchedCount`/`sessionTotal`).
            child: MxText(
              l10n.studyMatchProgress(board.matchedOnBoard, board.pairsLeft),
              role: MxTextRole.labelMedium,
              color: context.mxColors.textSecondary,
            ),
          ),
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
      onPressed: () => ref.invalidate(matchBoardControllerProvider(sessionId)),
    ),
  );
}

/// One board cell — a tappable front/back face whose fill reflects its status
/// (idle / selected = accent / matched = green ✓ / wrong = danger flash).
class _MatchCell extends StatelessWidget {
  const _MatchCell({required this.cell, required this.onTap});

  final MatchCell cell;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final (Color bg, Color fg, Color border) = switch (cell.status) {
      MatchCellStatus.idle => (colors.surface, colors.text, colors.border),
      MatchCellStatus.selected => (
        colors.accent,
        colors.accentContrast,
        colors.accent,
      ),
      MatchCellStatus.matched => (
        colors.successSoft,
        colors.success,
        colors.success,
      ),
      MatchCellStatus.wrong => (
        colors.dangerSoft,
        colors.danger,
        colors.danger,
      ),
    };
    return MxTappable(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: MxRadius.mdAll,
          border: Border.all(color: border, width: MxStroke.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MxSpacing.space4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (cell.status == MatchCellStatus.matched) ...<Widget>[
                Icon(Icons.check, size: MxIconSize.sm, color: fg),
                const SizedBox(width: MxSpacing.space1),
              ],
              Flexible(
                child: MxText(
                  cell.text,
                  role: MxTextRole.titleMedium,
                  color: fg,
                  textAlign: TextAlign.center,
                  maxLines: 3,
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
