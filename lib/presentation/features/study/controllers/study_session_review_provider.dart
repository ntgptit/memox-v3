import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_review_provider.g.dart';

/// Loads the review payload for a session (WBS 4.3.1 / 4.5.3): the persisted
/// header + the ordered, flashcard-joined items, via
/// `LoadStudySessionReviewUseCase`. Read-only for WP-SR2 (the session shell +
/// card); the grading controller that records answers + advances lands in
/// WP-SR3. A `Failure` surfaces as `AsyncError` for the screen's load-error.
@riverpod
Future<StudySessionReview> studySessionReview(
  Ref ref,
  SessionId sessionId,
) async {
  final Result<StudySessionReview> result = await ref
      .read(loadStudySessionReviewUseCaseProvider)
      .call(sessionId: sessionId);
  final StudySessionReview? data = result.data;
  if (data == null) {
    throw _StudySessionReviewException(result.failure);
  }
  return data;
}

/// Carries a domain [Failure] through `AsyncError` so the screen can render it.
class _StudySessionReviewException implements Exception {
  const _StudySessionReviewException(this.failure);

  final Failure? failure;
}
