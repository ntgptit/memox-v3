import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/study_session.dart';

part 'dashboard_resume_session_summary.freezed.dart';

/// Dashboard resume card read model.
@freezed
abstract class DashboardResumeSessionSummary
    with _$DashboardResumeSessionSummary {
  const factory DashboardResumeSessionSummary({
    required StudySession session,
    required int answeredCount,
    required int totalCount,
    String? scopeLabel,
  }) = _DashboardResumeSessionSummary;
}
