part of 'study_session_recall_viewmodel.dart';

typedef StudySessionRecallCursor = ({
  StudySessionReview review,
  int currentIndex,
});
typedef StudySessionRecallCountdown = ({
  bool isAnswerVisible,
  int countdownRemainingSeconds,
  bool revealedByTimeout,
});
typedef StudySessionRecallOperations = ({bool isSaving, bool isFinalizing});
typedef StudySessionRecallPersistence = ({
  Failure? saveFailure,
  Failure? finalizeFailure,
  bool didFinalizeSuccessfully,
});

class StudySessionRecallState {
  const StudySessionRecallState({
    required this.cursor,
    this.countdown = const (
      isAnswerVisible: false,
      countdownRemainingSeconds: DurationTokens.recallAnswerTimeoutSeconds,
      revealedByTimeout: false,
    ),
    this.operations = const (isSaving: false, isFinalizing: false),
    this.persistence = const (
      saveFailure: null,
      finalizeFailure: null,
      didFinalizeSuccessfully: false,
    ),
  });

  factory StudySessionRecallState.fromReview(StudySessionReview review) {
    final int firstUnansweredIndex = review.items.indexWhere(
      (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
    );
    return StudySessionRecallState(
      cursor: (
        review: review,
        currentIndex: firstUnansweredIndex == -1 ? 0 : firstUnansweredIndex,
      ),
    );
  }

  final StudySessionRecallCursor cursor;
  final StudySessionRecallCountdown countdown;
  final StudySessionRecallOperations operations;
  final StudySessionRecallPersistence persistence;

  StudySessionReview get review => cursor.review;

  int get currentIndex => cursor.currentIndex;

  bool get isAnswerVisible => countdown.isAnswerVisible;

  int get countdownRemainingSeconds => countdown.countdownRemainingSeconds;

  bool get revealedByTimeout => countdown.revealedByTimeout;

  bool get isSaving => operations.isSaving;

  bool get isFinalizing => operations.isFinalizing;

  Failure? get saveFailure => persistence.saveFailure;

  Failure? get finalizeFailure => persistence.finalizeFailure;

  bool get didFinalizeSuccessfully => persistence.didFinalizeSuccessfully;

  StudySessionReviewItem get currentItem => review.items[currentIndex];

  bool get isBusy => isSaving || isFinalizing;

  bool get currentItemAnswered => currentItem.sessionItem.answeredAt != null;

  bool get hasUnansweredItems => review.items.any(
    (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
  );

  bool get allAnswered => !hasUnansweredItems;

  bool get canRevealAnswer =>
      !isBusy && !isAnswerVisible && !currentItemAnswered && !allAnswered;

  bool get canGradeCurrentItem =>
      isAnswerVisible && !isBusy && !currentItemAnswered && !allAnswered;

  StudySessionRecallState revealAnswer({bool byTimeout = false}) => copyWith(
    isAnswerVisible: true,
    countdownRemainingSeconds: 0,
    revealedByTimeout: byTimeout,
    clearSaveFailure: true,
    clearFinalizeFailure: true,
  );

  StudySessionRecallState countdownTick() => countdownRemainingSeconds <= 1
      ? revealAnswer(byTimeout: true)
      : copyWith(
          countdownRemainingSeconds: countdownRemainingSeconds - 1,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        );

  StudySessionRecallState markAnswered({
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
      revealedByTimeout: false,
      countdownRemainingSeconds: DurationTokens.recallAnswerTimeoutSeconds,
      isSaving: false,
      isFinalizing: false,
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );
  }

  StudySessionRecallState copyWith({
    StudySessionReview? review,
    int? currentIndex,
    bool? isAnswerVisible,
    int? countdownRemainingSeconds,
    bool? revealedByTimeout,
    bool? isSaving,
    bool? isFinalizing,
    Failure? saveFailure,
    Failure? finalizeFailure,
    bool clearSaveFailure = false,
    bool clearFinalizeFailure = false,
    bool? didFinalizeSuccessfully,
  }) => StudySessionRecallState(
    cursor: (
      review: review ?? this.review,
      currentIndex: currentIndex ?? this.currentIndex,
    ),
    countdown: (
      isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
      countdownRemainingSeconds:
          countdownRemainingSeconds ?? this.countdownRemainingSeconds,
      revealedByTimeout: revealedByTimeout ?? this.revealedByTimeout,
    ),
    operations: (
      isSaving: isSaving ?? this.isSaving,
      isFinalizing: isFinalizing ?? this.isFinalizing,
    ),
    persistence: (
      saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
      finalizeFailure: clearFinalizeFailure
          ? null
          : finalizeFailure ?? this.finalizeFailure,
      didFinalizeSuccessfully:
          didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
    ),
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

class StudySessionRecallFailureException implements Exception {
  const StudySessionRecallFailureException(this.failure);

  final Failure failure;
}
