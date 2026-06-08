import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_type.dart';

part 'study_session.freezed.dart';

/// Persisted study session header.
@freezed
abstract class StudySession with _$StudySession {
  const factory StudySession({
    required SessionId id,
    required EntryType entryType,
    required EntryRefId entryRefId,
    required StudyType studyType,
    required SessionStatus status,
    required DateTime startedAt,
    required DateTime updatedAt,
  }) = _StudySession;
}
