import 'dart:async';

import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_viewmodel.g.dart';

/// Selected range tab (Week / Month / All time) for the Progress screen.
@riverpod
class ProgressRangeController extends _$ProgressRangeController {
  @override
  ProgressRange build() => ProgressRange.week;

  void select(ProgressRange range) => state = range;
}

/// Loads the [ProgressOverview] for the currently selected range.
@riverpod
Future<ProgressOverview> progressOverviewQuery(Ref ref) {
  final ProgressRange range = ref.watch(progressRangeControllerProvider);
  final useCase = ref.watch(loadProgressOverviewUseCaseProvider);
  return useCase
      .call(now: DateTime.now().toUtc(), range: range)
      .then(
        (Result<ProgressOverview> result) => result.fold((Failure failure) {
          // ignore: only_throw_errors -- reason: Riverpod query must surface repository Failure as AsyncError.
          throw failure;
        }, (ProgressOverview overview) => overview),
      );
}
