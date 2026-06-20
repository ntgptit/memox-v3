import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Creates a new study session for a scope from a resolved, ordered card list
/// (WBS 4.2.1).
///
/// Owns the `now` clock (epoch ms) used for the session timestamps so the
/// repository stays clock-free, then delegates the transactional
/// `study_sessions` + `study_session_items` insert to [StudyRepository]. The
/// caller resolves the ordered [flashcardIds] (eligibility gate WBS 4.1.1); this
/// use case applies the [maxSessionItems] batch cap (WBS 4.2.4) before
/// persisting. Failures propagate as `ValidationFailure` (empty list) or
/// `StorageFailure`.
class CreateStudySessionUseCase {
  const CreateStudySessionUseCase({required this.repository});

  /// Max cards persisted per session (`docs/business/study/study-flow.md`
  /// §Rules, WBS 4.2.4). When the resolved list is larger, only the first
  /// [maxSessionItems] (in the caller's resolved order: due-date for review,
  /// sort order for new) become session items. Caps unbounded recursive folder
  /// scopes so an abandoned session loses at most one batch of SRS credit.
  static const int maxSessionItems = 20;

  final StudyRepository repository;

  Future<Result<StudySession>> call({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    // Validation is the use-case layer's responsibility
    // (`docs/contracts/error-contract.md` §Domain layer): reject an empty queue
    // before touching the repository. The empty-scope gate (WBS 4.1.1) normally
    // makes this impossible; the repo keeps a defensive mirror of this guard.
    if (flashcardIds.isEmpty) {
      return (
        failure: const Failure.validation(
          field: 'flashcardIds',
          code: ValidationCode.insufficientContent,
          message: 'Cannot create a study session with no cards.',
        ),
        data: null,
      );
    }
    // Batch cap (WBS 4.2.4): take the first maxSessionItems in resolved order.
    final List<FlashcardId> batch = flashcardIds.length > maxSessionItems
        ? flashcardIds.sublist(0, maxSessionItems)
        : flashcardIds;
    return repository.createSession(
      scope: scope,
      flashcardIds: batch,
      now: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
