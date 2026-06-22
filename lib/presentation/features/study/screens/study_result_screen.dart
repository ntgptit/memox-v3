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
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_result_provider.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The end-of-session result summary (mock `17` / wireframe `18`), reached via
/// `pushReplacement` from the session's Finish action after finalize (WP-SR5a).
///
/// **V1 slice** (wireframe `18` §V1): the completion header + a counts summary
/// (Correct / Wrong / Answered, off `StudySessionResult`'s getters) + a Done
/// exit that **`go`es to the origin** (deck → that deck's flashcard list,
/// otherwise Dashboard), never `pop` (the result is not kept in the back stack). The
/// mock's **accuracy ring, Goal & streak block, "Due next" projection,
/// and "Keep studying" CTA are Future** (they need the engagement read model +
/// an SRS due-projection the result read model does not carry) — documented
/// visual gaps, not built here. The status-driven **save-failed / defensive**
/// states are WP-SR5b. WBS 4.7.2.
class StudyResultScreen extends ConsumerWidget {
  const StudyResultScreen({required this.sessionId, super.key});

  /// The finalized session id passed from the Finish action.
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: the result screen keeps one stable app
    // bar ("Session complete") across the async states; the watched summary only
    // drives the body via AppAsyncBuilder, so the shell stays intentionally reactive.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudySessionResult> async = ref.watch(
      studySessionResultProvider(sessionId),
    );
    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.studyResultTitle,
        automaticallyImplyLeading: false,
      ),
      body: AppAsyncBuilder<StudySessionResult>(
        value: async,
        loading: (_) => MxLoadingState(message: l10n.studyResultLoading),
        error: (_, _) => _errorBody(context, ref, l10n),
        data: (StudySessionResult result) {
          // Defensive (wireframe `18`): a session with no recorded answers
          // should not happen (Finish needs every card graded), but render a
          // plain notice instead of empty celebration counts.
          if (result.answeredCount == 0) {
            return _defensiveBody(context, l10n, result.session.scope);
          }
          return _loadedBody(context, ref, l10n, result);
        },
      ),
    );
  }

  Widget _loadedBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    StudySessionResult result,
  ) {
    // Save-failed (wireframe `18`): the summary aggregate failed to persist
    // (`failed_to_finalize`). Show a banner + a Retry, but Done stays enabled —
    // the user can always leave (data is preserved via the status).
    final bool saveFailed =
        result.session.status == SessionStatus.failedToFinalize;
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Content scrolls if it is taller than the viewport; the footer stays
          // pinned (no overflow on short screens / large text scale).
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (saveFailed) ...<Widget>[
                    _SaveFailedBanner(
                      message: l10n.studyResultSaveFailedBanner,
                    ),
                    const SizedBox(height: MxSpacing.space4),
                  ],
                  _HeroCard(total: result.total),
                  const SizedBox(height: MxSpacing.space4),
                  _StatSummary(
                    passed: result.passedCount,
                    forgot: result.forgotCount,
                    answered: result.answeredCount,
                    total: result.total,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          if (saveFailed) ...<Widget>[
            MxSecondaryButton(
              label: l10n.studyResultRetry,
              icon: Icons.refresh,
              fullWidth: true,
              onPressed: () => unawaited(_retry(ref)),
            ),
            const SizedBox(height: MxSpacing.space3),
          ],
          MxPrimaryButton(
            label: l10n.studyResultDone,
            fullWidth: true,
            onPressed: () => _done(context, result.session.scope),
          ),
        ],
      ),
    );
  }

  /// The zero-answers defensive surface: a plain notice + Done.
  Widget _defensiveBody(
    BuildContext context,
    AppLocalizations l10n,
    StudyScope scope,
  ) => MxEmptyState(
    icon: Icons.info_outline,
    title: l10n.studyResultDefensiveTitle,
    message: l10n.studyResultDefensiveMessage,
    action: MxPrimaryButton(
      label: l10n.studyResultDone,
      onPressed: () => _done(context, scope),
    ),
  );

  /// Re-run finalize then reload the summary (save-failed Retry). The finalize
  /// result is tolerated like the Finish action — Done always stays available.
  Future<void> _retry(WidgetRef ref) async {
    await ref
        .read(finalizeStudySessionUseCaseProvider)
        .call(sessionId: sessionId);
    ref.invalidate(studySessionResultProvider(sessionId));
  }

  /// Done → the **origin** route via `go` (wireframe `18` §Agent rule): a deck
  /// scope returns to that deck's flashcard list, everything other than that to the
  /// Dashboard. Uses `go` (not `pop`) so the result never stays in the back
  /// stack and Back from the caller does not re-enter it.
  void _done(BuildContext context, StudyScope scope) {
    final String? deckId = scope.entryRefId;
    if (scope.entryType == EntryType.deck && deckId != null) {
      context.goNamed(
        RouteNames.deckFlashcards,
        pathParameters: <String, String>{RouteParams.deckId: deckId},
      );
      return;
    }
    context.goNamed(RouteNames.home);
  }

  Widget _errorBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => MxErrorState(
    title: l10n.studyResultLoadFailedTitle,
    message: l10n.studyResultLoadFailedMessage,
    icon: Icons.cloud_off_outlined,
    action: MxSecondaryButton(
      label: l10n.commonRetryLabel,
      onPressed: () => ref.invalidate(studySessionResultProvider(sessionId)),
    ),
  );
}

/// The save-failed banner (wireframe `18`): a danger-soft strip warning that the
/// summary did not persist, while the local progress is kept.
class _SaveFailedBanner extends StatelessWidget {
  const _SaveFailedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.dangerSoft,
        borderRadius: MxRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.cloud_off_outlined,
              size: MxIconSize.md,
              color: colors.danger,
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: MxText(
                message,
                role: MxTextRole.bodySmall,
                color: colors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The completion hero: a celebration glyph + the headline + the reviewed count.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    return MxCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space6),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.celebration_outlined,
              size: MxSpacing.space12,
              color: colors.accent,
            ),
            const SizedBox(height: MxSpacing.space4),
            MxText(l10n.studyResultHeroTitle, role: MxTextRole.titleLarge),
            const SizedBox(height: MxSpacing.space1),
            MxText(
              l10n.studyResultCardsReviewed(total),
              role: MxTextRole.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// The counts summary card: Correct / Wrong / Answered (off the result getters).
class _StatSummary extends StatelessWidget {
  const _StatSummary({
    required this.passed,
    required this.forgot,
    required this.answered,
    required this.total,
  });

  final int passed;
  final int forgot;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                value: '$passed',
                label: l10n.studyResultCorrect,
              ),
            ),
            Expanded(
              child: _StatTile(value: '$forgot', label: l10n.studyResultWrong),
            ),
            Expanded(
              child: _StatTile(
                value: '$answered / $total',
                label: l10n.studyResultAnswered,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Column(
      children: <Widget>[
        MxText(value, role: MxTextRole.titleLarge),
        const SizedBox(height: MxSpacing.space1),
        MxText(label, role: MxTextRole.labelMedium, color: colors.textTertiary),
      ],
    );
  }
}
