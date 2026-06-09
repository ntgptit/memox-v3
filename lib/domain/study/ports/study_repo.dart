import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Study session repository contract.
///
/// The V1 gate only needs session start and resumable lookup, but the contract
/// also exposes the transactional create path so the data layer can be tested
/// directly.
abstract interface class StudyRepository {
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
  });

  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  });

  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary();

  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  });

  Future<Result<void>> cancelStudySession({required SessionId sessionId});

  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
  });

  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  });
}
