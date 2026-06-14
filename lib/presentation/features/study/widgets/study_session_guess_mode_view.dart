import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart' as study_di;
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/study/guess/guess_option.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_guess_viewmodel.dart';
import 'package:memox/presentation/shared/dialogs/mx_card_actions_sheet.dart';
import 'package:memox/presentation/shared/feedback/mx_callout.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_study_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_study_top_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

part 'study_session_guess_mode_view_parts.dart';
part 'study_session_guess_mode_view_more.dart';

class StudySessionGuessModeView extends ConsumerStatefulWidget {
  const StudySessionGuessModeView({
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
  ConsumerState<StudySessionGuessModeView> createState() =>
      _StudySessionGuessModeViewState();
}

class _StudySessionGuessModeViewState
    extends ConsumerState<StudySessionGuessModeView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(DurationTokens.fast, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studySessionGuessControllerProvider((
      sessionId: widget.sessionId,
      studyMode: widget.mode,
    ));

    ref.listen<AsyncValue<StudySessionGuessState>>(provider, (
      AsyncValue<StudySessionGuessState>? previous,
      AsyncValue<StudySessionGuessState> next,
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
    });

    final AsyncValue<StudySessionGuessState> value = ref.watch(provider);

    return switch (value) {
      AsyncLoading<StudySessionGuessState>() => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionGuessModeLabel,
          current: 0,
          total: 0,
          onClose: widget.onBack,
        ),
        body: const MxLoadingState(rows: 3),
      ),
      AsyncError<StudySessionGuessState>(:final error) =>
        _StudySessionGuessErrorState(error: error, onBack: widget.onBack),
      AsyncData<StudySessionGuessState>(:final value) => MxStudyScaffold(
        topBar: MxStudyTopBar(
          modeLabel: l10n.studySessionGuessModeLabel,
          current: value.answeredCount,
          total: value.review.items.length,
          onClose: widget.onBack,
        ),
        body: _StudySessionGuessBody(
          state: value,
          onTapOption: (GuessOption option) =>
              ref.read(provider.notifier).selectOption(option),
          onOpenCardActions: (GuessOption option) => _openCardActions(
            context,
            ref,
            widget.sessionId,
            widget.mode,
            option,
          ),
        ),
        bottomAction: _buildBottomAction(
          context: context,
          state: value,
          onRetryFinalize: () => ref.read(provider.notifier).retryFinalize(),
          onSkip: () => ref.read(provider.notifier).skipCountdown(),
        ),
      ),
    };
  }

  Widget? _buildBottomAction({
    required BuildContext context,
    required StudySessionGuessState state,
    required Future<void> Function() onRetryFinalize,
    required VoidCallback onSkip,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state.finalizeFailure != null && !state.isBusy) {
      return MxActionButton(
        intent: MxActionIntent.screenPrimary,
        label: l10n.studyFinalizeAction,
        onPressed: () async {
          await onRetryFinalize();
        },
        fullWidth: true,
      );
    }
    if (!state.isCountdownActive) {
      return null;
    }
    return _GuessCountdownFooter(
      countdownEndsAt: state.countdownEndsAt!,
      countdownDuration: state.countdownDuration!,
      onSkip: onSkip,
    );
  }
}
