import 'package:memox/domain/types/ids.dart';

/// One flashcard source item available for a Match board.
final class MatchBoardCard {
  const MatchBoardCard({
    required this.sessionItemId,
    required this.flashcardId,
    required this.front,
    required this.back,
  });

  final String sessionItemId;
  final FlashcardId flashcardId;
  final String front;
  final String back;
}

/// A single visible Match cell on the board.
final class MatchBoardCell {
  const MatchBoardCell({
    required this.id,
    required this.pairId,
    required this.sessionItemId,
    required this.flashcardId,
    required this.isFront,
    required this.text,
  });

  final String id;
  final String pairId;
  final String sessionItemId;
  final FlashcardId flashcardId;
  final bool isFront;
  final String text;
}

/// Stable pair identity for one card on a Match board.
final class MatchBoardPair {
  const MatchBoardPair({
    required this.id,
    required this.sessionItemId,
    required this.flashcardId,
    required this.frontCellId,
    required this.backCellId,
  });

  final String id;
  final String sessionItemId;
  final FlashcardId flashcardId;
  final String frontCellId;
  final String backCellId;
}

/// Immutable Match board composed from exactly 5 cards when available.
final class MatchBoard {
  const MatchBoard({
    required this.sessionId,
    required this.boardIndex,
    required this.pairs,
    required this.cells,
  });

  final SessionId sessionId;
  final int boardIndex;
  final List<MatchBoardPair> pairs;
  final List<MatchBoardCell> cells;

  int get pairCount => pairs.length;
  int get cellCount => cells.length;
}
