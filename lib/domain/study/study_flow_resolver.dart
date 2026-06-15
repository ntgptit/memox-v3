import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';

/// Resolves the [StudyFlow] (phase plan) for a session being created.
///
/// Single place that maps `(studyType, requested mode) → StudyFlow`
/// (`docs/business/study/study-flow.md` §Entry to flow resolution):
///
/// - SRS review → `srs_fill_review` only when fill is explicitly requested,
///   otherwise the adopted `srs_recall_review` default.
/// - New cards with no explicit mode → `new_full_cycle` (the chained
///   review → match → guess → recall → fill learning cycle).
/// - New cards with an explicit mode → the matching `new_*_only` targeted flow.
abstract final class StudyFlowResolver {
  StudyFlowResolver._();

  static StudyFlow resolve({required StudyType studyType, StudyMode? mode}) {
    if (studyType == StudyType.srsReview) {
      return mode == StudyMode.fill
          ? StudyFlow.srsFillReview
          : StudyFlow.srsRecallReview;
    }
    return switch (mode) {
      null => StudyFlow.newFullCycle,
      StudyMode.review => StudyFlow.newReviewOnly,
      StudyMode.match => StudyFlow.newMatchOnly,
      StudyMode.guess => StudyFlow.newGuessOnly,
      StudyMode.recall => StudyFlow.newRecallOnly,
      StudyMode.fill => StudyFlow.newFillOnly,
    };
  }
}
