import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

part 'dashboard_resume_session_summary.freezed.dart';

/// The Dashboard "Continue studying" read model (WBS 5.1.1): the user's single
/// most recently active resumable session, with its scope and progress.
///
/// The FE resolves the scope's display name and renders a Continue CTA; the card
/// is hidden when there is no resumable session (the repository returns `null`).
/// See `docs/business/engagement/dashboard-engagement.md` +
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
  }) = _DashboardResumeSessionSummary;
  const DashboardResumeSessionSummary._();

  /// Fraction of items answered (0..1); 0 when the session has no items.
  double get progress => totalCount == 0 ? 0 : answeredCount / totalCount;
}
