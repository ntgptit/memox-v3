import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/fill/fill_answer_evaluator.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_fill_viewmodel.g.dart';

@riverpod
class StudySessionFillController extends _$StudySessionFillController {
  late final TypedAnswerStudyModeStrategy _fillStrategy;

  Timer? _advanceTimer;
  DateTime _currentShownAt = DateTime.now();

  void _markCurrentShown() => _currentShownAt = DateTime.now();

  @override
  Future<StudySessionFillState> build(
    ({SessionId sessionId, StudyMode? studyMode}) request,
  ) async {
    ref.onDispose(_cancelAdvanceTimer);

    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: request.sessionId);

    final StudySessionReview review = switch (result) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>(:final failure) =>
        throw StudySessionFillFailureException(failure),
    };

    final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
      studyMode: request.studyMode,
    );
    if (strategy is! TypedAnswerStudyModeStrategy ||
        strategy.mode != StudyMode.fill) {
      throw const StudySessionFillFailureException(
        Failure.unsupportedAction(action: 'fill_mode'),
      );
    }

    _fillStrategy = strategy;
    _markCurrentShown();

    final StudySessionFillState initialState = StudySessionFillState.fromReview(
      review,
      currentIndex: _firstAvailableUnansweredIndex(review) ?? 0,
    );
    return _resolveUnavailableCurrentItem(initialState);
  }

  void setFillInputText(String value) {
    final StudySessionFillState? current = _currentState;
    if (current == null || current.isBusy || current.isFeedbackVisible) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        inputText: value,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );
  }

  void revealHint() {
    final StudySessionFillState? current = _currentState;
    if (current == null || current.isBusy || !current.canRevealHint) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        hintReveals: current.hintReveals + 1,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );
  }

  Future<void> checkAnswer() async {
    final StudySessionFillState? current = _currentState;
    if (current == null || !current.canCheckCurrentItem) {
      return;
    }

    final FillAnswerEvaluation evaluation = _fillStrategy.evaluateAnswer(
      typedInput: current.inputText,
      expectedFront: current.currentItem.flashcard.front,
      hintUsed: current.hintReveals > 0,
    );

    state = AsyncData(
      current.copyWith(
        isChecking: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );

    if (evaluation.result == AttemptResult.forgot && !current.retryUsed) {
      state = AsyncData(
        current.copyWith(
          isChecking: false,
          feedbackResult: AttemptResult.forgot,
          feedbackCommitted: false,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        ),
      );
      return;
    }

    await _commitCurrentAnswer(
      current: current.copyWith(isChecking: false),
      result: evaluation.result,
      committedFeedback: evaluation.result,
      autoAdvance: evaluation.result != AttemptResult.forgot,
    );
  }

  Future<void> markCorrect() async {
    final StudySessionFillState? current = _currentState;
    if (current == null || !current.canMarkCorrect) {
      return;
    }

    await _commitCurrentAnswer(
      current: current,
      result: AttemptResult.recovered,
      committedFeedback: AttemptResult.recovered,
      autoAdvance: true,
      overrideApplied: true,
    );
  }

  void tryAgain() {
    final StudySessionFillState? current = _currentState;
    if (current == null || !current.canRetryCurrentItem) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        inputText: '',
        feedbackResult: null,
        clearFeedbackResult: true,
        feedbackCommitted: false,
        retryUsed: true,
        isChecking: false,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );
  }

  void next() {
    final StudySessionFillState? current = _currentState;
    if (current == null || current.isBusy || !current.canAdvance) {
      return;
    }

    _cancelAdvanceTimer();
    unawaited(_advanceAfterFeedback(current));
  }

  Future<void> finishSession() async {
    final StudySessionFillState? current = _currentState;
    if (current == null ||
        current.isBusy ||
        !(current.readyToFinish || current.allAnswered)) {
      return;
    }

    await _finalizeCurrentSession(current);
  }

  Future<void> refreshReview() async {
    final StudySessionFillState? current = _currentState;
    if (current == null) {
      return;
    }

    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: current.review.session.id);

    final StudySessionReview? refreshedReview = switch (result) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>() => null,
    };
    if (refreshedReview == null) {
      return;
    }

    final String currentItemId = current.currentItem.sessionItem.id;
    final int currentIndex = _currentIndexForRefresh(
      refreshedReview,
      currentItemId,
      fallbackIndex: current.currentIndex,
    );
    final bool sameCard =
        currentIndex != -1 &&
        currentIndex < refreshedReview.items.length &&
        refreshedReview.items[currentIndex].sessionItem.id == currentItemId;
    final StudySessionFillState refreshedState = current.copyWith(
      review: refreshedReview,
      currentIndex: currentIndex == -1 ? current.currentIndex : currentIndex,
      inputText: sameCard ? current.inputText : '',
      hintReveals: sameCard ? current.hintReveals : 0,
      feedbackResult: sameCard ? current.feedbackResult : null,
      clearFeedbackResult: !sameCard,
      feedbackCommitted: sameCard ? current.feedbackCommitted : false,
      retryUsed: sameCard ? current.retryUsed : false,
      readyToFinish: refreshedReview.items.every(
        (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
      ),
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );

    _cancelAdvanceTimer();
    state = AsyncData(_resolveUnavailableCurrentItem(refreshedState));
    _markCurrentShown();
    _syncTimerIfNeeded();
  }

  void pauseAdvance() {
    _cancelAdvanceTimer();
  }

  void resumeAdvance() {
    final StudySessionFillState? current = _currentState;
    if (current == null || current.isBusy || !current.feedbackCommitted) {
      return;
    }
    if (current.readyToFinish || current.isWrongFeedbackTerminal) {
      return;
    }
    _scheduleAdvance(current);
  }

  StudySessionFillState? get _currentState => switch (state) {
    AsyncData<StudySessionFillState>(:final value) => value,
    _ => null,
  };

  Future<void> _commitCurrentAnswer({
    required StudySessionFillState current,
    required AttemptResult result,
    required AttemptResult committedFeedback,
    required bool autoAdvance,
    bool overrideApplied = false,
  }) async {
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
          sessionItemId: current.currentItem.sessionItem.id,
          result: result,
          studyMode: _fillStrategy.mode,
          durationMs: elapsedMs >= 0 ? elapsedMs : null,
        );

    switch (recordResult) {
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(
            isSaving: false,
            isChecking: false,
            saveFailure: failure,
          ),
        );
        return;
      case Ok<void>():
        final DateTime answeredAt = DateTime.now().toUtc();
        final StudySessionFillState answeredState = current
            .markAnswered(
              sessionItemId: current.currentItem.sessionItem.id,
              answeredAt: answeredAt,
            )
            .copyWith(
              inputText: current.inputText,
              hintReveals: current.hintReveals,
              feedbackResult: committedFeedback,
              feedbackCommitted: true,
              retryUsed: current.retryUsed,
              isSaving: false,
              isChecking: false,
              clearSaveFailure: true,
              clearFinalizeFailure: true,
              readyToFinish: !autoAdvance && current.allAnswered,
            );
        state = AsyncData(answeredState);
        _markCurrentShown();
        if (autoAdvance) {
          _scheduleAdvance(answeredState);
        }
    }
  }

  Future<void> _advanceAfterFeedback(StudySessionFillState current) async {
    if (!current.feedbackCommitted || current.isBusy) {
      return;
    }

    final int nextIndex = _nextAvailableUnansweredIndex(
      current.review.items,
      startIndex: current.currentIndex + 1,
    );
    if (nextIndex == -1) {
      state = AsyncData(
        current.copyWith(
          readyToFinish: true,
          isSaving: false,
          isChecking: false,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        ),
      );
      _markCurrentShown();
      return;
    }

    final StudySessionFillState nextState = current.copyWith(
      currentIndex: nextIndex,
      inputText: '',
      hintReveals: 0,
      feedbackResult: null,
      clearFeedbackResult: true,
      feedbackCommitted: false,
      retryUsed: false,
      isSaving: false,
      isChecking: false,
      readyToFinish: false,
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );
    state = AsyncData(_resolveUnavailableCurrentItem(nextState));
    _markCurrentShown();
  }

  Future<void> _finalizeCurrentSession(StudySessionFillState current) async {
    if (current.didFinalizeSuccessfully) {
      return;
    }

    _cancelAdvanceTimer();
    state = AsyncData(
      current.copyWith(
        isFinalizing: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );

    final Result<void> finalizeResult = await ref
        .read(finalizeStudySessionUseCaseProvider)
        .call(sessionId: current.review.session.id);

    switch (finalizeResult) {
      case Ok<void>():
        state = AsyncData(
          current.copyWith(
            isFinalizing: false,
            didFinalizeSuccessfully: true,
            clearSaveFailure: true,
            clearFinalizeFailure: true,
          ),
        );
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isFinalizing: false, finalizeFailure: failure),
        );
    }
  }

  void _scheduleAdvance(StudySessionFillState current) {
    _cancelAdvanceTimer();
    _advanceTimer = Timer(DurationTokens.guessCorrectCountdown, () {
      final StudySessionFillState? latest = _currentState;
      if (latest == null || latest.isBusy || !latest.feedbackCommitted) {
        return;
      }
      unawaited(_advanceAfterFeedback(latest));
    });
  }

  void _syncTimerIfNeeded() {
    final StudySessionFillState? current = _currentState;
    if (current == null ||
        !current.feedbackCommitted ||
        current.readyToFinish) {
      return;
    }
    if (current.isCorrectFeedback) {
      _scheduleAdvance(current);
    }
  }

  StudySessionFillState _resolveUnavailableCurrentItem(
    StudySessionFillState state,
  ) {
    final int nextAvailableIndex = _nextAvailableUnansweredIndex(
      state.review.items,
      startIndex: state.currentIndex,
    );
    if (nextAvailableIndex == -1 || nextAvailableIndex == state.currentIndex) {
      return state;
    }

    return state.copyWith(
      currentIndex: nextAvailableIndex,
      inputText: '',
      hintReveals: 0,
      feedbackResult: null,
      clearFeedbackResult: true,
      feedbackCommitted: false,
      retryUsed: false,
      readyToFinish: false,
      clearSaveFailure: true,
      clearFinalizeFailure: true,
    );
  }

  int _currentIndexForRefresh(
    StudySessionReview review,
    String currentItemId, {
    required int fallbackIndex,
  }) {
    final int index = review.items.indexWhere(
      (StudySessionReviewItem item) => item.sessionItem.id == currentItemId,
    );
    if (index != -1) {
      return index;
    }

    if (review.items.isEmpty) {
      return 0;
    }

    final int clampedFallback = fallbackIndex.clamp(0, review.items.length - 1);
    return _nextAvailableUnansweredIndex(
              review.items,
              startIndex: clampedFallback,
            ) ==
            -1
        ? clampedFallback
        : _nextAvailableUnansweredIndex(
            review.items,
            startIndex: clampedFallback,
          );
  }

  int? _firstAvailableUnansweredIndex(StudySessionReview review) {
    for (int index = 0; index < review.items.length; index++) {
      final StudySessionReviewItem item = review.items[index];
      if (item.sessionItem.answeredAt != null) {
        continue;
      }
      if (_fillStrategy.isAvailable(item.flashcard.front)) {
        return index;
      }
    }
    for (int index = 0; index < review.items.length; index++) {
      if (review.items[index].sessionItem.answeredAt == null) {
        return index;
      }
    }
    return null;
  }

  int _nextAvailableUnansweredIndex(
    List<StudySessionReviewItem> items, {
    required int startIndex,
  }) {
    if (startIndex < 0) {
      return -1;
    }
    for (int index = startIndex; index < items.length; index++) {
      final StudySessionReviewItem item = items[index];
      if (item.sessionItem.answeredAt != null) {
        continue;
      }
      if (_fillStrategy.isAvailable(item.flashcard.front)) {
        return index;
      }
    }
    for (int index = startIndex; index < items.length; index++) {
      if (items[index].sessionItem.answeredAt == null) {
        return index;
      }
    }
    return -1;
  }

  void _cancelAdvanceTimer() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
  }
}

