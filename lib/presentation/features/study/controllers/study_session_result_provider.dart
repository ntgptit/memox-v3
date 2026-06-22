import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_result_provider.g.dart';

/// Loads the result summary for a finished session (WBS 4.7.2): the persisted
/// header + the ordered, flashcard-joined items with their terminal outcomes,
/// via `LoadStudySessionResultUseCase`. The session is finalized by the Finish
/// action **before** this route is reached (WP-SR5a), so this is read-only.
/// A `Failure` surfaces as `AsyncError` for the screen's load-error.
@riverpod
Future<StudySessionResult> studySessionResult(
  Ref ref,
  SessionId sessionId,
) async {
  final Result<StudySessionResult> result = await ref
      .read(loadStudySessionResultUseCaseProvider)
      .call(sessionId: sessionId);
  final StudySessionResult? data = result.data;
  if (data == null) {
    throw _StudySessionResultException(result.failure);
  }
  return data;
}

/// Carries a domain [Failure] through `AsyncError` so the screen can render it.
class _StudySessionResultException implements Exception {
  const _StudySessionResultException(this.failure);

  final Failure? failure;
}
