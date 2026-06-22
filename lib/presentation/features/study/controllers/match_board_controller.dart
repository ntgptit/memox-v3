import 'dart:async';
import 'dart:math';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_motion.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_board_controller.g.dart';

/// The visual status of one board cell (wireframe `14` §Components).
enum MatchCellStatus { idle, selected, matched, wrong }

/// One cell on the Match board — a single front OR back face of a card.
class MatchCell {
  const MatchCell({
    required this.id,
    required this.text,
    required this.flashcardId,
    required this.sessionItemId,
    required this.isFront,
    required this.status,
  });

  /// Stable per-board cell id (`f<sortOrder>` / `b<sortOrder>`).
  final String id;
  final String text;
  final FlashcardId flashcardId;
  final String sessionItemId;
  final bool isFront;
  final MatchCellStatus status;

  MatchCell copyWith({MatchCellStatus? status}) => MatchCell(
    id: id,
    text: text,
    flashcardId: flashcardId,
    sessionItemId: sessionItemId,
    isFront: isFront,
    status: status ?? this.status,
  );
}

/// The current Match board: its (shuffled) cells + the live selection (WP-SM4).
class MatchBoardView {
  const MatchBoardView({
    required this.cells,
    required this.boardIndex,
    required this.totalPairs,
    required this.sessionTotal,
    required this.selectedCellId,
  });

  final List<MatchCell> cells;
  final int boardIndex;

  /// Pairs on this board (= cells / 2).
  final int totalPairs;

  /// Total cards in the whole session (for the `{matched}/{total}` count).
  final int sessionTotal;
  final String? selectedCellId;

  int get matchedCount =>
      cells
          .where((MatchCell c) => c.status == MatchCellStatus.matched)
          .length ~/
      2;
  int get pairsLeft => totalPairs - matchedCount;
  bool get boardComplete => totalPairs > 0 && matchedCount == totalPairs;

  MatchBoardView copyWith({
    List<MatchCell>? cells,
    String? selectedCellId,
    bool clearSelection = false,
  }) => MatchBoardView(
    cells: cells ?? this.cells,
    boardIndex: boardIndex,
    totalPairs: totalPairs,
    sessionTotal: sessionTotal,
    selectedCellId: clearSelection
        ? null
        : (selectedCellId ?? this.selectedCellId),
  );
}

/// Drives the Match board's tap-pair interaction (WP-SM4): builds the current
/// board's 10 Fisher-Yates-shuffled cells from the review queue, tracks the
/// single live selection, evaluates each second tap, and persists every pair
/// (right or wrong) via `RecordMatchEvaluationUseCase` (append-only).
///
/// One selection at a time; a matched pair locks (non-interactive); a wrong pair
/// flashes for [_wrongFlash] then both cells deselect. Board progression +
/// finalize are WP-SM5. WBS 4.5.5.
@riverpod
class MatchBoardController extends _$MatchBoardController {
  static const int _boardSize = 5;
  static const Duration _wrongFlash = AppMotion.matchWrongFlash;

  @override
  Future<MatchBoardView> build(SessionId sessionId) async {
    final StudySessionReview review = await ref.watch(
      studySessionReviewProvider(sessionId).future,
    );
    return _buildBoard(review, boardIndex: 0);
  }

  MatchBoardView _buildBoard(
    StudySessionReview review, {
    required int boardIndex,
  }) {
    final List<StudySessionReviewItem> items = review.items
        .skip(boardIndex * _boardSize)
        .take(_boardSize)
        .toList();
    final List<MatchCell> cells = <MatchCell>[];
    for (final StudySessionReviewItem item in items) {
      cells.add(
        MatchCell(
          id: 'f${item.sortOrder}',
          text: item.front,
          flashcardId: item.flashcardId,
          sessionItemId: item.sessionItemId,
          isFront: true,
          status: MatchCellStatus.idle,
        ),
      );
      cells.add(
        MatchCell(
          id: 'b${item.sortOrder}',
          text: item.back,
          flashcardId: item.flashcardId,
          sessionItemId: item.sessionItemId,
          isFront: false,
          status: MatchCellStatus.idle,
        ),
      );
    }
    // Fisher-Yates with a per-board deterministic seed (testable + stable golden).
    final Random rng = Random(sessionId.hashCode ^ (boardIndex + 1));
    for (int i = cells.length - 1; i > 0; i--) {
      final int j = rng.nextInt(i + 1);
      final MatchCell tmp = cells[i];
      cells[i] = cells[j];
      cells[j] = tmp;
    }
    return MatchBoardView(
      cells: cells,
      boardIndex: boardIndex,
      totalPairs: items.length,
      sessionTotal: review.total,
      selectedCellId: null,
    );
  }

