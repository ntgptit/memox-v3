import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

@riverpod
Future<DashboardResumeSessionSummary?> dashboardResumeSessionQuery(Ref ref) {
  final useCase = ref.watch(loadDashboardResumeSessionSummaryUseCaseProvider);
  return useCase.call().then(
    (Result<DashboardResumeSessionSummary?> result) => result.fold((
      Failure failure,
    ) {
      // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
      throw failure;
    }, (DashboardResumeSessionSummary? summary) => summary),
  );
}
