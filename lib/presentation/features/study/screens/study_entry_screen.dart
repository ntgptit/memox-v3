import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart'
    show StudyScopeEmptyReason;
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_controller.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_outcome.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// The study entry gate (mock `12`, wireframe `12-study-entry-gate.md`).
///
/// A transient gate: it resolves the scope's start outcome
/// (`StudyEntryController`, no silent resume) and either renders the empty-scope
/// state ([StudyEntryOutcome.blocked]), the Resume / Start-over choice
/// ([StudyEntryOutcome.resumeRequired]), or auto-creates a session and
/// `pushReplacement`s to it ([StudyEntryOutcome.ready]) so the gate never stays
/// in the back stack. WBS 4.1.2 / 4.2.2.
///
/// Scope: `deck` / `folder` (via `:entryType/:entryRefId`) + `today` (the
/// literal `today` route, null ref id) — WP-SR1b-1. The `?study_type=` query
/// overrides the entry default (WP-SR1b-1); an unparseable `entryType` or an
/// unrecognized `study_type` falls through to the error surface. The per-reason
/// empty matrix (icon/copy = WP-SR1b-2a; Study-new/Done CTAs + start-over confirm
/// = WP-SR1b-2b; the scope-specific CTAs + "Next due in {X}" = WP-SR1b-2c).
class StudyEntryScreen extends ConsumerWidget {
  const StudyEntryScreen({
    required this.entryType,
    this.entryRefId,
    this.studyTypeRaw,
    super.key,
  });

  /// Raw `:entryType` path segment (`deck` / `folder` / `today`).
  final String entryType;

  /// Raw `:entryRefId` path segment (deck/folder id); `null` for `today`.
  final String? entryRefId;

  /// Raw `?study_type=` query value (`StudyType.storageValue`); `null` → the
  /// entry default, an unrecognized value → the error surface.
  final String? studyTypeRaw;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StudyScope? scope = _resolveScope();
    if (scope == null) {
      return _shell(context, l10n, _errorBody(context, l10n));
    }

    // Navigate out of the gate the moment a session is ready (the gate is
    // transient — `pushReplacement` so Back returns to the caller).
    ref.listen<AsyncValue<StudyEntryOutcome>>(
      studyEntryControllerProvider(scope),
      (AsyncValue<StudyEntryOutcome>? _, AsyncValue<StudyEntryOutcome> next) {
        final StudyEntryOutcome? outcome = next.asData?.value;
        if (outcome is StudyEntryOutcomeReady) {
          _openSession(context, outcome.sessionId);
        }
      },
    );

