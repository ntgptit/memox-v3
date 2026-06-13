import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/guess/guess_option.dart';
import 'package:memox/domain/study/modes/guess_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_guess_viewmodel.g.dart';

@riverpod
class StudySessionGuessController extends _$StudySessionGuessController {
  late final GuessStudyModeStrategy _guessStrategy;
  late final BinaryGradeStudyModeStrategy _gradeStrategy;

  Timer? _advanceTimer;
  DateTime _currentShownAt = DateTime.now();

  void _markCurrentShown() => _currentShownAt = DateTime.now();

  @override
  Future<StudySessionGuessState> build(
    ({SessionId sessionId, StudyMode? studyMode}) request,
  ) async {
    ref.onDispose(_cancelTimers);

    final Result<StudySessionReview> result = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: request.sessionId);

    final StudySessionReview review = switch (result) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>(:final failure) =>
        throw StudySessionGuessFailureException(failure),
    };

    final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
      studyMode: request.studyMode,
    );
    if (strategy is! GuessStudyModeStrategy) {
      throw const StudySessionGuessFailureException(
        Failure.unsupportedAction(action: 'guess_mode'),
      );
    }
    _guessStrategy = strategy;
    _gradeStrategy = strategy;
    _markCurrentShown();

    final StudySessionGuessState initialState =
        StudySessionGuessState.fromReview(
          review: review,
          options: _buildOptions(review, _firstUnansweredIndex(review) ?? 0),
        );

    if (review.session.status == SessionStatus.inProgress &&
        initialState.allAnswered &&
        !initialState.isCountdownActive) {
      unawaited(_finalizeCurrentSession(initialState));
    }

    return initialState;
  }

  void selectOption(GuessOption option) => _recordAnswer(option);

  void skipCountdown() {
    final StudySessionGuessState? current = _currentState;
    if (current == null || !current.isCountdownActive || current.isBusy) {
      return;
    }
    _advanceTimer?.cancel();
    _advanceTimer = null;
    unawaited(_advanceOrFinalize(current));
  }

  Future<void> retryFinalize() async {
    final StudySessionGuessState? current = _currentState;
    if (current == null || current.isBusy || !current.allAnswered) {
      return;
    }
    await _finalizeCurrentSession(current);
  }

  StudySessionGuessState? get _currentState => switch (state) {
    AsyncData<StudySessionGuessState>(:final value) => value,
    _ => null,
  };

  List<GuessOption> _buildOptions(StudySessionReview review, int currentIndex) {
    try {
      return _guessStrategy.buildOptions(
        sessionId: review.session.id,
        current: review.items[currentIndex].flashcard,
        scopeCards: review.items.map(
          (StudySessionReviewItem item) => item.flashcard,
        ),
      );
    } on Object catch (error) {
      if (error is UnsupportedError) {
        throw const StudySessionGuessFailureException(
          Failure.unsupportedAction(action: 'guess_mode'),
        );
      }
      rethrow;
    }
  }

  int? _firstUnansweredIndex(StudySessionReview review) {
    for (int index = 0; index < review.items.length; index++) {
      if (review.items[index].sessionItem.answeredAt == null) {
        return index;
      }
    }
    return null;
  }

  Future<void> _recordAnswer(GuessOption option) async {
    final StudySessionGuessState? current = _currentState;
    if (current == null || current.isBusy || !current.canChooseCurrentItem) {
      return;
    }

    final StudySessionReviewItem currentItem = current.currentItem;
    final AttemptResult result = option.isCorrect
        ? _gradeStrategy.mapGotItAction()
        : _gradeStrategy.mapForgotAction();
    final Duration countdownDuration = option.isCorrect
        ? DurationTokens.guessCorrectCountdown
        : DurationTokens.guessWrongCountdown;

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
          sessionItemId: currentItem.sessionItem.id,
          result: result,
          studyMode: _gradeStrategy.mode,
          durationMs: elapsedMs >= 0 ? elapsedMs : null,
        );

    switch (recordResult) {
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(
            isSaving: false,
            saveFailure: failure,
            clearFinalizeFailure: true,
          ),
        );
        return;
      case Ok<void>():
        final DateTime answeredAt = DateTime.now().toUtc();
        final StudySessionGuessState updated = current.copyWith(
          review: current.review.copyWith(
            items: current.review.items
                .map(
                  (StudySessionReviewItem item) =>
                      item.sessionItem.id == currentItem.sessionItem.id
                      ? item.copyWith(
                          sessionItem: item.sessionItem.copyWith(
                            answeredAt: answeredAt,
                          ),
                        )
                      : item,
                )
                .toList(growable: false),
          ),
          selectedOptionId: option.flashcard.id,
          selectedOptionIsCorrect: option.isCorrect,
          countdownEndsAt: DateTime.now().add(countdownDuration),
          countdownDuration: countdownDuration,
          isSaving: false,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        );
        state = AsyncData(updated);
        _scheduleAdvance(updated);
    }
  }

  Future<void> _advanceOrFinalize(StudySessionGuessState current) async {
    if (!current.isCountdownActive || current.didFinalizeSuccessfully) {
      return;
    }
    final int? nextIndex = _nextUnansweredIndex(
      current.review.items,
      startIndex: current.currentIndex + 1,
    );
    if (nextIndex != null) {
      final StudySessionGuessState nextState = current.copyWith(
        currentIndex: nextIndex,
        options: _buildOptions(current.review, nextIndex),
        clearSelectedOptionId: true,
        clearCountdownEndsAt: true,
        clearCountdownDuration: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      );
      state = AsyncData(nextState);
      _markCurrentShown();
      return;
    }

    await _finalizeCurrentSession(current);
  }

  Future<void> _finalizeCurrentSession(StudySessionGuessState current) async {
    if (current.didFinalizeSuccessfully) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        isFinalizing: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
        clearCountdownEndsAt: true,
        clearCountdownDuration: true,
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
            clearCountdownEndsAt: true,
            clearCountdownDuration: true,
          ),
        );
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(
            isFinalizing: false,
            finalizeFailure: failure,
            clearSaveFailure: true,
            clearCountdownEndsAt: true,
            clearCountdownDuration: true,
          ),
        );
    }
  }

  void _scheduleAdvance(StudySessionGuessState current) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(current.countdownDuration ?? DurationTokens.fast, () {
      final StudySessionGuessState? latest = _currentState;
      if (latest == null || latest.didFinalizeSuccessfully) {
        return;
      }
      unawaited(_advanceOrFinalize(latest));
    });
  }

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

  void _cancelTimers() {
    _advanceTimer?.cancel();
  }
}

