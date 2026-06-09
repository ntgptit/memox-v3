import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_result_viewmodel.g.dart';
part 'study_result_viewmodel.freezed.dart';

@riverpod
class StudyResultController extends _$StudyResultController {
  @override
  Future<StudyResultScreenState> build(SessionId sessionId) async {
    await Future<void>.delayed(Duration.zero);

    final String trimmedSessionId = StringUtils.trimmed(sessionId);
    if (trimmedSessionId.isEmpty) {
      return const StudyResultScreenState.invalidSessionId();
    }

    final Result<StudySessionResult> result = await ref
        .read(loadStudySessionResultUseCaseProvider)
        .call(sessionId: trimmedSessionId);

    return switch (result) {
      Ok<StudySessionResult>(:final value) =>
        switch (value.session.status) {
          SessionStatus.completed =>
            StudyResultScreenState.success(result: value),
          _ => StudyResultScreenState.notCompleted(status: value.session.status),
        },
      Err<StudySessionResult>(:final failure) => switch (failure) {
        NotFoundFailure() => const StudyResultScreenState.notFound(),
        _ => throw StudyResultFailureException(failure),
      },
    };
  }
}

@freezed
abstract class StudyResultScreenState with _$StudyResultScreenState {
  const factory StudyResultScreenState.invalidSessionId() =
      InvalidSessionId;
  const factory StudyResultScreenState.notFound() = NotFound;
  const factory StudyResultScreenState.notCompleted({
    required SessionStatus status,
  }) = NotCompleted;
  const factory StudyResultScreenState.success({
    required StudySessionResult result,
  }) = Success;
}

class StudyResultFailureException implements Exception {
  const StudyResultFailureException(this.failure);

  final Failure failure;
}
