import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_controller.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_outcome.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
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
/// empty matrix (replacing the generic empty surface) is WP-SR1b-2.
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
          StudyEntryOutcomeBlocked() => _blockedBody(context, l10n),
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

  /// WP-SR1a renders a single generic empty surface for every
  /// `StudyScopeEmptyReason`; the per-reason matrix (deck-no-cards, all-done,
  /// all-buried, …) with its dedicated CTAs is WP-SR1b-2. The gate still **blocks**
  /// the zero-card session here — only the copy is generic for now.
  Widget _blockedBody(BuildContext context, AppLocalizations l10n) =>
      MxEmptyState(
        icon: Icons.check_circle_outline,
        title: l10n.studyEmptyGenericTitle,
        message: l10n.studyEmptyGenericMessage,
        action: MxSecondaryButton(
          label: l10n.commonBack,
          onPressed: () => context.pop(),
        ),
      );

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
            onPressed: () => ref
                .read(studyEntryControllerProvider(scope).notifier)
                .startOver(session),
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
}
