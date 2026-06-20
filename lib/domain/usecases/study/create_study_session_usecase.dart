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
/// caller resolves [flashcardIds] (eligibility gate WBS 4.1.1) and applies the
/// `maxSessionItems` cap (WBS 4.2.4) before calling. Failures propagate as
/// `ValidationFailure` (empty list) or `StorageFailure`.
class CreateStudySessionUseCase {
  const CreateStudySessionUseCase({required this.repository});

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
    return repository.createSession(
      scope: scope,
      flashcardIds: flashcardIds,
      now: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
