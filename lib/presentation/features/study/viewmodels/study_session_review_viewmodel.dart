import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_review_viewmodel.g.dart';

@riverpod
class StudySessionReviewController extends _$StudySessionReviewController {
  late final StudyModeStrategy _studyModeStrategy;

  /// When the current card was last shown, used to measure time-on-card for the
  /// attempt's `duration_ms` (Card History timeline). Reset on every card change.
  DateTime _currentShownAt = DateTime.now();

  void _markCurrentShown() => _currentShownAt = DateTime.now();

  @override
  Future<StudySessionReviewState> build(SessionId sessionId) async {
    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: sessionId);

    if (result case Ok<StudySessionReview>(:final value)) {
      _studyModeStrategy = StudyModeStrategyFactory.resolve();
      _markCurrentShown();
      return StudySessionReviewState.fromReview(value);
    }
    final Err<StudySessionReview> err = result as Err<StudySessionReview>;
    throw StudySessionFailureException(err.failure);
  }

  void toggleAnswer() => _updateCurrentState(
    (StudySessionReviewState state) => state.toggleAnswer(),
  );

  void previous() {
    _updateCurrentState((StudySessionReviewState state) => state.previous());
    _markCurrentShown();
  }

  void next() {
    _updateCurrentState((StudySessionReviewState state) => state.next());
    _markCurrentShown();
  }

  Future<void> gradeForgot() => _recordAnswer(
    (BinaryGradeStudyModeStrategy strategy) => strategy.mapForgotAction(),
  );

  Future<void> gradeGotIt() => _recordAnswer(
    (BinaryGradeStudyModeStrategy strategy) => strategy.mapGotItAction(),
  );

  Future<bool> finishSession() async {
    final StudySessionReviewState? current = switch (state) {
      AsyncData<StudySessionReviewState>(:final value) => value,
      _ => null,
    };
    if (current == null || current.isBusy || !current.allAnswered) {
      return false;
    }

    state = AsyncData(
      current.copyWith(isFinalizing: true, clearFinalizeFailure: true),
    );

    final Result<void> finalizeResult = await ref
        .read(finalizeStudySessionUseCaseProvider)
        .call(sessionId: current.review.session.id);

    switch (finalizeResult) {
      case Ok<void>():
        state = AsyncData(
          current.copyWith(isFinalizing: false, clearFinalizeFailure: true),
        );
        return true;
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isFinalizing: false, finalizeFailure: failure),
        );
        return false;
    }
  }

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

  Future<void> _recordAnswer(
    AttemptResult Function(BinaryGradeStudyModeStrategy strategy) mapResult,
  ) async {
    final StudySessionReviewState? current = switch (state) {
      AsyncData<StudySessionReviewState>(:final value) => value,
      _ => null,
    };
    if (current == null || current.isSaving || !current.canGradeCurrentItem) {
      return;
    }

    final StudySessionReviewItem item = current.currentItem;
    // This screen only handles the V1 reveal/self-grade flow. The type check
    // is what allows calling the binary-grade mapping at all (Fill/Match
    // strategies no longer expose it), and the flag keeps review/guess on
    // their own future flows even though they are binary-grade too.
    final StudyModeStrategy strategy = _studyModeStrategy;
    if (strategy is! BinaryGradeStudyModeStrategy ||
        !strategy.usesRevealSelfGradeFlow) {
      return;
    }
    final AttemptResult result = mapResult(strategy);
    state = AsyncData(
      current.copyWith(
        isSaving: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );

    final int elapsedMs = DateTime.now()
        .difference(_currentShownAt)
        .inMilliseconds;
    final Result<void> recordResult = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: current.review.session.id,
          sessionItemId: item.sessionItem.id,
          result: result,
          studyMode: _studyModeStrategy.mode,
          durationMs: elapsedMs >= 0 ? elapsedMs : null,
        );

    switch (recordResult) {
      case Ok<void>():
        final DateTime answeredAt = DateTime.now().toUtc();
        _markCurrentShown();
        state = AsyncData(
          current.markAnswered(
            sessionItemId: item.sessionItem.id,
            answeredAt: answeredAt,
          ),
        );
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isSaving: false, saveFailure: failure),
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
