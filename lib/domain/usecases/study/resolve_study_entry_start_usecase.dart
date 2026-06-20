import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/study_scope.dart';

/// The no-silent-resume study entry gate (WBS 4.2.2).
///
/// Owns the `now` clock and resolves what the gate must do for a [StudyScope]:
/// a resumable session → [StudyEntryStartResult.resumeRequired] (never resumed
/// silently — decision row S28); otherwise eligibility (WBS 4.1.1) decides
/// [StudyEntryStartResult.canStart] vs [StudyEntryStartResult.blocked].
class ResolveStudyEntryStartUseCase {
  const ResolveStudyEntryStartUseCase({
    required this.studyRepository,
    required this.entryRepository,
  });

  final StudyRepository studyRepository;
  final StudyEntryRepository entryRepository;

  Future<Result<StudyEntryStartResult>> call({
    required StudyScope scope,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    final Result<StudySession?> resumable = await studyRepository.findResumable(
      scope: scope,
      now: now,
    );
    if (resumable.failure != null) {
      return (failure: resumable.failure, data: null);
    }
    final StudySession? session = resumable.data;
    if (session != null) {
      return (
        failure: null,
        data: StudyEntryStartResult.resumeRequired(session),
      );
    }

    final Result<StudyEntryEligibility> eligibility = await entryRepository
        .resolveEligibility(scope: scope, now: now);
    final StudyEntryEligibility? elig = eligibility.data;
    if (elig == null) {
      return (failure: eligibility.failure, data: null);
    }
    // The eligibility repo (WBS 4.1.1) sets exactly one of: no `emptyReason`
    // (eligible to start) or an `emptyReason` naming the empty-scope state.
    final StudyScopeEmptyReason? reason = elig.emptyReason;
    return (
      failure: null,
      data: reason == null
          ? StudyEntryStartResult.canStart(elig)
          : StudyEntryStartResult.blocked(reason, nextDueAt: elig.nextDueAt),
    );
  }
}
