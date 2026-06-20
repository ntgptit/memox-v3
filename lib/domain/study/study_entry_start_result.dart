import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';

part 'study_entry_start_result.freezed.dart';

/// The controlled outcome of the study entry gate (WBS 4.2.2): what the gate
/// must do when the user starts study on a scope.
///
/// Study Entry V1 **must not silently resume**: when a resumable session exists
/// it returns [StudyEntryStartResult.resumeRequired] so the FE renders explicit
/// Resume / Start over / Back actions (`docs/business/resume/resume-session.md`,
/// decision row S28). Otherwise it resolves eligibility (WBS 4.1.1) into
/// [StudyEntryStartResult.canStart] (a session may be created) or
/// [StudyEntryStartResult.blocked] (an empty-scope reason to render).
@freezed
sealed class StudyEntryStartResult with _$StudyEntryStartResult {
  /// A resumable session already exists for this scope — offer Resume / Start
  /// over instead of creating a new one.
  const factory StudyEntryStartResult.resumeRequired(StudySession session) =
      StudyEntryResumeRequired;

  /// No resumable session and the scope has eligible cards — proceed to session
  /// creation (WBS 4.2.1) with this [eligibility].
  const factory StudyEntryStartResult.canStart(
    StudyEntryEligibility eligibility,
  ) = StudyEntryCanStart;

  /// No resumable session and the scope cannot start — render the empty-scope
  /// state for [reason] (with [nextDueAt] for the `*_noDueCards` reasons).
  const factory StudyEntryStartResult.blocked(
    StudyScopeEmptyReason reason, {
    int? nextDueAt,
  }) = StudyEntryBlocked;
}
