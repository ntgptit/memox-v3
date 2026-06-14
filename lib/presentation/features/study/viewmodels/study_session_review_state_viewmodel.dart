part of 'study_session_review_viewmodel.dart';

class StudySessionReviewState {
  const StudySessionReviewState({
    required this.review,
    required this.currentIndex,
    this.isAnswerVisible = false,
    this.isSaving = false,
    this.isFinalizing = false,
    this.saveFailure,
    this.finalizeFailure,
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
  final bool isFinalizing;
  final Failure? saveFailure;
  final Failure? finalizeFailure;

  StudySessionReviewItem get currentItem => review.items[currentIndex];

  bool get isBusy => isSaving || isFinalizing;

  bool get canGoPrevious => currentIndex > 0 && !isBusy;

  bool get canGoNext => currentIndex < review.items.length - 1 && !isBusy;

  bool get currentItemAnswered => currentItem.sessionItem.answeredAt != null;

  bool get hasUnansweredItems => review.items.any(
    (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
  );

  bool get allAnswered => !hasUnansweredItems;

  bool get canGradeCurrentItem =>
      isAnswerVisible && !isBusy && !currentItemAnswered && !allAnswered;

  StudySessionReviewState toggleAnswer() => copyWith(
    isAnswerVisible: !isAnswerVisible,
    clearSaveFailure: true,
    clearFinalizeFailure: true,
  );

  StudySessionReviewState previous() => currentIndex == 0 || isBusy
      ? this
      : copyWith(
          currentIndex: currentIndex - 1,
          isAnswerVisible: false,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        );

  StudySessionReviewState next() =>
      currentIndex >= review.items.length - 1 || isBusy
      ? this
      : copyWith(
          currentIndex: currentIndex + 1,
          isAnswerVisible: false,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        );

  StudySessionReviewState markAnswered({
    required String sessionItemId,
    required DateTime answeredAt,
  }) {
    final List<StudySessionReviewItem> updatedItems = review.items
        .map(
          (StudySessionReviewItem item) => item.sessionItem.id == sessionItemId
              ? item.copyWith(
                  sessionItem: item.sessionItem.copyWith(
                    answeredAt: answeredAt,
                  ),
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
      isFinalizing: false,
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );
  }

  StudySessionReviewState copyWith({
    StudySessionReview? review,
    int? currentIndex,
    bool? isAnswerVisible,
    bool? isSaving,
    bool? isFinalizing,
    Failure? saveFailure,
    Failure? finalizeFailure,
    bool clearSaveFailure = false,
    bool clearFinalizeFailure = false,
  }) => StudySessionReviewState(
    review: review ?? this.review,
    currentIndex: currentIndex ?? this.currentIndex,
    isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
    isSaving: isSaving ?? this.isSaving,
    isFinalizing: isFinalizing ?? this.isFinalizing,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    finalizeFailure: clearFinalizeFailure
        ? null
        : finalizeFailure ?? this.finalizeFailure,
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
