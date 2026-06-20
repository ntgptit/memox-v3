import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Read port for study entry eligibility (WBS 4.1.1).
///
/// Resolves whether a [StudyScope] can start a session and, when it cannot, the
/// empty-scope matrix branch to render (`docs/business/study/study-flow.md`
/// §Empty scope matrix). Card-list loading + batching live in session creation
/// (WBS 4.2.1); this port only classifies the scope's counts.
abstract interface class StudyEntryRepository {
  /// Classifies [scope] as of [now] (epoch ms). Returns a
  /// [StudyEntryEligibility] (eligible count or an empty reason). A `deck`/
  /// `folder` scope with a `null` `entryRefId` is a `ValidationFailure`; a read
  /// error maps to a `StorageFailure`.
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  });
}
