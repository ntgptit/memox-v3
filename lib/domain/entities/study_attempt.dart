import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/box_number.dart';
import 'package:memox/domain/types/study_mode.dart';

part 'study_attempt.freezed.dart';

/// A single persisted answer attempt inside a study session.
@freezed
abstract class StudyAttempt with _$StudyAttempt {
  const factory StudyAttempt({
    required String id,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    required BoxNumber boxBefore,
    required BoxNumber boxAfter,
    String? userInput,
    required DateTime attemptedAt,
  }) = _StudyAttempt;
}
