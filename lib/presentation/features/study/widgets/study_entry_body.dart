import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/study/study_entry_route_input.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

class StudyEntryBody extends StatelessWidget {
  const StudyEntryBody({required this.request, required this.value, super.key});

  final StudyEntryRouteInput request;
  final AsyncValue<StudyEntryStartResult> value;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppAsyncBuilder<StudyEntryStartResult>(
      value: value,
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
      data: (StudyEntryStartResult result) => switch (result) {
        StudyEntryStartStarted() => _StudyEntryLoadingState(
          title: l10n.studyEntryPreparingTitle,
          message: l10n.studyEntryPreparingMessage,
        ),
        StudyEntryStartResumeRequired(:final sessionId) =>
          _StudyEntryResumeRequiredState(sessionId: sessionId),
        StudyEntryStartEmpty(:final emptyState) => _StudyEntryEmptyStateView(
          request: request,
          emptyState: emptyState,
        ),
        StudyEntryStartResult() => const SizedBox.shrink(),
      },
    );
  }
}

class _StudyEntryLoadingState extends StatelessWidget {
  const _StudyEntryLoadingState({required this.title, required this.message});

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

class _StudyEntryEmptyStateView extends StatelessWidget {
  const _StudyEntryEmptyStateView({
    required this.request,
    required this.emptyState,
  });

  final StudyEntryRouteInput request;
  final StudyEntryEmptyState emptyState;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EntryType entryType = _parseEntryType(request.entryType);
    final String? message = _message(l10n);
    final String actionLabel = _actionLabel(l10n);

    return MxEmptyState(
      icon: _icon,
      title: _title(l10n),
      message: message,
      actionLabel: actionLabel,
      onAction: () => _onAction(context, entryType),
    );
  }

  IconData get _icon => switch (emptyState.variant) {
    StudyEntryEmptyVariant.deckNoCards => Icons.view_carousel_outlined,
    StudyEntryEmptyVariant.deckNoDueCards => Icons.check_circle_outline,
    StudyEntryEmptyVariant.folderNoCards => Icons.folder_outlined,
    StudyEntryEmptyVariant.folderNoDueCards => Icons.check_circle_outline,
    StudyEntryEmptyVariant.todayAllDone => Icons.celebration_outlined,
    StudyEntryEmptyVariant.todayNoContent => Icons.library_add_outlined,
    StudyEntryEmptyVariant.allBuried => Icons.nightlight_outlined,
    StudyEntryEmptyVariant.allSuspended => Icons.volume_off_outlined,
  };

  String _title(AppLocalizations l10n) => switch (emptyState.variant) {
    StudyEntryEmptyVariant.deckNoCards => l10n.studyEmpty_deck_noCards_title,
    StudyEntryEmptyVariant.deckNoDueCards =>
      l10n.studyEmpty_deck_noDueCards_title,
    StudyEntryEmptyVariant.folderNoCards =>
      l10n.studyEmpty_folder_noCards_title,
    StudyEntryEmptyVariant.folderNoDueCards =>
      l10n.studyEmpty_folder_noDueCards_title,
    StudyEntryEmptyVariant.todayAllDone => l10n.studyEmpty_today_allDone_title,
    StudyEntryEmptyVariant.todayNoContent =>
      l10n.studyEmpty_today_noContent_title,
    StudyEntryEmptyVariant.allBuried => l10n.studyEmpty_allBuried_title,
    StudyEntryEmptyVariant.allSuspended => l10n.studyEmpty_allSuspended_title,
  };

  String? _message(AppLocalizations l10n) => switch (emptyState.variant) {
    StudyEntryEmptyVariant.deckNoCards => null,
    StudyEntryEmptyVariant.deckNoDueCards => _nextDueMessage(l10n),
    StudyEntryEmptyVariant.folderNoCards => null,
    StudyEntryEmptyVariant.folderNoDueCards => _nextDueMessage(l10n),
    StudyEntryEmptyVariant.todayAllDone =>
      l10n.studyEmpty_today_allDone_message,
    StudyEntryEmptyVariant.todayNoContent => null,
    StudyEntryEmptyVariant.allBuried => l10n.studyEmpty_allBuried_message,
    StudyEntryEmptyVariant.allSuspended => l10n.studyEmpty_allSuspended_message,
  };