  /// Re-entrancy guard: while a pair is being evaluated (record + wrong-flash),
  /// further taps are ignored so a third tap can't re-evaluate the stale pair.
  bool _evaluating = false;

  /// Handle a tap on cell [cellId] (the tap-pair FSM).
  Future<void> select(String cellId) async {
    if (_evaluating) return;
    final MatchBoardView? view = state.asData?.value;
    if (view == null) return;
    final MatchCell tapped = view.cells.firstWhere(
      (MatchCell c) => c.id == cellId,
    );
    if (tapped.status == MatchCellStatus.matched ||
        tapped.status == MatchCellStatus.wrong) {
      return; // locked or mid-flash
    }

    final String? selectedId = view.selectedCellId;
    if (selectedId == null) {
      state = AsyncData<MatchBoardView>(
        view.copyWith(
          cells: _withStatus(view.cells, cellId, MatchCellStatus.selected),
          selectedCellId: cellId,
        ),
      );
      return;
    }
    if (selectedId == cellId) {
      // Tap the selected cell again → deselect.
      state = AsyncData<MatchBoardView>(
        view.copyWith(
          cells: _withStatus(view.cells, cellId, MatchCellStatus.idle),
          clearSelection: true,
        ),
      );
      return;
    }

    // Second cell → evaluate the pair.
    final MatchCell first = view.cells.firstWhere(
      (MatchCell c) => c.id == selectedId,
    );
    final bool isPair =
        first.flashcardId == tapped.flashcardId &&
        first.isFront != tapped.isFront;
    final MatchCell front = first.isFront ? first : tapped;
    final MatchCell back = first.isFront ? tapped : first;

    // Guard the whole evaluation (record + wrong-flash) against re-entrant taps.
    _evaluating = true;
    try {
      await _record(
        front: front,
        back: back,
        isCorrect: isPair,
        boardIndex: view.boardIndex,
      );

      final MatchBoardView? current = state.asData?.value;
      if (current == null) return;
      if (isPair) {
        state = AsyncData<MatchBoardView>(
          current.copyWith(
            cells: _withStatus(
              _withStatus(current.cells, first.id, MatchCellStatus.matched),
              tapped.id,
              MatchCellStatus.matched,
            ),
            clearSelection: true,
          ),
        );
        return;
      }
      // Wrong pair: flash both, then revert to idle.
      state = AsyncData<MatchBoardView>(
        current.copyWith(
          cells: _withStatus(
            _withStatus(current.cells, first.id, MatchCellStatus.wrong),
            tapped.id,
            MatchCellStatus.wrong,
          ),
          clearSelection: true,
        ),
      );
      await Future<void>.delayed(_wrongFlash);
      final MatchBoardView? afterFlash = state.asData?.value;
      if (afterFlash == null) return;
      state = AsyncData<MatchBoardView>(
        afterFlash.copyWith(
          cells: _withStatus(
            _withStatus(afterFlash.cells, first.id, MatchCellStatus.idle),
            tapped.id,
            MatchCellStatus.idle,
          ),
        ),
      );
    } finally {
      _evaluating = false;
    }
  }

  Future<void> _record({
    required MatchCell front,
    required MatchCell back,
    required bool isCorrect,
    required int boardIndex,
  }) async {
    // The eval is attributed to the FRONT cell's session item (its card decides
    // its own terminal at finalization; a wrong tap blames the front face).
    final Result<void> result = await ref
        .read(recordMatchEvaluationUseCaseProvider)
        .call(
          sessionId: sessionId,
          sessionItemId: front.sessionItemId,
          boardIndex: boardIndex,
          pairId: front.flashcardId,
          selectedFrontCellId: front.id,
          selectedBackCellId: back.id,
          expectedFrontFlashcardId: front.flashcardId,
          expectedBackFlashcardId: back.flashcardId,
          isCorrect: isCorrect,
        );
    // Tolerated like the Review grade: a persist failure leaves the board state
    // as-is (the session stays resumable; finalization re-derives from rows).
    if (result.failure != null) return;
  }

  List<MatchCell> _withStatus(
    List<MatchCell> cells,
    String cellId,
    MatchCellStatus status,
  ) => <MatchCell>[
    for (final MatchCell c in cells)
      if (c.id == cellId) c.copyWith(status: status) else c,
  ];
}
