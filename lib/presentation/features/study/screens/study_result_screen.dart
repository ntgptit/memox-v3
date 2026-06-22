import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_session_result_provider.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
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
        data: (StudySessionResult result) => _loadedBody(context, l10n, result),
      ),
    );
  }

  Widget _loadedBody(
    BuildContext context,
    AppLocalizations l10n,
    StudySessionResult result,
  ) => Padding(
    padding: const EdgeInsets.all(MxSpacing.space5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HeroCard(total: result.total),
        const SizedBox(height: MxSpacing.space4),
        _StatSummary(
          passed: result.passedCount,
          forgot: result.forgotCount,
          answered: result.answeredCount,
          total: result.total,
        ),
        const Spacer(),
        MxPrimaryButton(
          label: l10n.studyResultDone,
          fullWidth: true,
          onPressed: () => _done(context, result.session.scope),
        ),
      ],
    ),
  );

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