class StudySessionFillState {
  const StudySessionFillState({
    required this.review,
    required this.currentIndex,
    this.inputText = '',
    this.hintReveals = 0,
    this.feedbackResult,
    this.feedbackCommitted = false,
    this.retryUsed = false,
    this.isChecking = false,
    this.isSaving = false,
    this.isFinalizing = false,
    this.readyToFinish = false,
    this.saveFailure,
    this.finalizeFailure,
    this.didFinalizeSuccessfully = false,
  });

  factory StudySessionFillState.fromReview(
    StudySessionReview review, {
    required int currentIndex,
  }) {
    final bool allAnswered = review.items.every(
      (StudySessionReviewItem item) => item.sessionItem.answeredAt != null,
    );
    return StudySessionFillState(
      review: review,
      currentIndex: currentIndex,
      readyToFinish: allAnswered,
    );
  }

  final StudySessionReview review;
  final int currentIndex;
  final String inputText;
  final int hintReveals;
  final AttemptResult? feedbackResult;
  final bool feedbackCommitted;
  final bool retryUsed;
  final bool isChecking;
  final bool isSaving;
  final bool isFinalizing;
  final bool readyToFinish;
  final Failure? saveFailure;
  final Failure? finalizeFailure;
  final bool didFinalizeSuccessfully;

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
    review: review ?? this.review,
    currentIndex: currentIndex ?? this.currentIndex,
    inputText: inputText ?? this.inputText,
    hintReveals: hintReveals ?? this.hintReveals,
    feedbackResult: clearFeedbackResult
        ? null
        : feedbackResult ?? this.feedbackResult,
    feedbackCommitted: feedbackCommitted ?? this.feedbackCommitted,
    retryUsed: retryUsed ?? this.retryUsed,
    isChecking: isChecking ?? this.isChecking,
    isSaving: isSaving ?? this.isSaving,
    isFinalizing: isFinalizing ?? this.isFinalizing,
    readyToFinish: readyToFinish ?? this.readyToFinish,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    finalizeFailure: clearFinalizeFailure
        ? null
        : finalizeFailure ?? this.finalizeFailure,
    didFinalizeSuccessfully:
        didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
  );
}

class StudySessionFillFailureException implements Exception {
  const StudySessionFillFailureException(this.failure);

  final Failure failure;
}
