import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';

part 'study_session_review.freezed.dart';

/// Persisted study-session review read model.
///
/// Carries the loaded [session] header and its ordered [items], each with the
/// joined flashcard content the review screen needs to render the first card.
@freezed
abstract class StudySessionReview with _$StudySessionReview {
  const factory StudySessionReview({
    required StudySession session,
    required List<StudySessionReviewItem> items,
  }) = _StudySessionReview;
}

/// One queued session item plus its joined flashcard content.
@freezed
abstract class StudySessionReviewItem with _$StudySessionReviewItem {
  const factory StudySessionReviewItem({
    required StudySessionItem sessionItem,
    required Flashcard flashcard,
  }) = _StudySessionReviewItem;
}
