import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads a session's review payload — header + ordered, flashcard-joined items
/// (WBS 4.3.1).
///
/// Thin delegation to [StudyRepository.loadStudySessionReview]; the review
/// controller (WBS 4.3.2) resumes at `firstUnansweredIndex`. A missing session
/// is a `NotFoundFailure`; an item-less session is a controlled
/// `ValidationFailure` (`docs/contracts/usecase-contracts/study.md`
/// §LoadStudySessionReviewUseCase).
class LoadStudySessionReviewUseCase {
  const LoadStudySessionReviewUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<StudySessionReview>> call({required SessionId sessionId}) =>
      repository.loadStudySessionReview(id: sessionId);
}
