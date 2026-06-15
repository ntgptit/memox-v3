import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_fill_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_inline_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

part 'study_session_fill_mode_view_parts.dart';
part 'study_session_fill_mode_view_more.dart';

class StudySessionFillModeView extends HookConsumerWidget {
  const StudySessionFillModeView({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionFillControllerProvider((
      sessionId: sessionId,
      studyMode: mode,
    ));
    final MxTextSubmitState input = useMxTextSubmitState();
    final FocusNode inputFocusNode = useFocusNode();

    ref.listen<AsyncValue<StudySessionFillState>>(provider, (
      AsyncValue<StudySessionFillState>? previous,
      AsyncValue<StudySessionFillState> next,
    ) {
      final bool didNavigateBefore =
          previous?.asData?.value.didFinalizeSuccessfully ?? false;
      final bool didNavigateNow =
          next.asData?.value.didFinalizeSuccessfully ?? false;
      if (!didNavigateBefore && didNavigateNow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            onFinalized();
          }
        });
      }

      final StudySessionFillState? state = next.asData?.value;
      if (state == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        _syncInputController(input.controller, state);
      });
    });

    final AsyncValue<StudySessionFillState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionFillState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionFillModeLabel,
          current: 0,
          total: 0,
          onClose: onBack,
          accent: context.customColors.success,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionFillState>(:final error) =>
        _StudySessionFillErrorState(error: error, onBack: onBack),
      AsyncData<StudySessionFillState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionFillModeLabel,
          current: value.currentIndex + 1,
          total: value.review.items.length,
          onClose: onBack,
          accent: context.customColors.success,
        ),
        body: _StudySessionFillBody(
          state: value,
          input: input,
          inputFocusNode: inputFocusNode,
          onChanged: (String text) =>
              ref.read(provider.notifier).setFillInputText(text),
          onHint: () => ref.read(provider.notifier).revealHint(),
          onCheck: () => ref.read(provider.notifier).checkAnswer(),
          onMarkCorrect: () => ref.read(provider.notifier).markCorrect(),
          onTryAgain: () => ref.read(provider.notifier).tryAgain(),
          onNext: () => ref.read(provider.notifier).next(),
          onFinish: () => ref.read(provider.notifier).finishSession(),
          onEditCard: (StudySessionReviewItem item) =>
              _editCard(context, ref, sessionId, mode, item),
          onOpenCardActions: (StudySessionReviewItem item) =>
              _openCardActions(context, ref, sessionId, mode, item),
          onSpeakFront: (StudySessionReviewItem item) => unawaited(
            ref.read(speakFlashcardUseCaseProvider).speakFlashcardFront(
              frontText: item.flashcard.front,
              targetLanguage: item.targetLanguage,
            ),
          ),
        ),
      ),
    };
  }

  void _syncInputController(
    TextEditingController inputController,
    StudySessionFillState state,
  ) {
    if (inputController.text == state.inputText) {
      return;
    }

    inputController.value = TextEditingValue(
      text: state.inputText,
      selection: TextSelection.collapsed(offset: state.inputText.length),
    );
  }
}
