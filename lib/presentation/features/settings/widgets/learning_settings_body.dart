import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/features/settings/widgets/learning_goal_card.dart';
import 'package:memox/presentation/features/settings/widgets/learning_reminder_card.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_busy_overlay.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The Learning-settings body (kit screen 22): renders the daily-goal + reminder
/// cards over the controller, with a saving overlay while a write is in flight.
class LearningSettingsBody extends ConsumerWidget {
  const LearningSettingsBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<LearningSettingsView> async = ref.watch(
      learningSettingsControllerProvider,
    );
    return AppAsyncBuilder<LearningSettingsView>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        title: l10n.learningSettingsErrorTitle,
        message: l10n.learningSettingsErrorMessage,
      ),
      data: (LearningSettingsView view) => _content(context, ref, l10n, view),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LearningSettingsView view,
  ) {
    final MxColors colors = context.mxColors;
    final LearningSettingsController controller = ref.read(
      learningSettingsControllerProvider.notifier,
    );
    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.fromLTRB(
            MxSpacing.screen,
            MxSpacing.space4,
            MxSpacing.screen,
            MxSpacing.space6,
          ),
          children: <Widget>[
            LearningGoalCard(
              view: view,
              onToggle: controller.setGoalEnabled,
              onLimit: controller.setDailyLimit,
            ),
            const SizedBox(height: MxSpacing.space4),
            const LearningReminderCard(),
          ],
        ),
        if (view.saving) ...<Widget>[
          Positioned.fill(child: ColoredBox(color: colors.overlay)),
          Positioned.fill(
            child: MxBusyOverlay(label: l10n.learningSettingsSaving),
          ),
        ],
      ],
    );
  }
}