    final AsyncValue<StudyEntryOutcome> async = ref.watch(
      studyEntryControllerProvider(scope),
    );
    return _shell(
      context,
      l10n,
      AppAsyncBuilder<StudyEntryOutcome>(
        value: async,
        loading: (_) => _preparingBody(l10n),
        error: (_, _) => _errorBody(context, l10n),
        data: (StudyEntryOutcome outcome) => switch (outcome) {
          // Ready is transient — the listener above navigates away; keep the
          // preparing placeholder visible until the replacement lands.
          StudyEntryOutcomeReady() => _preparingBody(l10n),
          StudyEntryOutcomeBlocked(:final StudyScopeEmptyReason reason) =>
            _blockedBody(context, l10n, reason, scope),
          StudyEntryOutcomeResumeRequired(:final StudySession session) =>
            _resumeBody(context, ref, l10n, scope, session),
        },
      ),
    );
  }

  StudyScope? _resolveScope() {
    EntryType? type;
    for (final EntryType e in EntryType.values) {
      if (e.name == entryType) {
        type = e;
        break;
      }
    }
    if (type == null) return null;
    final bool isToday = type == EntryType.today;
    final String? refId = entryRefId;
    // `today` must not carry a ref id; `deck`/`folder` require one.
    if (isToday && refId != null) return null;
    if (!isToday && (refId == null || refId.isEmpty)) return null;
    final StudyType? studyType = _resolveStudyType(isToday: isToday);
    if (studyType == null) return null; // unrecognized `study_type` → error
    return StudyScope(entryType: type, entryRefId: refId, studyType: studyType);
  }

  /// The `?study_type=` override when present and valid, else the entry default
  /// (`deck`/`folder` → new, `today` → due review). Returns `null` for an
  /// unrecognized token so the gate fails fast into the error surface.
  StudyType? _resolveStudyType({required bool isToday}) {
    final String? raw = studyTypeRaw;
    if (raw == null || raw.isEmpty) {
      return isToday ? StudyType.srsReview : StudyType.newCards;
    }
    return StudyType.fromStorage(raw);
  }

  void _openSession(BuildContext context, String sessionId) =>
      context.pushReplacementNamed(
        RouteNames.studySession,
        pathParameters: <String, String>{RouteParams.sessionId: sessionId},
      );

  Widget _shell(BuildContext context, AppLocalizations l10n, Widget body) =>
      MxScaffold(
        appBar: MxAppBar(
          automaticallyImplyLeading: false,
          leading: MxIconButton.toolbar(
            icon: Icons.arrow_back,
            tooltip: l10n.commonCancel,
            onPressed: () => context.pop(),
          ),
          title: l10n.studyEntryTitle,
        ),
        body: body,
      );

  Widget _preparingBody(AppLocalizations l10n) =>
      MxLoadingState(message: l10n.studyPreparing);

  Widget _errorBody(BuildContext context, AppLocalizations l10n) =>
      MxErrorState(
        title: l10n.studyEntryErrorTitle,
        message: l10n.studyEntryErrorMessage,
        icon: Icons.error_outline,
        action: MxSecondaryButton(
          label: l10n.commonBack,
          onPressed: () => context.pop(),
        ),
      );

  /// The per-reason empty-scope matrix (`study-flow.md` §Empty scope matrix,
  /// wireframe `12`). WP-SR1b-2a renders the tailored icon / title / message for
  /// each of the 8 `StudyScopeEmptyReason`s; WP-SR1b-2b adds the Study-new /
  /// Done CTAs (see `_blockedAction`). The scope-specific CTAs (Add flashcards /
  /// View suspended / Open folder / Create deck) + the streak inset + the "Next
  /// due in {relativeTime}" line are **WP-SR1b-2c**. The gate always **blocks**
  /// the zero-card session here.
  Widget _blockedBody(
    BuildContext context,
    AppLocalizations l10n,
    StudyScopeEmptyReason reason,
    StudyScope scope,
  ) {
    final (IconData icon, String title, String message) = switch (reason) {
      StudyScopeEmptyReason.deckNoCards => (
        Icons.style_outlined,
        l10n.studyEmptyDeckNoCardsTitle,
        l10n.studyEmptyDeckNoCardsMessage,
      ),
      StudyScopeEmptyReason.deckNoDueCards => (
        Icons.check_circle_outline,
        l10n.studyEmptyCaughtUpTitle,
        l10n.studyEmptyDeckNoDueMessage,
      ),
      StudyScopeEmptyReason.folderNoCards => (
        Icons.style_outlined,
        l10n.studyEmptyFolderNoCardsTitle,
        l10n.studyEmptyFolderNoCardsMessage,
      ),
      StudyScopeEmptyReason.folderNoDueCards => (
        Icons.check_circle_outline,
        l10n.studyEmptyCaughtUpTitle,
        l10n.studyEmptyFolderNoDueMessage,
      ),
      StudyScopeEmptyReason.todayAllDone => (
        Icons.celebration_outlined,
        l10n.studyEmptyTodayAllDoneTitle,
        l10n.studyEmptyTodayAllDoneMessage,
      ),
      StudyScopeEmptyReason.todayNoContent => (
        Icons.style_outlined,
        l10n.studyEmptyTodayNoContentTitle,
        l10n.studyEmptyTodayNoContentMessage,
      ),
      StudyScopeEmptyReason.allBuried => (
        Icons.bedtime_outlined,
        l10n.studyEmptyAllBuriedTitle,
        l10n.studyEmptyAllBuriedMessage,
      ),
      StudyScopeEmptyReason.allSuspended => (
        Icons.pause_circle_outlined,
        l10n.studyEmptyAllSuspendedTitle,
        l10n.studyEmptyAllSuspendedMessage,
      ),
    };
    return MxEmptyState(
      icon: icon,
      title: title,
      message: message,
      action: _blockedAction(context, l10n, reason, scope),
    );
  }

  /// The per-reason CTA (WP-SR1b-2b): **Study new instead** (re-enter the gate
  /// with `?study_type=new_cards`) for the *no-due* + all-buried reasons,
  /// **Done** (pop) for the all-done / all-buried reasons, else **Back**. The
  /// scope-specific CTAs (Add flashcards / View suspended / Open folder / Create
  /// deck) + the "Next due in {relativeTime}" line are WP-SR1b-2c.
  Widget _blockedAction(
    BuildContext context,
    AppLocalizations l10n,
    StudyScopeEmptyReason reason,
    StudyScope scope,
  ) {
    final Widget studyNew = MxPrimaryButton(
      label: l10n.studyActionStudyNew,
      fullWidth: true,
      onPressed: () => _reenterWithNewCards(context, scope),
    );
    final Widget done = MxSecondaryButton(
      label: l10n.commonDone,
      fullWidth: true,
      onPressed: () => context.pop(),
    );
    return switch (reason) {
      StudyScopeEmptyReason.deckNoDueCards ||
      StudyScopeEmptyReason.folderNoDueCards => studyNew,
      StudyScopeEmptyReason.allBuried => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          studyNew,
          const SizedBox(height: MxSpacing.space3),
          done,
        ],
      ),
      StudyScopeEmptyReason.todayAllDone => done,
      _ => MxSecondaryButton(
        label: l10n.commonBack,
        onPressed: () => context.pop(),
      ),
    };
  }

  /// Re-enter the gate for the same scope with `?study_type=new_cards` so a
  /// caught-up / all-buried scope can fall back to new learning (mock `12`
  /// "Study new instead"). `pushReplacement` keeps the gate transient.
  void _reenterWithNewCards(BuildContext context, StudyScope scope) {
    final Map<String, String> query = <String, String>{
      RouteParams.studyTypeQueryParam: StudyType.newCards.storageValue,
    };
    if (scope.entryType == EntryType.today) {
      context.pushReplacementNamed(
        RouteNames.studyToday,
        queryParameters: query,
      );
      return;
    }
    context.pushReplacementNamed(
      RouteNames.studyEntry,
      pathParameters: <String, String>{
        RouteParams.entryType: scope.entryType.name,
        RouteParams.entryRefId: scope.entryRefId ?? '',
      },
      queryParameters: query,
    );
  }

  Widget _resumeBody(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    StudyScope scope,
    StudySession session,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(l10n.studyResumeTitle, role: MxTextRole.titleLarge),
          const SizedBox(height: MxSpacing.space2),
          MxText(l10n.studyResumeMessage, role: MxTextRole.bodyMedium),
          const SizedBox(height: MxSpacing.space5),
          MxPrimaryButton(
            label: l10n.studyResumeAction,
            fullWidth: true,
            onPressed: () => _openSession(context, session.id),
          ),
          const SizedBox(height: MxSpacing.space3),
          MxSecondaryButton(
            label: l10n.studyStartOverAction,
            fullWidth: true,
            onPressed: () =>
                _confirmStartOver(context, ref, l10n, scope, session),
          ),
          const SizedBox(height: MxSpacing.space3),
          MxSecondaryButton(
            label: l10n.commonBack,
            fullWidth: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    ),
  );

  /// Start over discards the resumable session — confirm first (decision S87,
  /// the FE of S28 "Start over confirms then restarts"), then cancel + create.
  Future<void> _confirmStartOver(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    StudyScope scope,
    StudySession session,
  ) async {
    final bool confirmed = await MxConfirmDialog.show(
      context,
      title: l10n.studyStartOverTitle,
      message: l10n.studyStartOverMessage,
      confirmLabel: l10n.studyStartOverAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    await ref
        .read(studyEntryControllerProvider(scope).notifier)
        .startOver(session);
  }
}
