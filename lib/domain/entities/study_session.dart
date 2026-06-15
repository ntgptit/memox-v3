import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
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

    /// Ordered phase plan for this session (per-phase chaining).
    required StudyFlow studyFlow,

    /// Active phase pointer; `null` marks a legacy single-mode session
    /// resolved through the recall fallback.
    required StudyMode? currentMode,
    required DateTime startedAt,
    required DateTime updatedAt,
  }) = _StudySession;
}
