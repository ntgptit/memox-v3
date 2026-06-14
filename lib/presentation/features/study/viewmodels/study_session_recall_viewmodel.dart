import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_recall_viewmodel.g.dart';

@riverpod
class StudySessionRecallController extends _$StudySessionRecallController {
  static const Duration _countdownTick = DurationTokens.oneSecond;

  late final StudyModeStrategy _studyModeStrategy;

  Timer? _countdownTimer;
  DateTime _currentShownAt = DateTime.now();
  DateTime? _countdownPausedAt;

  void _markCurrentShown() => _currentShownAt = DateTime.now();

  @override
  Future<StudySessionRecallState> build(
    ({SessionId sessionId, StudyMode? studyMode}) request,
  ) async {
    ref.onDispose(_cancelCountdown);

    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: request.sessionId);

    final StudySessionReview review = switch (result) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>(:final failure) =>
        throw StudySessionRecallFailureException(failure),
    };

    _studyModeStrategy = StudyModeStrategyFactory.resolve(
      studyMode: request.studyMode,
    );
    _markCurrentShown();

    final StudySessionRecallState initialState =
        StudySessionRecallState.fromReview(review);

    if (review.session.status == SessionStatus.inProgress &&
        initialState.allAnswered) {
      unawaited(_finalizeCurrentSession(initialState));
    }
    if (!initialState.allAnswered) {
      _startCountdown();
    }

    return initialState;
  }

  Future<void> refreshReview() async {
    final StudySessionRecallState? current = _currentState;
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

    final int currentIndex = current.currentIndex < refreshedReview.items.length
        ? current.currentIndex
        : (refreshedReview.items.isEmpty
              ? 0
              : refreshedReview.items.length - 1);
    state = AsyncData(
      current.copyWith(review: refreshedReview, currentIndex: currentIndex),
    );
  }

  void revealAnswer() {
    final StudySessionRecallState? current = _currentState;
    if (current == null || current.isBusy || !current.canRevealAnswer) {
      return;
    }

    _cancelCountdown();
    state = AsyncData(current.revealAnswer());
  }

  void pauseCountdown() {
    final StudySessionRecallState? current = _currentState;
    if (current == null ||
        current.isBusy ||
        current.isAnswerVisible ||
        current.countdownRemainingSeconds <= 0 ||
        _countdownPausedAt != null) {
      return;
    }

    _countdownPausedAt = DateTime.now();
    _cancelCountdown();
  }

  void resumeCountdown() {
    final StudySessionRecallState? current = _currentState;
    final DateTime? pausedAt = _countdownPausedAt;
    if (current == null ||
        pausedAt == null ||
        current.isBusy ||
        current.isAnswerVisible ||
        current.countdownRemainingSeconds <= 0) {
      _countdownPausedAt = null;
      return;
    }

    _currentShownAt = _currentShownAt.add(DateTime.now().difference(pausedAt));
    _countdownPausedAt = null;
    _startCountdown();
  }

  Future<void> gradeForgot() => _recordAnswer(
    (BinaryGradeStudyModeStrategy strategy) => strategy.mapForgotAction(),
  );

  Future<void> gradeGotIt() => _recordAnswer(
    (BinaryGradeStudyModeStrategy strategy) => strategy.mapGotItAction(),
  );

  Future<bool> finishSession() async {
    final StudySessionRecallState? current = _currentState;
    if (current == null || current.isBusy || !current.allAnswered) {
      return false;
    }

    return _finalizeCurrentSession(current);
  }

  StudySessionRecallState? get _currentState => switch (state) {
    AsyncData<StudySessionRecallState>(:final value) => value,
    _ => null,
  };

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(_countdownTick, (_) {
      final StudySessionRecallState? current = _currentState;
      if (current == null ||
          current.isBusy ||
          current.isAnswerVisible ||
          current.allAnswered ||
          current.currentItemAnswered) {
        return;
      }

      if (current.countdownRemainingSeconds <= 1) {
        _cancelCountdown();
        state = AsyncData(current.revealAnswer(byTimeout: true));
        return;
      }

      state = AsyncData(current.countdownTick());
    });
  }

  Future<void> _recordAnswer(
    AttemptResult Function(BinaryGradeStudyModeStrategy strategy) mapResult,
  ) async {
    final StudySessionRecallState? current = _currentState;
    if (current == null || current.isSaving || !current.canGradeCurrentItem) {
      return;
    }

    final StudySessionReviewItem item = current.currentItem;
    final StudyModeStrategy strategy = _studyModeStrategy;
    if (strategy is! BinaryGradeStudyModeStrategy) {
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
        final StudySessionRecallState answeredState = current.markAnswered(
          sessionItemId: item.sessionItem.id,
          answeredAt: answeredAt,
        );
        state = AsyncData(answeredState);
        if (answeredState.allAnswered &&
            current.review.session.status == SessionStatus.inProgress) {
          unawaited(_finalizeCurrentSession(answeredState));
          return;
        }

        _markCurrentShown();
        _startCountdown();
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isSaving: false, saveFailure: failure),
        );
    }
  }

  Future<bool> _finalizeCurrentSession(StudySessionRecallState current) async {
    if (current.didFinalizeSuccessfully) {
      return true;
    }

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
        return true;
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isFinalizing: false, finalizeFailure: failure),
        );
        return false;
    }
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }
}

class StudySessionRecallState {
  const StudySessionRecallState({
    required this.review,
    required this.currentIndex,
    this.isAnswerVisible = false,
    this.countdownRemainingSeconds = DurationTokens.recallAnswerTimeoutSeconds,
    this.revealedByTimeout = false,
    this.isSaving = false,
    this.isFinalizing = false,
    this.saveFailure,
    this.finalizeFailure,
    this.didFinalizeSuccessfully = false,
  });

  factory StudySessionRecallState.fromReview(StudySessionReview review) {
    final int firstUnansweredIndex = review.items.indexWhere(
      (StudySessionReviewItem item) => item.sessionItem.answeredAt == null,
    );
    return StudySessionRecallState(
      review: review,
      currentIndex: firstUnansweredIndex == -1 ? 0 : firstUnansweredIndex,
    );
  }

  final StudySessionReview review;
  final int currentIndex;
  final bool isAnswerVisible;
  final int countdownRemainingSeconds;
  final bool revealedByTimeout;
  final bool isSaving;
  final bool isFinalizing;
  final Failure? saveFailure;
  final Failure? finalizeFailure;
  final bool didFinalizeSuccessfully;

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
    review: review ?? this.review,
    currentIndex: currentIndex ?? this.currentIndex,
    isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
    countdownRemainingSeconds:
        countdownRemainingSeconds ?? this.countdownRemainingSeconds,
    revealedByTimeout: revealedByTimeout ?? this.revealedByTimeout,
    isSaving: isSaving ?? this.isSaving,
    isFinalizing: isFinalizing ?? this.isFinalizing,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    finalizeFailure: clearFinalizeFailure
        ? null
        : finalizeFailure ?? this.finalizeFailure,
    didFinalizeSuccessfully:
        didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
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
