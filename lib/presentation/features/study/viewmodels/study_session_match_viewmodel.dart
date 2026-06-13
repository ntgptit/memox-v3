import 'dart:async';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/match/match_board.dart';
import 'package:memox/domain/study/match/match_board_builder.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_match_viewmodel.g.dart';

const Duration _matchWrongFlashDuration = DurationTokens.chartDraw;

@riverpod
class StudySessionMatchController extends _$StudySessionMatchController {
  Timer? _advanceTimer;
  Timer? _wrongFlashTimer;

  @override
  Future<StudySessionMatchState> build(
    ({SessionId sessionId, StudyMode? studyMode}) request,
  ) async {
    ref.onDispose(_cancelTimers);

    final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
      studyMode: request.studyMode,
    );
    if (strategy is! BoardStudyModeStrategy) {
      throw const StudySessionMatchFailureException(
        Failure.unsupportedAction(action: 'match_mode'),
      );
    }

    final Result<StudySessionReview> reviewResult = await ref
        .read(loadStudySessionReviewUseCaseProvider)
        .call(sessionId: request.sessionId);
    final StudySessionReview review = switch (reviewResult) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>(:final failure) =>
        throw StudySessionMatchFailureException(failure),
    };

    final Result<List<StudyMatchEvaluation>> evaluationsResult = await ref
        .read(loadMatchEvaluationsUseCaseProvider)
        .call(sessionId: request.sessionId);
    final List<StudyMatchEvaluation> evaluations = switch (evaluationsResult) {
      Ok<List<StudyMatchEvaluation>>(:final value) => value,
      Err<List<StudyMatchEvaluation>>(:final failure) =>
        throw StudySessionMatchFailureException(failure),
    };

    return StudySessionMatchState.initial(
      review: review,
      evaluations: evaluations,
      boardStartedAt: DateTime.now(),
    );
  }

  void tapCell(MatchBoardCell cell) {
    final StudySessionMatchState? current = _currentState;
    if (current == null || current.isBusy || current.didFinalizeSuccessfully) {
      return;
    }
    if (current.isCellMatched(cell.id)) {
      return;
    }

    final String? selectedCellId = current.selectedCellId;
    if (selectedCellId == null) {
      state = AsyncData(
        current.copyWith(
          selectedCellId: cell.id,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        ),
      );
      return;
    }

    if (selectedCellId == cell.id) {
      state = AsyncData(
        current.copyWith(
          clearSelectedCellId: true,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        ),
      );
      return;
    }

    final MatchBoardCell firstCell = current.cellById(selectedCellId);
    unawaited(
      _recordEvaluation(
        current: current,
        firstCell: firstCell,
        secondCell: cell,
      ),
    );
  }

  Future<void> retryFinalize() async {
    final StudySessionMatchState? current = _currentState;
    if (current == null || current.isBusy || !current.allBoardsCompleted) {
      return;
    }
    await _finalizeCurrentSession(current);
  }

  StudySessionMatchState? get _currentState => switch (state) {
    AsyncData<StudySessionMatchState>(:final value) => value,
    _ => null,
  };

  Future<void> _recordEvaluation({
    required StudySessionMatchState current,
    required MatchBoardCell firstCell,
    required MatchBoardCell secondCell,
  }) async {
    final bool isCorrect = firstCell.pairId == secondCell.pairId;
    state = AsyncData(
      current.copyWith(
        isSaving: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      ),
    );

    final (String selectedFrontCellId, String selectedBackCellId) =
        _selectedCellIds(firstCell, secondCell);
    final Result<void> recordResult = await ref
        .read(recordMatchEvaluationUseCaseProvider)
        .call(
          sessionId: current.review.session.id,
          sessionItemId: firstCell.sessionItemId,
          flashcardId: firstCell.flashcardId,
          boardIndex: current.visibleBoardIndex,
          pairId: firstCell.pairId,
          selectedFrontCellId: selectedFrontCellId,
          selectedBackCellId: selectedBackCellId,
          expectedFrontFlashcardId: firstCell.flashcardId,
          expectedBackFlashcardId: firstCell.flashcardId,
          isCorrect: isCorrect,
          studyMode: StudyMode.match,
        );

    switch (recordResult) {
      case Err<void>(:final failure):
        state = AsyncData(
          current.copyWith(isSaving: false, saveFailure: failure),
        );
        return;
      case Ok<void>():
        final DateTime evaluatedAt = DateTime.now();
        final StudyMatchEvaluation evaluation = StudyMatchEvaluation(
          id: IdGenerator.newId(),
          sessionId: current.review.session.id,
          sessionItemId: firstCell.sessionItemId,
          flashcardId: firstCell.flashcardId,
          boardIndex: current.visibleBoardIndex,
          pairId: firstCell.pairId,
          selectedFrontCellId: selectedFrontCellId,
          selectedBackCellId: selectedBackCellId,
          expectedFrontFlashcardId: firstCell.flashcardId,
          expectedBackFlashcardId: firstCell.flashcardId,
          isCorrect: isCorrect,
          attemptOrder: current.evaluations.length,
          evaluatedAt: evaluatedAt,
          createdAt: evaluatedAt,
        );
        final StudySessionMatchState updated = current.copyWith(
          evaluations: <StudyMatchEvaluation>[
            ...current.evaluations,
            evaluation,
          ],
          isSaving: false,
          clearSelectedCellId: true,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        );
        state = AsyncData(updated);
        if (isCorrect) {
          await _advanceOrFinalize(updated);
          return;
        }

        _scheduleWrongFlashClear(
          updated.copyWith(
            wrongFlashCellIds: <String>{firstCell.id, secondCell.id},
          ),
        );
    }
  }

  Future<void> _advanceOrFinalize(StudySessionMatchState current) async {
    if (!current.isCurrentBoardComplete) {
      return;
    }
    if (current.hasNextBoard) {
      final StudySessionMatchState advancing = current.copyWith(
        isAdvancing: true,
        clearSelectedCellId: true,
        clearWrongFlashCellIds: true,
        clearSaveFailure: true,
        clearFinalizeFailure: true,
      );
      state = AsyncData(advancing);
      _advanceTimer?.cancel();
      _advanceTimer = Timer(DurationTokens.contentSwitch, () {
        final StudySessionMatchState? latest = _currentState;
        if (latest == null || latest.didFinalizeSuccessfully) {
          return;
        }
        state = AsyncData(
          latest.copyWith(
            visibleBoardIndex: latest.visibleBoardIndex + 1,
            boardStartedAt: DateTime.now(),
            isAdvancing: false,
            clearSelectedCellId: true,
            clearWrongFlashCellIds: true,
            clearSaveFailure: true,
            clearFinalizeFailure: true,
          ),
        );
      });
      return;
    }

    await _finalizeCurrentSession(current);
  }

  Future<void> _finalizeCurrentSession(StudySessionMatchState current) async {
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
          current.copyWith(
            isFinalizing: false,
            finalizeFailure: failure,
            clearSaveFailure: true,
          ),
        );
    }
  }

  void _scheduleWrongFlashClear(StudySessionMatchState current) {
    _wrongFlashTimer?.cancel();
    state = AsyncData(
      current.copyWith(wrongFlashCellIds: current.wrongFlashCellIds),
    );
    _wrongFlashTimer = Timer(_matchWrongFlashDuration, () {
      final StudySessionMatchState? latest = _currentState;
      if (latest == null || latest.didFinalizeSuccessfully) {
        return;
      }
      state = AsyncData(
        latest.copyWith(
          clearWrongFlashCellIds: true,
          clearSaveFailure: true,
          clearFinalizeFailure: true,
        ),
      );
    });
  }

  void _cancelTimers() {
    _advanceTimer?.cancel();
    _wrongFlashTimer?.cancel();
  }

  (String selectedFrontCellId, String selectedBackCellId) _selectedCellIds(
    MatchBoardCell firstCell,
    MatchBoardCell secondCell,
  ) {
    if (firstCell.isFront && !secondCell.isFront) {
      return (firstCell.id, secondCell.id);
    }
    if (!firstCell.isFront && secondCell.isFront) {
      return (secondCell.id, firstCell.id);
    }
    return firstCell.isFront
        ? (firstCell.id, secondCell.id)
        : (secondCell.id, firstCell.id);
  }
}

