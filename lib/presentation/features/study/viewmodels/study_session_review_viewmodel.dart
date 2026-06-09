import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_review_viewmodel.g.dart';

@riverpod
class StudySessionReviewController extends _$StudySessionReviewController {
  @override
  Future<StudySessionReviewState> build(SessionId sessionId) async {
    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: sessionId);

    return switch (result) {
      Ok<StudySessionReview>(:final value) =>
        StudySessionReviewState.fromReview(value),
      Err<StudySessionReview>(:final failure) =>
        throw StudySessionFailureException(failure),
    };
  }

  void toggleAnswer() => _updateCurrentState(
    (StudySessionReviewState state) => state.toggleAnswer(),
  );

  void previous() => _updateCurrentState(
    (StudySessionReviewState state) => state.previous(),
  );

  void next() => _updateCurrentState(
    (StudySessionReviewState state) => state.next(),
  );

  Future<void> gradeForgot() => _recordAnswer(AttemptResult.forgot);

  Future<void> gradeGotIt() => _recordAnswer(AttemptResult.perfect);

  void _updateCurrentState(
    StudySessionReviewState Function(StudySessionReviewState state) mutate,
  ) {
    final StudySessionReviewState? current = switch (state) {
      AsyncData<StudySessionReviewState>(:final value) => value,
      _ => null,
    };
    if (current == null) {
      return;
    }
    state = AsyncData(mutate(current));
  }

  Future<void> _recordAnswer(AttemptResult result) async {
    final StudySessionReviewState? current = switch (state) {
      AsyncData<StudySessionReviewState>(:final value) => value,
      _ => null,
    };
    if (current == null || current.isSaving || !current.canGradeCurrentItem) {
      return;
    }

    final StudySessionReviewItem item = current.currentItem;
    state = AsyncData(
      current.copyWith(isSaving: true, clearSaveFailure: true),
    );

    final Result<void> recordResult = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: current.review.session.id,
          sessionItemId: item.sessionItem.id,
          result: result,
          studyMode: StudyMode.recall,
        );

    switch (recordResult) {
      case Ok<void>():
        final DateTime answeredAt = DateTime.now().toUtc();
        state = AsyncData(
          current.markAnswered(
            sessionItemId: item.sessionItem.id,
            answeredAt: answeredAt,
          ),
        );
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(
            isSaving: false,
            saveFailure: failure,
          ),
        );
    }
  }
}

class StudySessionReviewState {
  const StudySessionReviewState({
    required this.review,
    required this.currentIndex,
    this.isAnswerVisible = false,
    this.isSaving = false,
    this.saveFailure,
  });

  factory StudySessionReviewState.fromReview(StudySessionReview review) {
    final int firstUnansweredIndex = review.items.indexWhere(
      (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
    );
    return StudySessionReviewState(
      review: review,
      currentIndex: firstUnansweredIndex == -1 ? 0 : firstUnansweredIndex,
    );
  }

  final StudySessionReview review;
  final int currentIndex;
  final bool isAnswerVisible;
  final bool isSaving;
  final Failure? saveFailure;

  StudySessionReviewItem get currentItem => review.items[currentIndex];

  bool get canGoPrevious => currentIndex > 0 && !isSaving;

  bool get canGoNext =>
      currentIndex < review.items.length - 1 && !isSaving;

  bool get currentItemAnswered => currentItem.sessionItem.answeredAt != null;

  bool get hasUnansweredItems => review.items.any(
    (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
  );

  bool get allAnswered => !hasUnansweredItems;

  bool get canGradeCurrentItem =>
      isAnswerVisible && !isSaving && !currentItemAnswered && !allAnswered;

  StudySessionReviewState toggleAnswer() => copyWith(
    isAnswerVisible: !isAnswerVisible,
    clearSaveFailure: true,
  );

  StudySessionReviewState previous() => currentIndex == 0 || isSaving
      ? this
      : copyWith(
          currentIndex: currentIndex - 1,
          isAnswerVisible: false,
          clearSaveFailure: true,
        );

  StudySessionReviewState next() => currentIndex >= review.items.length - 1 || isSaving
      ? this
      : copyWith(
          currentIndex: currentIndex + 1,
          isAnswerVisible: false,
          clearSaveFailure: true,
        );

  StudySessionReviewState markAnswered({
    required String sessionItemId,
    required DateTime answeredAt,
  }) {
    final List<StudySessionReviewItem> updatedItems = review.items
        .map(
          (StudySessionReviewItem item) => item.sessionItem.id == sessionItemId
              ? item.copyWith(
                  sessionItem: item.sessionItem.copyWith(answeredAt: answeredAt),
                )
              : item,
        )
        .toList(growable: false);
    final int? nextUnansweredIndex = _nextUnansweredIndex(
      updatedItems,
      startIndex: currentIndex + 1,
    );
    return copyWith(
      review: review.copyWith(items: updatedItems),
      currentIndex: nextUnansweredIndex ?? currentIndex,
      isAnswerVisible: false,
      isSaving: false,
      clearSaveFailure: true,
    );
  }

  StudySessionReviewState copyWith({
    StudySessionReview? review,
    int? currentIndex,
    bool? isAnswerVisible,
    bool? isSaving,
    Failure? saveFailure,
    bool clearSaveFailure = false,
  }) => StudySessionReviewState(
    review: review ?? this.review,
    currentIndex: currentIndex ?? this.currentIndex,
    isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
    isSaving: isSaving ?? this.isSaving,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
  );

  int? _nextUnansweredIndex(
    List<StudySessionReviewItem> items, {
    required int startIndex,
  }) {
    for (int index = startIndex; index < items.length; index++) {
      if (items[index].sessionItem.answeredAt == null) {
        return index;
      }
    }
    return null;
  }
}

class StudySessionFailureException implements Exception {
  const StudySessionFailureException(this.failure);

  final Failure failure;
}