  String _actionLabel(AppLocalizations l10n) => switch (emptyState.variant) {
    StudyEntryEmptyVariant.deckNoCards => l10n.studyEmpty_deck_noCards_cta,
    StudyEntryEmptyVariant.deckNoDueCards =>
      l10n.studyEmpty_deck_noDueCards_cta,
    StudyEntryEmptyVariant.folderNoCards => l10n.studyEmpty_folder_noCards_cta,
    StudyEntryEmptyVariant.folderNoDueCards =>
      l10n.studyEmpty_folder_noDueCards_cta,
    StudyEntryEmptyVariant.todayAllDone => l10n.studyEmpty_today_allDone_cta,
    StudyEntryEmptyVariant.todayNoContent =>
      l10n.studyEmpty_today_noContent_cta,
    StudyEntryEmptyVariant.allBuried => l10n.studyEmpty_allBuried_cta,
    StudyEntryEmptyVariant.allSuspended => l10n.studyEmpty_allSuspended_cta,
  };

  String? _nextDueMessage(AppLocalizations l10n) {
    final DateTime? nextDueAt = emptyState.nextDueAt;
    if (nextDueAt == null) {
      return null;
    }
    final DateTime now = DateTime.now().toUtc();
    final Duration delta = nextDueAt.difference(now);
    if (delta.inMinutes < 60) {
      return l10n.studyEmptyNextDueSoon;
    }
    if (delta.inDays < 1) {
      return l10n.studyEmptyNextDueInHours(delta.inHours);
    }
    return l10n.studyEmptyNextDueInDays(delta.inDays);
  }

  void _onAction(BuildContext context, EntryType entryType) {
    final StudyType studyType = switch (emptyState.variant) {
      StudyEntryEmptyVariant.deckNoCards => StudyType.newCards,
      StudyEntryEmptyVariant.deckNoDueCards => StudyType.newCards,
      StudyEntryEmptyVariant.folderNoCards => StudyType.newCards,
      StudyEntryEmptyVariant.folderNoDueCards => StudyType.newCards,
      StudyEntryEmptyVariant.todayAllDone => StudyType.srsReview,
      StudyEntryEmptyVariant.todayNoContent => StudyType.srsReview,
      StudyEntryEmptyVariant.allBuried => StudyType.newCards,
      StudyEntryEmptyVariant.allSuspended => StudyType.newCards,
    };

    switch (emptyState.variant) {
      case StudyEntryEmptyVariant.deckNoCards:
        final String? deckId = request.entryRefId;
        if (deckId != null && deckId.isNotEmpty) {
          context.pushFlashcardCreate(deckId);
          return;
        }
        context.pop();
        return;
      case StudyEntryEmptyVariant.deckNoDueCards:
      case StudyEntryEmptyVariant.folderNoDueCards:
        context.goStudyEntry(
          entryType: entryType,
          entryRefId: request.entryRefId,
          studyType: studyType,
          mode: _modeFromRequest(),
        );
        return;
      case StudyEntryEmptyVariant.allBuried:
        if (entryType == EntryType.today) {
          context.goLibrary();
          return;
        }
        context.goStudyEntry(
          entryType: entryType,
          entryRefId: request.entryRefId,
          studyType: studyType,
          mode: _modeFromRequest(),
        );
        return;
      case StudyEntryEmptyVariant.folderNoCards:
        context.goFolderDetail(request.entryRefId ?? '');
        return;
      case StudyEntryEmptyVariant.todayAllDone:
        context.goHome();
        return;
      case StudyEntryEmptyVariant.todayNoContent:
      case StudyEntryEmptyVariant.allSuspended:
        context.goLibrary();
        return;
    }
  }

  StudyMode? _modeFromRequest() {
    final String? mode = request.modeQuery;
    if (mode == null || mode.isEmpty) {
      return null;
    }
    return switch (mode) {
      'review' => StudyMode.review,
      'match' => StudyMode.match,
      'guess' => StudyMode.guess,
      'recall' => StudyMode.recall,
      'fill' => StudyMode.fill,
      _ => null,
    };
  }

  EntryType _parseEntryType(String value) => switch (value) {
    'deck' => EntryType.deck,
    'folder' => EntryType.folder,
    'today' => EntryType.today,
    _ => EntryType.today,
  };
}

class _StudyEntryResumeRequiredState extends StatelessWidget {
  const _StudyEntryResumeRequiredState({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxEmptyState(
      key: ValueKey<String>('study-entry-resume-required-$sessionId'),
      icon: Icons.history,
      title: l10n.studyEntryResumeRequiredTitle,
      message: l10n.studyEntryResumeRequiredMessage,
      actionLabel: l10n.studyEntryResumeRequiredCta,
      onAction: () => context.pop(),
    );
  }
}
