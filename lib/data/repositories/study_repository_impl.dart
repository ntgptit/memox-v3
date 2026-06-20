import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/domain/repositories/study_repository.dart';

/// Drift-backed [StudyRepository] skeleton (ENABLER — WBS 4.0.1).
///
/// No study/SRS business logic yet: it only owns the stale-session retention
/// sweep, delegating the row mutation to [StudySessionDao] and mapping a storage
/// error to `StorageFailure(write)`. The session lifecycle (create / load /
/// finalize / SRS transition) lands with the study use cases (WBS 4.1.x+).
class StudyRepositoryImpl implements StudyRepository {
  const StudyRepositoryImpl({required StudySessionDao dao}) : _dao = dao;

  final StudySessionDao _dao;

  @override
  Future<Result<int>> expireOldSessions({required int now}) async {
    try {
      final int cutoff = now - StudyRepository.resumeWindow.inMilliseconds;
      final int cancelled = await _dao.cancelSessionsUpdatedBefore(cutoff);
      return (failure: null, data: cancelled);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.write,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
