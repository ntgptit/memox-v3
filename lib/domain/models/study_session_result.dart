import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';

part 'study_session_result.freezed.dart';

/// Persisted study-session result read model.
///
/// Carries the finalized session header plus the summary counts the result
/// screen needs to render a V1 completion view.
@freezed
abstract class StudySessionResult with _$StudySessionResult {
  const factory StudySessionResult({
    required StudySession session,
    required int totalCount,
    required int answeredCount,
    required int forgotCount,
    required int passedCount,
  }) = _StudySessionResult;
}
