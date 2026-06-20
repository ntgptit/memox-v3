import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Resolves whether a study scope can start a session (WBS 4.1.1).
///
/// Owns the `now` clock (epoch ms) used for the due/buried cutoffs so the
/// repository stays clock-free, then delegates to [StudyEntryRepository]. The
/// caller (the entry gate, WBS 4.1.2) renders the empty-scope branch or proceeds
/// to session creation (WBS 4.2.1). Failures propagate as `ValidationFailure`
/// (missing ref id) or `StorageFailure(read)`.
class ResolveStudyEntryEligibilityUseCase {
  const ResolveStudyEntryEligibilityUseCase({required this.repository});

  final StudyEntryRepository repository;

  Future<Result<StudyEntryEligibility>> call({required StudyScope scope}) =>
      repository.resolveEligibility(
        scope: scope,
        now: DateTime.now().millisecondsSinceEpoch,
      );
}
