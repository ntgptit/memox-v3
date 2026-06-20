import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';

part 'study_session.freezed.dart';

/// A persisted study session header (`study_sessions` row).
///
/// Owns its resolved [scope] (entry type / ref id / study type), lifecycle
/// [status], and activity timestamps. The ordered queue of cards lives in
/// `study_session_items` (loaded separately, WBS 4.3.1). Timestamps are UTC
/// (the mapper converts the persisted epoch-ms at the data boundary). See
/// `docs/business/study/study-flow.md` and `docs/database/schema-contract.md`
/// §study_sessions.
@freezed
sealed class StudySession with _$StudySession {
  const factory StudySession({
    required SessionId id,
    required StudyScope scope,
    required SessionStatus status,
    required DateTime startedAt,
    required DateTime updatedAt,
  }) = _StudySession;
}
