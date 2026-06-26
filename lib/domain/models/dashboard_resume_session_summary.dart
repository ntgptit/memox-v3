import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

part 'dashboard_resume_session_summary.freezed.dart';

/// The Dashboard "Continue studying" read model (WBS 5.1.1): the user's single
/// most recently active resumable session, with its scope, resolved scope name,
/// and progress.
///
/// [scopeName] is the session scope's display name, resolved read-only at query
/// time: the deck name for a `deck` scope, the folder name for a `folder` scope,
/// and `null` for the global `today` scope (the FE renders a localized label).
/// The card renders a Continue CTA and is hidden when there is no resumable
/// session (the repository returns `null`). See
/// `docs/business/engagement/dashboard-engagement.md` +
/// `docs/business/resume/resume-session.md`.
@freezed
sealed class DashboardResumeSessionSummary
    with _$DashboardResumeSessionSummary {
  const factory DashboardResumeSessionSummary({
    required SessionId sessionId,
    required StudyScope scope,
    required int answeredCount,
    required int totalCount,
    required DateTime lastActiveAt,
    String? scopeName,
  }) = _DashboardResumeSessionSummary;
  const DashboardResumeSessionSummary._();

  /// Fraction of items answered (0..1); 0 when the session has no items.
  double get progress => totalCount == 0 ? 0 : answeredCount / totalCount;
}
