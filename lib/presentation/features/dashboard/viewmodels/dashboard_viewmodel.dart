import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
Future<DashboardResumeSessionSummary?> dashboardResumeSessionQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardResumeSessionSummaryUseCaseProvider);
  return useCase.call().then(
    (Result<DashboardResumeSessionSummary?> result) =>
        result.fold((Failure failure) {
          // ignore: only_throw_errors
          throw failure;
        }, (DashboardResumeSessionSummary? summary) => summary),
  );
}

/// Dashboard action controller — keeps the screen free of repository calls.
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  FutureOr<void> build() {}

  Future<Result<void>> discardSession(SessionId sessionId) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(cancelStudySessionUseCaseProvider)
        .call(sessionId: sessionId);
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (void _) => const AsyncValue<void>.data(null),
    );
    return result;
  }
}
