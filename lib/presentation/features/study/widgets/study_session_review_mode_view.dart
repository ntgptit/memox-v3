import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

part 'study_session_review_mode_view_parts.dart';

class StudySessionReviewModeView extends ConsumerWidget {
  const StudySessionReviewModeView({
    required this.sessionId,
    required this.mode,
    required this.onBack,
    super.key,
  });

  final String sessionId;
  final StudyMode? mode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<StudySessionReviewState> value = ref.watch(
      studySessionReviewControllerProvider((
        sessionId: sessionId,
        studyMode: mode,
      )),
    );

    return switch (value) {
      AsyncLoading<StudySessionReviewState>() => const MxScaffold(
        appBar: _StudySessionReviewAppBar(current: 0, total: 0, onClose: _noop),
        body: MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionReviewState>(:final error) =>
        _StudySessionReviewErrorState(error: error, onBack: onBack),
      AsyncData<StudySessionReviewState>(:final value) =>
        _StudySessionReviewBody(
          state: value,
          onBack: onBack,
          onOpenCardActions: (StudySessionReviewItem item) async {
            final MxStudySessionCardAction? action =
                await showStudySessionCardActions(
                  context,
                  front: item.flashcard.front,
                );
            if (!context.mounted) {
              return;
            }
            if (action == null) {
              return;
            }

            switch (action) {
              case MxStudySessionCardAction.edit:
                unawaited(
                  context.pushFlashcardEdit(
                    item.flashcard.deckId,
                    item.flashcard.id,
                  ),
                );
                return;
              case MxStudySessionCardAction.buryUntilTomorrow:
                await _applyCardAction(
                  context: context,
                  ref: ref,
                  sessionId: sessionId,
                  studyMode: mode,
                  successMessage: l10n.studySessionBurySuccessMessage,
                  failureMessage: l10n.studySessionCardActionFailedMessage,
                  call: () => ref
                      .read(study_di.buryStudySessionCardUseCaseProvider)
                      .call(
                        sessionId: sessionId,
                        flashcardId: item.flashcard.id,
                      ),
                );
                return;
              case MxStudySessionCardAction.suspend:
                await _applyCardAction(
                  context: context,
                  ref: ref,
                  sessionId: sessionId,
                  studyMode: mode,
                  successMessage: l10n.studySessionSuspendSuccessMessage,
                  failureMessage: l10n.studySessionCardActionFailedMessage,
                  call: () => ref
                      .read(study_di.suspendStudySessionCardUseCaseProvider)
                      .call(
                        sessionId: sessionId,
                        flashcardId: item.flashcard.id,
                      ),
                );
                return;
            }
          },
          onSwipeForgot: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .gradeForgot(),
          onSwipePerfect: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .gradePerfect(),
          onFinish: () => ref
              .read(
                studySessionReviewControllerProvider((
                  sessionId: sessionId,
                  studyMode: mode,
                )).notifier,
              )
              .finishSession(),
          onFinalized: () => context.pushReplacementStudyResult(sessionId),
        ),
    };
  }
}