class StudySessionMatchState {
  const StudySessionMatchState({
    required this.review,
    required this.visibleBoardIndex,
    required this.evaluations,
    required this.boardStartedAt,
    this.selectedCellId,
    this.wrongFlashCellIds = const <String>{},
    this.isSaving = false,
    this.isAdvancing = false,
    this.isFinalizing = false,
    this.saveFailure,
    this.finalizeFailure,
    this.didFinalizeSuccessfully = false,
  });

  factory StudySessionMatchState.initial({
    required StudySessionReview review,
    required List<StudyMatchEvaluation> evaluations,
    required DateTime boardStartedAt,
  }) {
    final Set<String> matchedSessionItemIds = evaluations
        .where((StudyMatchEvaluation evaluation) => evaluation.isCorrect)
        .map((StudyMatchEvaluation evaluation) => evaluation.sessionItemId)
        .toSet();
    return StudySessionMatchState(
      review: review,
      visibleBoardIndex:
          matchedSessionItemIds.length ~/ MatchBoardBuilder.pairLimit,
      evaluations: evaluations,
      boardStartedAt: boardStartedAt,
    );
  }

  final StudySessionReview review;
  final int visibleBoardIndex;
  final List<StudyMatchEvaluation> evaluations;
  final DateTime boardStartedAt;
  final String? selectedCellId;
  final Set<String> wrongFlashCellIds;
  final bool isSaving;
  final bool isAdvancing;
  final bool isFinalizing;
  final Failure? saveFailure;
  final Failure? finalizeFailure;
  final bool didFinalizeSuccessfully;

