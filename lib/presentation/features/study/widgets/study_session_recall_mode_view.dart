import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_recall_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

part 'study_session_recall_mode_view_parts.dart';

class StudySessionRecallModeView extends ConsumerStatefulWidget {
  const StudySessionRecallModeView({
    required this.sessionId,
    required this.mode,
    required this.onBack,
    required this.onFinalized,
    super.key,
  });

  final String sessionId;
  final StudyMode? mode;
  final VoidCallback onBack;
  final VoidCallback onFinalized;

  @override
  ConsumerState<StudySessionRecallModeView> createState() =>
      _StudySessionRecallModeViewState();
}

class _StudySessionRecallModeViewState
    extends ConsumerState<StudySessionRecallModeView> {
  int _lastAutoPlayIndex = -1;

  void _maybeAutoPlay(StudySessionRecallState state) {
    if (state.currentIndex == _lastAutoPlayIndex) return;
    _lastAutoPlayIndex = state.currentIndex;
    final StudySessionReviewItem item = state.currentItem;
    if (item.targetLanguage == TargetLanguage.unsupported) return;
    // Read TTS settings synchronously from the repository via the use case;
    // fire-and-forget — failures are suppressed inside speakFlashcardFront.
    unawaited(_autoPlayIfEnabled(item));
  }

  Future<void> _autoPlayIfEnabled(StudySessionReviewItem item) async {
    final Result<TtsSettings> settingsResult =
        await ref.read(loadTtsSettingsUseCaseProvider).call();
    final bool autoPlay = switch (settingsResult) {
      Ok<TtsSettings>(:final TtsSettings value) => value.autoPlay,
      Err<TtsSettings>() => false,
    };
    if (!autoPlay || !mounted) return;
    unawaited(
      ref.read(speakFlashcardUseCaseProvider).speakFlashcardFront(
        frontText: item.flashcard.front,
        targetLanguage: item.targetLanguage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionRecallControllerProvider((
      sessionId: widget.sessionId,
      studyMode: widget.mode,
    ));

    ref.listen<AsyncValue<StudySessionRecallState>>(provider, (
      AsyncValue<StudySessionRecallState>? previous,
      AsyncValue<StudySessionRecallState> next,
    ) {
      final bool didNavigateBefore =
          previous?.asData?.value.didFinalizeSuccessfully ?? false;
      final bool didNavigateNow =
          next.asData?.value.didFinalizeSuccessfully ?? false;
      if (!didNavigateBefore && didNavigateNow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onFinalized();
          }
        });
      }

      // Auto-play: speak front when card advances, if the setting is enabled.
      final StudySessionRecallState? state = next.asData?.value;
      if (state != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _maybeAutoPlay(state);
        });
      }
    });

    final AsyncValue<StudySessionRecallState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionRecallState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionRecallModeLabel,
          current: 0,
          total: 0,
          onClose: widget.onBack,
          accent: context.customColors.success,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionRecallState>(:final error) =>
        _StudySessionRecallErrorState(error: error, onBack: widget.onBack),
      AsyncData<StudySessionRecallState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionRecallModeLabel,
          current: value.currentIndex + 1,
          total: value.review.items.length,
          onClose: widget.onBack,
          accent: context.customColors.success,
        ),
        body: _StudySessionRecallBody(
          state: value,
          onRevealAnswer: () => ref.read(provider.notifier).revealAnswer(),
          onForgot: () => ref.read(provider.notifier).gradeForgot(),
          onGotIt: () => ref.read(provider.notifier).gradeGotIt(),
          onEditCard: (StudySessionReviewItem item) =>
              _editCard(context, ref, widget.sessionId, widget.mode, item),
          onOpenCardActions: (StudySessionReviewItem item) => _openCardActions(
            context,
            ref,
            widget.sessionId,
            widget.mode,
            item,
          ),
          onSpeakFront: (StudySessionReviewItem item) => unawaited(
            ref.read(speakFlashcardUseCaseProvider).speakFlashcardFront(
              frontText: item.flashcard.front,
              targetLanguage: item.targetLanguage,
            ),
          ),
        ),
        bottomAction: _buildBottomAction(
          context: context,
          state: value,
          onRevealAnswer: () => ref.read(provider.notifier).revealAnswer(),
          onForgot: () => ref.read(provider.notifier).gradeForgot(),
          onGotIt: () => ref.read(provider.notifier).gradeGotIt(),
          onRetryFinalize: () => ref.read(provider.notifier).finishSession(),
        ),
      ),
    };
  }

  Widget? _buildBottomAction({
    required BuildContext context,
    required StudySessionRecallState state,
    required VoidCallback onRevealAnswer,
    required Future<void> Function() onForgot,
    required Future<void> Function() onGotIt,
    required Future<bool> Function() onRetryFinalize,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state.finalizeFailure != null && state.allAnswered) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: () async {
          final bool finished = await onRetryFinalize();
          if (!finished) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          widget.onFinalized();
        },
        fullWidth: true,
      );
    }

    if (state.isAnswerVisible || state.isSaving || state.isFinalizing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.revealedByTimeout) ...<Widget>[
            MxText(
              l10n.studySessionRecallTimeoutCaption,
              role: MxTextRole.labelLarge,
              color: context.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          MxCardActions(
            secondary: MxActionButton(
              intent: MxActionIntent.cardSecondary,
              label: l10n.studyForgotAction,
              onPressed: state.canGradeCurrentItem
                  ? () async {
                      await onForgot();
                    }
                  : null,
            ),
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: l10n.studyGotItAction,
              onPressed: state.canGradeCurrentItem
                  ? () async {
                      await onGotIt();
                    }
                  : null,
            ),
          ),
        ],
      );
    }

    return MxActionButton(
      intent: MxActionIntent.screenPrimary,
      label: l10n.studySessionRecallShowAnswerAction(
        state.countdownRemainingSeconds,
      ),
      onPressed: onRevealAnswer,
      fullWidth: true,
    );
  }
}
