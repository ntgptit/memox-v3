import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/study_statistics.dart';

part 'progress_read_model.freezed.dart';

/// The composed Progress-screen read model (WBS 7.4.1): the due summary
/// (WBS 7.1.1), the Leitner box distribution (WBS 7.2.1), and the
/// session/attempt statistics (WBS 7.3.1) loaded together in one call
/// (`docs/decision-tables/progress-history.md` P11). An empty database yields a
/// model whose parts are all zero-safe.
@freezed
sealed class ProgressReadModel with _$ProgressReadModel {
  const factory ProgressReadModel({
    required DueSummary dueSummary,
    required BoxDistribution boxDistribution,
    required StudyStatistics statistics,
  }) = _ProgressReadModel;
}