  int get totalCards => review.items.length;

  int get totalBoards => totalCards ~/ MatchBoardBuilder.pairLimit;

  int get matchedCount => matchedSessionItemIds.length;

  int get matchedPairsOnCurrentBoard => currentBoardItems
      .where(
        (StudySessionReviewItem item) =>
            matchedSessionItemIds.contains(item.sessionItem.id),
      )
      .length;

  int get pairsLeft => currentBoard.pairCount - matchedPairsOnCurrentBoard;

  bool get isCurrentBoardComplete =>
      matchedPairsOnCurrentBoard >= currentBoard.pairCount;

  bool get hasNextBoard => visibleBoardIndex + 1 < totalBoards;

  bool get allBoardsCompleted => matchedCount >= totalCards;

  bool get isWrongFlashVisible => wrongFlashCellIds.isNotEmpty;

  bool get isBusy =>
      isSaving || isAdvancing || isFinalizing || isWrongFlashVisible;

  Set<String> get matchedSessionItemIds => evaluations
      .where((StudyMatchEvaluation evaluation) => evaluation.isCorrect)
      .map((StudyMatchEvaluation evaluation) => evaluation.sessionItemId)
      .toSet();

  List<StudySessionReviewItem> get currentBoardItems {
    final int start = visibleBoardIndex * MatchBoardBuilder.pairLimit;
    return review.items
        .skip(start)
        .take(MatchBoardBuilder.pairLimit)
        .toList(growable: false);
  }

  MatchBoard get currentBoard => MatchBoardBuilder.build(
    sessionId: review.session.id,
    boardIndex: visibleBoardIndex,
    cards: currentBoardItems
        .map(
          (StudySessionReviewItem item) => MatchBoardCard(
            sessionItemId: item.sessionItem.id,
            flashcardId: item.flashcard.id,
            front: item.flashcard.front,
            back: item.flashcard.back,
          ),
        )
        .toList(growable: false),
  );

  MatchBoardCell cellById(String cellId) =>
      currentBoard.cells.firstWhere((MatchBoardCell cell) => cell.id == cellId);

  bool isCellMatched(String cellId) => matchedSessionItemIds.contains(
    currentBoard.cells
        .firstWhere((MatchBoardCell cell) => cell.id == cellId)
        .sessionItemId,
  );

  StudySessionMatchState copyWith({
    StudySessionReview? review,
    int? visibleBoardIndex,
    List<StudyMatchEvaluation>? evaluations,
    DateTime? boardStartedAt,
    String? selectedCellId,
    bool clearSelectedCellId = false,
    Set<String>? wrongFlashCellIds,
    bool clearWrongFlashCellIds = false,
    bool? isSaving,
    bool? isAdvancing,
    bool? isFinalizing,
    Failure? saveFailure,
    Failure? finalizeFailure,
    bool clearSaveFailure = false,
    bool clearFinalizeFailure = false,
    bool? didFinalizeSuccessfully,
  }) => StudySessionMatchState(
    review: review ?? this.review,
    visibleBoardIndex: visibleBoardIndex ?? this.visibleBoardIndex,
    evaluations: evaluations ?? this.evaluations,
    boardStartedAt: boardStartedAt ?? this.boardStartedAt,
    selectedCellId: clearSelectedCellId
        ? null
        : selectedCellId ?? this.selectedCellId,
    wrongFlashCellIds: clearWrongFlashCellIds
        ? const <String>{}
        : wrongFlashCellIds ?? this.wrongFlashCellIds,
    isSaving: isSaving ?? this.isSaving,
    isAdvancing: isAdvancing ?? this.isAdvancing,
    isFinalizing: isFinalizing ?? this.isFinalizing,
    saveFailure: clearSaveFailure ? null : saveFailure ?? this.saveFailure,
    finalizeFailure: clearFinalizeFailure
        ? null
        : finalizeFailure ?? this.finalizeFailure,
    didFinalizeSuccessfully:
        didFinalizeSuccessfully ?? this.didFinalizeSuccessfully,
  );
}

class StudySessionMatchFailureException implements Exception {
  const StudySessionMatchFailureException(this.failure);

  final Failure failure;
}
