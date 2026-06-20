import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';

/// Loads the Dashboard "Continue studying" summary (WBS 5.1.1).
///
/// Owns the `now` clock (epoch ms) used for the 30-day resume window so the
/// repository stays clock-free. Returns `null` data when there is no resumable
/// session (the FE hides the Continue card); failures propagate as
/// `StorageFailure(read)`.
class LoadDashboardResumeSummaryUseCase {
  const LoadDashboardResumeSummaryUseCase({required this.repository});

  final DashboardRepository repository;

  Future<Result<DashboardResumeSessionSummary?>> call() => repository
      .loadResumeSessionSummary(now: DateTime.now().millisecondsSinceEpoch);
}
