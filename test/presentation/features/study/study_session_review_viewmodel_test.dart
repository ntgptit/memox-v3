import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_item.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/presentation/features/study/viewmodels/study_session_review_viewmodel.dart';

StudySessionReview _review({
  required List<({String front, String back})> cards,
  Set<int> answeredIndices = const <int>{},
}) {
  final DateTime now = DateTime.utc(2026, 1, 1);
  final StudySession session = StudySession(
    id: 'session-review',
    entryType: EntryType.deck,
    entryRefId: 'deck-1',
    studyType: StudyType.newCards,
    status: SessionStatus.inProgress,
    studyFlow: StudyFlow.newFullCycle,
    currentMode: StudyMode.review,
    startedAt: now,
    updatedAt: now,
  );
  return StudySessionReview(
    session: session,
    items: <StudySessionReviewItem>[
      for (int index = 0; index < cards.length; index++)
        StudySessionReviewItem(
          sessionItem: StudySessionItem(
            id: 'item-$index',
            sessionId: session.id,
            flashcardId: 'card-$index',
            sortOrder: index,
            answeredAt: answeredIndices.contains(index) ? now : null,
            createdAt: now,
            updatedAt: now,
          ),
          flashcard: Flashcard(
            id: 'card-$index',
            deckId: 'deck-1',
            front: cards[index].front,
            back: cards[index].back,
            sortOrder: index,
            createdAt: now,
            updatedAt: now,
          ),
          targetLanguage: TargetLanguage.korean,
        ),
    ],
  );
}

void main() {
  test('DT1 fromReview: first unanswered item becomes the current card', () {
    final StudySessionReviewState state = StudySessionReviewState.fromReview(
      _review(
        cards: <({String front, String back})>[
          (front: 'Front 1', back: 'Back 1'),
          (front: 'Front 2', back: 'Back 2'),
          (front: 'Front 3', back: 'Back 3'),
        ],
        answeredIndices: <int>{0},
      ),
    );

    expect(state.currentIndex, 1);
    expect(state.currentItem.flashcard.front, 'Front 2');
    expect(state.currentItem.sessionItem.answeredAt, isNull);
    expect(state.review.items.first.sessionItem.answeredAt, isNotNull);
    expect(state.allAnswered, isFalse);
  });

  test(
    'DT2 fromReview: fully answered review falls back to the first item',
    () {
      final StudySessionReviewState state = StudySessionReviewState.fromReview(
        _review(
          cards: <({String front, String back})>[
            (front: 'Front 1', back: 'Back 1'),
            (front: 'Front 2', back: 'Back 2'),
          ],
          answeredIndices: <int>{0, 1},
        ),
      );

      expect(state.currentIndex, 0);
      expect(state.currentItem.flashcard.front, 'Front 1');
      expect(state.currentItem.sessionItem.answeredAt, isNotNull);
      expect(state.allAnswered, isTrue);
    },
  );
}
