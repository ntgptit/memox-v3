import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
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
/// WP-SR2 builds the **shell + card** (read-only): the `✕` exit + a blue
/// (recognition-family) progress bar + `{answered}/{total}` count, and the card
/// showing **both sides at once** (front-side label → front → divider →
/// back-side label → back → example pill) with no reveal step. Grading by swipe
/// is WP-SR3; exit-confirm + card-actions WP-SR4; finalize→result WP-SR5. The
/// front/back labels fall back to FRONT/BACK — the language-specific labels
/// (KOREAN/MEANING from `deck.target_language`) need the read model to carry the
/// language and are WP-SR2b polish. WBS 4.5.3.
class StudySessionScreen extends ConsumerWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  /// The persisted session id from the entry gate.
  final String sessionId;

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
        if (review.items.isEmpty) {
          return _shell(context, l10n, progress: null, body: _emptyBody(l10n));
        }
        // The current card is the first unanswered item. On a fully-answered
        // reload (`firstUnansweredIndex == null`) WP-SR2 falls back to the first
        // card with a full progress bar; the Finish-Session surface for that
        // case lands with WP-SR3 (no grading/finish here yet).
        final StudySessionReviewItem item =
            review.items[review.firstUnansweredIndex ?? 0];
        return _shell(
          context,
          l10n,
          progress: (review.answeredCount, review.total),
          body: _ReviewCard(item: item),
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
        onPressed: () => context.pop(),
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
