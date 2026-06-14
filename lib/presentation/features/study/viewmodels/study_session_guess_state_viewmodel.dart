part of 'study_session_guess_viewmodel.dart';

typedef StudySessionGuessCursor = ({
  StudySessionReview review,
  int currentIndex,
});
typedef StudySessionGuessSelection = ({
  String? selectedOptionId,
  bool selectedOptionIsCorrect,
});
typedef StudySessionGuessCountdown = ({
  DateTime? countdownEndsAt,
  Duration? countdownDuration,
});
typedef StudySessionGuessOperations = ({bool isSaving, bool isFinalizing});
typedef StudySessionGuessPersistence = ({
  Failure? saveFailure,
  Failure? finalizeFailure,
  bool didFinalizeSuccessfully,
});

class StudySessionGuessState {
  const StudySessionGuessState({
    required this.cursor,
    required this.options,
    this.selection = const (
      selectedOptionId: null,
      selectedOptionIsCorrect: false,
    ),
    this.countdown = const (countdownEndsAt: null, countdownDuration: null),
    this.operations = const (isSaving: false, isFinalizing: false),
    this.persistence = const (
      saveFailure: null,
      finalizeFailure: null,
      didFinalizeSuccessfully: false,
    ),
  });

  factory StudySessionGuessState.fromReview({
    required StudySessionReview review,
    required List<GuessOption> options,
  }) {
    final int firstUnansweredIndex = _firstUnansweredIndex(review);
    final int currentIndex = firstUnansweredIndex == -1
        ? 0
        : firstUnansweredIndex;
    return StudySessionGuessState(
      cursor: (review: review, currentIndex: currentIndex),
      options: options,
    );
  }

  final StudySessionGuessCursor cursor;
  final List<GuessOption> options;
  final StudySessionGuessSelection selection;
  final StudySessionGuessCountdown countdown;
  final StudySessionGuessOperations operations;
  final StudySessionGuessPersistence persistence;

  StudySessionReview get review => cursor.review;

  int get currentIndex => cursor.currentIndex;

  String? get selectedOptionId => selection.selectedOptionId;

  bool get selectedOptionIsCorrect => selection.selectedOptionIsCorrect;

  DateTime? get countdownEndsAt => countdown.countdownEndsAt;

  Duration? get countdownDuration => countdown.countdownDuration;

  bool get isSaving => operations.isSaving;

  bool get isFinalizing => operations.isFinalizing;

  Failure? get saveFailure => persistence.saveFailure;

  Failure? get finalizeFailure => persistence.finalizeFailure;

  bool get didFinalizeSuccessfully => persistence.didFinalizeSuccessfully;

  StudySessionReviewItem get currentItem => review.items[currentIndex];

  GuessOption get correctOption =>
      options.firstWhere((GuessOption option) => option.isCorrect);

  bool get isBusy => isSaving || isFinalizing;

  bool get isCountdownActive => countdownEndsAt != null;

  bool get currentItemAnswered => currentItem.sessionItem.answeredAt != null;

  bool get hasUnansweredItems => review.items.any(
    (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
  );

  bool get allAnswered => !hasUnansweredItems;

  bool get canChooseCurrentItem =>
      !isBusy && !isCountdownActive && !currentItemAnswered;

  bool get didSelectOption => selectedOptionId != null;

  bool get isSelectionCorrect => didSelectOption && selectedOptionIsCorrect;

  bool get isSelectionWrong => didSelectOption && !selectedOptionIsCorrect;

  int get answeredCount => review.items
      .where(
        (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
      )
      .length;

  StudySessionGuessState copyWith({
    StudySessionReview? review,
    int? currentIndex,
    List<GuessOption>? options,
    String? selectedOptionId,
    bool clearSelectedOptionId = false,
    bool? selectedOptionIsCorrect,
    DateTime? countdownEndsAt,
    bool clearCountdownEndsAt = false,
    Duration? countdownDuration,
    bool clearCountdownDuration = false,
    bool? isSaving,
    bool? isFinalizing,
    Failure? saveFailure,
    Failure? finalizeFailure,
    bool clearSaveFailure = false,
    bool clearFinalizeFailure = false,
    bool? didFinalizeSuccessfully,
  }) => StudySessionGuessState(
    cursor: (
      review: review ?? this.review,
      currentIndex: currentIndex ?? this.currentIndex,
    ),
    options: options ?? this.options,
    selection: (
      selectedOptionId: clearSelectedOptionId
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      selectedOptionIsCorrect:
          selectedOptionIsCorrect ?? this.selectedOptionIsCorrect,
    ),
    countdown: (
      countdownEndsAt: clearCountdownEndsAt
          ? null
          : countdownEndsAt ?? this.countdownEndsAt,
      countdownDuration: clearCountdownDuration
          ? null
          : countdownDuration ?? this.countdownDuration,
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

  static int _firstUnansweredIndex(StudySessionReview review) {
    for (int index = 0; index < review.items.length; index++) {
      if (review.items[index].sessionItem.answeredAt == null) {
        return index;
      }
    }
    return -1;
  }
}

class StudySessionGuessFailureException implements Exception {
  const StudySessionGuessFailureException(this.failure);

  final Failure failure;
}