class StudySessionGuessState {
  const StudySessionGuessState({
    required this.review,
    required this.currentIndex,
    required this.options,
    this.selectedOptionId,
    this.selectedOptionIsCorrect = false,
    this.countdownEndsAt,
    this.countdownDuration,
    this.isSaving = false,
    this.isFinalizing = false,
    this.saveFailure,
    this.finalizeFailure,
    this.didFinalizeSuccessfully = false,
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
      review: review,
      currentIndex: currentIndex,
      options: options,
    );
  }

  final StudySessionReview review;
  final int currentIndex;
  final List<GuessOption> options;
  final String? selectedOptionId;
  final bool selectedOptionIsCorrect;
  final DateTime? countdownEndsAt;
  final Duration? countdownDuration;
  final bool isSaving;
  final bool isFinalizing;
  final Failure? saveFailure;
  final Failure? finalizeFailure;
  final bool didFinalizeSuccessfully;

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
    review: review ?? this.review,
    currentIndex: currentIndex ?? this.currentIndex,
    options: options ?? this.options,
    selectedOptionId: clearSelectedOptionId
        ? null
        : selectedOptionId ?? this.selectedOptionId,
    selectedOptionIsCorrect:
        selectedOptionIsCorrect ?? this.selectedOptionIsCorrect,
    countdownEndsAt: clearCountdownEndsAt
        ? null
        : countdownEndsAt ?? this.countdownEndsAt,
    countdownDuration: clearCountdownDuration
        ? null
        : countdownDuration ?? this.countdownDuration,
    isSaving: isSaving ?? this.isSaving,
    isFinalizing: isFinalizing ?? this.isFinalizing,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    finalizeFailure: clearFinalizeFailure
        ? null
        : finalizeFailure ?? this.finalizeFailure,
    didFinalizeSuccessfully:
        didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
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
