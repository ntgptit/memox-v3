import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/match/match_board.dart';
import 'package:memox/domain/study/match/match_board_builder.dart';

MatchBoardCard _card(
  String sessionItemId,
  String flashcardId,
  String front,
  String back,
) => MatchBoardCard(
  sessionItemId: sessionItemId,
  flashcardId: flashcardId,
  front: front,
  back: back,
);

void main() {
  test('builds exactly five pairs and ten cells from five unique cards', () {
    final List<MatchBoardCard> cards = <MatchBoardCard>[
      _card('item-1', 'card-1', '공부하다', 'to study'),
      _card('item-2', 'card-2', '먹다', 'to eat'),
      _card('item-3', 'card-3', '하늘', 'sky'),
      _card('item-4', 'card-4', '도서관', 'library'),
      _card('item-5', 'card-5', '책', 'book'),
    ];

    expect(MatchBoardBuilder.canBuild(cards: cards), isTrue);

    final MatchBoard board = MatchBoardBuilder.build(
      sessionId: 'session-1',
      boardIndex: 0,
      cards: cards,
    );

    expect(board.pairCount, 5);
    expect(board.cellCount, 10);
    expect(board.pairs.map((pair) => pair.id), <String>[
      'card-1',
      'card-2',
      'card-3',
      'card-4',
      'card-5',
    ]);
    expect(board.cells.where((cell) => cell.isFront), hasLength(5));
    expect(board.cells.where((cell) => !cell.isFront), hasLength(5));
  });

  test(
    'build keeps pair identity and cell ownership stable by id across duplicate text',
    () {
      final List<MatchBoardCard> cards = <MatchBoardCard>[
        _card('item-1', 'card-1', '같다', 'same'),
        _card('item-2', 'card-2', '같다', 'same'),
        _card('item-3', 'card-3', '열다', 'open'),
        _card('item-4', 'card-4', '닫다', 'close'),
        _card('item-5', 'card-5', '보다', 'see'),
      ];

      final MatchBoard board = MatchBoardBuilder.build(
        sessionId: 'session-dup',
        boardIndex: 1,
        cards: cards,
      );

      expect(board.pairs.map((pair) => pair.flashcardId), <String>[
        'card-1',
        'card-2',
        'card-3',
        'card-4',
        'card-5',
      ]);
      expect(
        board.cells.where((cell) => cell.pairId == 'card-1'),
        hasLength(2),
      );
      expect(
        board.cells
            .where((cell) => cell.pairId == 'card-1')
            .map((cell) => cell.sessionItemId),
        everyElement('item-1'),
      );
    },
  );

  test('build is deterministic for the same seed and input cards', () {
    final List<MatchBoardCard> cards = <MatchBoardCard>[
      _card('item-1', 'card-1', '공부하다', 'to study'),
      _card('item-2', 'card-2', '먹다', 'to eat'),
      _card('item-3', 'card-3', '하늘', 'sky'),
      _card('item-4', 'card-4', '도서관', 'library'),
      _card('item-5', 'card-5', '책', 'book'),
    ];

    final List<String> firstOrder = MatchBoardBuilder.build(
      sessionId: 'session-2',
      boardIndex: 0,
      cards: cards,
    ).cells.map((cell) => cell.id).toList(growable: false);
    final List<String> secondOrder = MatchBoardBuilder.build(
      sessionId: 'session-2',
      boardIndex: 0,
      cards: cards,
    ).cells.map((cell) => cell.id).toList(growable: false);
    final List<String> differentBoardOrder = MatchBoardBuilder.build(
      sessionId: 'session-2',
      boardIndex: 1,
      cards: cards,
    ).cells.map((cell) => cell.id).toList(growable: false);

    expect(firstOrder, equals(secondOrder));
    expect(firstOrder, isNot(equals(differentBoardOrder)));
  });

  test(
    'build rejects fewer than five unique cards without a partial board',
    () {
      final List<MatchBoardCard> cards = <MatchBoardCard>[
        _card('item-1', 'card-1', '공부하다', 'to study'),
        _card('item-2', 'card-1', '공부하다', 'to study'),
        _card('item-3', 'card-2', '먹다', 'to eat'),
        _card('item-4', 'card-3', '하늘', 'sky'),
      ];

      expect(MatchBoardBuilder.canBuild(cards: cards), isFalse);
      expect(
        () => MatchBoardBuilder.build(
          sessionId: 'session-3',
          boardIndex: 0,
          cards: cards,
        ),
        throwsUnsupportedError,
      );
    },
  );
}
