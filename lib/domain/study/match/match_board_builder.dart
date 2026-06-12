import 'dart:math' as math;

import 'package:memox/domain/study/match/match_board.dart';
import 'package:memox/domain/types/ids.dart';

/// Builds a deterministic Match board from the next 5 unique cards.
abstract final class MatchBoardBuilder {
  MatchBoardBuilder._();

  static const int pairLimit = 5;
  static const int cellCount = pairLimit * 2;

  static bool canBuild({required Iterable<MatchBoardCard> cards}) =>
      _uniqueCards(cards).length >= pairLimit;

  static MatchBoard build({
    required String sessionId,
    required int boardIndex,
    required Iterable<MatchBoardCard> cards,
  }) {
    final List<MatchBoardCard> uniqueCards = _uniqueCards(cards);
    if (uniqueCards.length < pairLimit) {
      throw UnsupportedError(
        'Match mode requires at least 5 valid unique cards.',
      );
    }

    final List<MatchBoardCard> selectedCards = uniqueCards
        .take(pairLimit)
        .toList(growable: false);
    final String boardSeed = '$sessionId|$boardIndex';

    final List<MatchBoardPair> pairs = selectedCards
        .map(
          (MatchBoardCard card) => MatchBoardPair(
            id: card.flashcardId,
            sessionItemId: card.sessionItemId,
            flashcardId: card.flashcardId,
            frontCellId: _cellId(
              sessionId: sessionId,
              boardIndex: boardIndex,
              flashcardId: card.flashcardId,
              side: 'front',
            ),
            backCellId: _cellId(
              sessionId: sessionId,
              boardIndex: boardIndex,
              flashcardId: card.flashcardId,
              side: 'back',
            ),
          ),
        )
        .toList(growable: false);

    final List<MatchBoardCell> cells = <MatchBoardCell>[
      for (final MatchBoardCard card in selectedCards)
        MatchBoardCell(
          id: _cellId(
            sessionId: sessionId,
            boardIndex: boardIndex,
            flashcardId: card.flashcardId,
            side: 'front',
          ),
          pairId: card.flashcardId,
          sessionItemId: card.sessionItemId,
          flashcardId: card.flashcardId,
          isFront: true,
          text: card.front,
        ),
      for (final MatchBoardCard card in selectedCards)
        MatchBoardCell(
          id: _cellId(
            sessionId: sessionId,
            boardIndex: boardIndex,
            flashcardId: card.flashcardId,
            side: 'back',
          ),
          pairId: card.flashcardId,
          sessionItemId: card.sessionItemId,
          flashcardId: card.flashcardId,
          isFront: false,
          text: card.back,
        ),
    ]..shuffle(math.Random(_stableHash(boardSeed)));

    return MatchBoard(
      sessionId: sessionId,
      boardIndex: boardIndex,
      pairs: pairs,
      cells: cells,
    );
  }

  static List<MatchBoardCard> _uniqueCards(Iterable<MatchBoardCard> cards) {
    final Map<String, MatchBoardCard> uniqueCardsById =
        <String, MatchBoardCard>{};
    for (final MatchBoardCard card in cards) {
      uniqueCardsById.putIfAbsent(card.flashcardId, () => card);
    }
    return uniqueCardsById.values.toList(growable: false);
  }

  static String _cellId({
    required String sessionId,
    required int boardIndex,
    required FlashcardId flashcardId,
    required String side,
  }) => '$sessionId|$boardIndex|$flashcardId|$side';

  static int _stableHash(String value) {
    const int fnvOffset = 0x811C9DC5;
    const int fnvPrime = 0x01000193;
    int hash = fnvOffset;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }
    return hash;
  }
}
