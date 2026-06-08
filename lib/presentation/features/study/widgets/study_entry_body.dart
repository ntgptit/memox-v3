import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/types/types.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/viewmodels/study_entry_viewmodel.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

class StudyEntryBody extends ConsumerWidget {
  const StudyEntryBody({required this.request, super.key});

  final StudyEntryRouteInput request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppAsyncBuilder<StudyEntryRouteState>(
      value: ref.watch(studyEntryProvider(request)),
      loading: (BuildContext context) => _StudyEntryLoadingState(
        title: l10n.studyEntryPreparingTitle,
        message: l10n.studyEntryPreparingMessage,
      ),
      error: (Object error, StackTrace? stackTrace) => MxErrorState(
        title: l10n.studyEntryInvalidTitle,
        message: l10n.studyEntryInvalidMessage,
        retryLabel: l10n.commonBack,
        onRetry: () => context.pop(),
      ),
      data: (StudyEntryRouteState state) => _StudyEntryUnsupportedState(
        state: state,
        title: l10n.studyEntryUnsupportedTitle,
        message: l10n.studyEntryUnsupportedMessage,
        actionLabel: l10n.commonBack,
        onAction: () => context.pop(),
      ),
    );
  }
}

class _StudyEntryLoadingState extends StatelessWidget {
  const _StudyEntryLoadingState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: MxLoadingState(rows: 3)),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudyEntryUnsupportedState extends StatelessWidget {
  const _StudyEntryUnsupportedState({
    required this.state,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final StudyEntryRouteState state;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (state.entryType) {
      EntryType.today => Icons.today_outlined,
      EntryType.deck => Icons.view_carousel_outlined,
      EntryType.folder => Icons.folder_outlined,
    };

    return MxEmptyState(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
