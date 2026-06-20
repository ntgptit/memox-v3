import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Cancels (discards) a study session (WBS 4.10.1).
///
/// Moves the session to `cancelled` without deleting it; recorded
/// `study_attempts` are preserved (`docs/contracts/usecase-contracts/study.md`
/// §CancelSessionUseCase). Used by the transactional start-over flow before
/// re-entering the same scope. A missing session is a `NotFoundFailure`.
class CancelStudySessionUseCase {
  const CancelStudySessionUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({required SessionId id}) =>
      repository.cancelSession(id: id);
}
