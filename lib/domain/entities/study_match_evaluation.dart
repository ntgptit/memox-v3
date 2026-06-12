import 'package:memox/domain/types/ids.dart';

/// An append-only Match evaluation recorded while a board is in progress.
class StudyMatchEvaluation {
  const StudyMatchEvaluation({
    required this.id,
    required this.sessionId,
    required this.sessionItemId,
    required this.flashcardId,
    required this.boardIndex,
    required this.pairId,
    required this.selectedFrontCellId,
    required this.selectedBackCellId,
    required this.expectedFrontFlashcardId,
    required this.expectedBackFlashcardId,
    required this.isCorrect,
    required this.attemptOrder,
    required this.evaluatedAt,
    required this.createdAt,
  });

  final String id;
  final SessionId sessionId;
  final String sessionItemId;
  final FlashcardId flashcardId;
  final int boardIndex;
  final String pairId;
  final String selectedFrontCellId;
  final String selectedBackCellId;
  final FlashcardId expectedFrontFlashcardId;
  final FlashcardId expectedBackFlashcardId;
  final bool isCorrect;
  final int attemptOrder;
  final DateTime evaluatedAt;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyMatchEvaluation &&
          other.id == id &&
          other.sessionId == sessionId &&
          other.sessionItemId == sessionItemId &&
          other.flashcardId == flashcardId &&
          other.boardIndex == boardIndex &&
          other.pairId == pairId &&
          other.selectedFrontCellId == selectedFrontCellId &&
          other.selectedBackCellId == selectedBackCellId &&
          other.expectedFrontFlashcardId == expectedFrontFlashcardId &&
          other.expectedBackFlashcardId == expectedBackFlashcardId &&
          other.isCorrect == isCorrect &&
          other.attemptOrder == attemptOrder &&
          other.evaluatedAt == evaluatedAt &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    sessionItemId,
    flashcardId,
    boardIndex,
    pairId,
    selectedFrontCellId,
    selectedBackCellId,
    expectedFrontFlashcardId,
    expectedBackFlashcardId,
    isCorrect,
    attemptOrder,
    evaluatedAt,
    createdAt,
  );
}
