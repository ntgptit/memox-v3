import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart'
    show StudyScopeEmptyReason;
import 'package:memox/domain/types/ids.dart';

part 'study_entry_outcome.freezed.dart';

/// The resolved outcome the study entry gate renders (WBS 4.1.2 / 4.2.2).
///
/// Derived from `StudyEntryStartResult` by `StudyEntryController`: a resumable
/// session → [resumeRequired] (explicit Resume / Start over, never silent —
/// decision row S28); an eligible scope is auto-created into a session →
/// [ready] (the gate `pushReplacement`s to it); an empty scope → [blocked] with
/// the matrix reason. The transient preparing/error states are the controller's
/// `AsyncLoading` / `AsyncError`, not members here.
@freezed
sealed class StudyEntryOutcome with _$StudyEntryOutcome {
  /// The scope cannot start — render the empty-scope state for [reason]
  /// ([nextDueAt] epoch ms for the `*_noDueCards` reasons).
  const factory StudyEntryOutcome.blocked(
    StudyScopeEmptyReason reason, {
    int? nextDueAt,
  }) = StudyEntryOutcomeBlocked;

  /// A resumable session exists — offer Resume / Start over / Back.
  const factory StudyEntryOutcome.resumeRequired(StudySession session) =
      StudyEntryOutcomeResumeRequired;

  /// A session is ready (newly created or resumed) — the gate navigates to it.
  const factory StudyEntryOutcome.ready(SessionId sessionId) =
      StudyEntryOutcomeReady;
}
