part of 'study_session_fill_viewmodel.dart';

typedef StudySessionFillCursor = ({
  StudySessionReview review,
  int currentIndex,
});
typedef StudySessionFillDraft = ({String inputText, int hintReveals});
typedef StudySessionFillFeedback = ({
  AttemptResult? feedbackResult,
  bool feedbackCommitted,
  bool retryUsed,
});
typedef StudySessionFillOperations = ({
  bool isChecking,
  bool isSaving,
  bool isFinalizing,
});
typedef StudySessionFillPersistence = ({
  Failure? saveFailure,
  Failure? finalizeFailure,
  bool didFinalizeSuccessfully,
});

class StudySessionFillState {
  const StudySessionFillState({
    required this.cursor,
    this.draft = const (inputText: '', hintReveals: 0),
    this.feedback = const (
      feedbackResult: null,
      feedbackCommitted: false,
      retryUsed: false,
    ),
    this.operations = const (
      isChecking: false,
      isSaving: false,
      isFinalizing: false,
    ),
    this.readyToFinish = false,
    this.persistence = const (
      saveFailure: null,
      finalizeFailure: null,
      didFinalizeSuccessfully: false,
    ),
  });

  factory StudySessionFillState.fromReview(
    StudySessionReview review, {
    required int currentIndex,
  }) {
    final bool allAnswered = review.items.every(
      (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
    );
    return StudySessionFillState(
      cursor: (review: review, currentIndex: currentIndex),
      readyToFinish: allAnswered,
    );
  }

  final StudySessionFillCursor cursor;
  final StudySessionFillDraft draft;
  final StudySessionFillFeedback feedback;
  final StudySessionFillOperations operations;
  final bool readyToFinish;
  final StudySessionFillPersistence persistence;

  StudySessionReview get review => cursor.review;

  int get currentIndex => cursor.currentIndex;

  String get inputText => draft.inputText;

  int get hintReveals => draft.hintReveals;

  AttemptResult? get feedbackResult => feedback.feedbackResult;

  bool get feedbackCommitted => feedback.feedbackCommitted;

  bool get retryUsed => feedback.retryUsed;

  bool get isChecking => operations.isChecking;

  bool get isSaving => operations.isSaving;

  bool get isFinalizing => operations.isFinalizing;

  Failure? get saveFailure => persistence.saveFailure;

  Failure? get finalizeFailure => persistence.finalizeFailure;

  bool get didFinalizeSuccessfully => persistence.didFinalizeSuccessfully;

  StudySessionReviewItem get currentItem => review.items[currentIndex];

  bool get isBusy => isChecking || isSaving || isFinalizing;

  bool get currentItemAnswered => currentItem.sessionItem.answeredAt != null;

  bool get hasUnansweredItems => review.items.any(
    (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
  );

  bool get allAnswered => !hasUnansweredItems;

  bool get isTyping => feedbackResult == null && !readyToFinish;

  bool get isFeedbackVisible => feedbackResult != null;

  bool get isCorrectFeedback =>
      feedbackResult == AttemptResult.perfect ||
      feedbackResult == AttemptResult.recovered;

  bool get isWrongFeedback => feedbackResult == AttemptResult.forgot;

  bool get isWrongFeedbackTerminal => isWrongFeedback && feedbackCommitted;

  bool get canCheckCurrentItem =>
      isTyping &&
      !isBusy &&
      StringUtils.trimmed(inputText).isNotEmpty &&
      !currentItemAnswered;

  bool get canRevealHint =>
      isTyping &&
      !isBusy &&
      !currentItemAnswered &&
      hintReveals < maxHintReveals;

  bool get canRetryCurrentItem =>
      isWrongFeedback && !feedbackCommitted && !retryUsed && !isBusy;

  bool get canMarkCorrect => isWrongFeedback && !feedbackCommitted && !isBusy;

  bool get canAdvance => feedbackCommitted && !isBusy && !readyToFinish;

  bool get canFinish =>
      (readyToFinish || allAnswered) && !isBusy && !didFinalizeSuccessfully;

  bool get showSpeakAction => isFeedbackVisible;

  bool get hasHint => hintReveals > 0;

  int get answeredCount => review.items
      .where(
        (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
      )
      .length;

  int get maxHintReveals => currentItem.flashcard.front.runes.length ~/ 2;

  String get hintedFront =>
      String.fromCharCodes(currentItem.flashcard.front.runes.take(hintReveals));

  StudySessionFillState markAnswered({
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
    return copyWith(
      review: review.copyWith(items: updatedItems),
      isSaving: false,
      isChecking: false,
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );
  }

  StudySessionFillState copyWith({
    StudySessionReview? review,
    int? currentIndex,
    String? inputText,
    int? hintReveals,
    AttemptResult? feedbackResult,
    bool clearFeedbackResult = false,
    bool? feedbackCommitted,
    bool? retryUsed,
    bool? isChecking,
    bool? isSaving,
    bool? isFinalizing,
    bool? readyToFinish,
    Failure? saveFailure,
    Failure? finalizeFailure,
    bool clearSaveFailure = false,
    bool clearFinalizeFailure = false,
    bool? didFinalizeSuccessfully,
  }) => StudySessionFillState(
    cursor: (
      review: review ?? this.review,
      currentIndex: currentIndex ?? this.currentIndex,
    ),
    draft: (
      inputText: inputText ?? this.inputText,
      hintReveals: hintReveals ?? this.hintReveals,
    ),
    feedback: (
      feedbackResult: clearFeedbackResult
          ? null
          : feedbackResult ?? this.feedbackResult,
      feedbackCommitted: feedbackCommitted ?? this.feedbackCommitted,
      retryUsed: retryUsed ?? this.retryUsed,
    ),
    operations: (
      isChecking: isChecking ?? this.isChecking,
      isSaving: isSaving ?? this.isSaving,
      isFinalizing: isFinalizing ?? this.isFinalizing,
    ),
    readyToFinish: readyToFinish ?? this.readyToFinish,
    persistence: (
      saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
      finalizeFailure: clearFinalizeFailure
          ? null
          : finalizeFailure ?? this.finalizeFailure,
      didFinalizeSuccessfully:
          didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
    ),
  );
}

class StudySessionFillFailureException implements Exception {
  const StudySessionFillFailureException(this.failure);

  final Failure failure;
}
