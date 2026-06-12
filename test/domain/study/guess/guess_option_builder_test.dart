import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/study/guess/guess_option_builder.dart';
import 'package:memox/domain/study/modes/guess_study_mode_strategy.dart';

Flashcard _flashcard(
  String id,
  String front,
  String back, {
  String? hint,
  String? exampleSentence,
}) => Flashcard(
  id: id,
  deckId: 'deck-1',
  front: front,
  back: back,
  hint: hint,
  exampleSentence: exampleSentence,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  test('builds five deterministic options when enough candidates exist', () {
    const GuessStudyModeStrategy strategy = GuessStudyModeStrategy();
    final Flashcard current = _flashcard(
      'card-current',
      'front-current',
      'library',
      hint: 'Current hint',
    );
    final List<Flashcard> scopeCards = <Flashcard>[
      current,
      _flashcard('card-1', 'front-1', 'school', exampleSentence: 'School ex'),
      _flashcard('card-2', 'front-2', 'office', hint: 'Office hint'),
      _flashcard('card-3', 'front-3', 'hospital'),
      _flashcard('card-4', 'front-4', 'station'),
      _flashcard('card-5', 'front-5', 'bakery'),
    ];

    expect(
      GuessOptionBuilder.canBuild(current: current, scopeCards: scopeCards),
      isTrue,
    );
    final List<String> firstOrder = GuessOptionBuilder.build(
      sessionId: 'session-1',
      current: current,
      scopeCards: scopeCards,
    ).map((option) => option.flashcard.id).toList(growable: false);
    final List<String> secondOrder = strategy
        .buildOptions(
          sessionId: 'session-1',
          current: current,
          scopeCards: scopeCards.reversed,
        )
        .map((option) => option.flashcard.id)
        .toList(growable: false);

    expect(firstOrder, hasLength(5));
    expect(firstOrder, equals(secondOrder));
    expect(firstOrder, contains(current.id));
    expect(firstOrder.toSet(), hasLength(5));
  });

  test(
    'build rejects insufficient valid decoys without returning partial options',
    () {
      final Flashcard current = _flashcard('card-current', 'front', 'library');
      final List<Flashcard> scopeCards = <Flashcard>[
        current,
        _flashcard('card-1', 'front-1', 'library'),
        _flashcard('card-2', 'front-2', 'school'),
        _flashcard('card-3', 'front-3', '  school  '),
        _flashcard('card-4', 'front-4', ' '),
      ];

      expect(
        GuessOptionBuilder.canBuild(current: current, scopeCards: scopeCards),
        isFalse,
      );
      expect(
        () => GuessOptionBuilder.build(
          sessionId: 'session-2',
          current: current,
          scopeCards: scopeCards,
        ),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'duplicate backs can reduce valid decoys below four and make guess unavailable',
    () {
      final Flashcard current = _flashcard('card-current', 'front', 'library');
      final List<Flashcard> scopeCards = <Flashcard>[
        current,
        _flashcard('card-1', 'front-1', 'school'),
        _flashcard('card-2', 'front-2', ' school '),
        _flashcard('card-3', 'front-3', 'office'),
        _flashcard('card-4', 'front-4', 'office'),
        _flashcard('card-5', 'front-5', 'park'),
      ];

      expect(
        GuessOptionBuilder.canBuild(current: current, scopeCards: scopeCards),
        isFalse,
      );
      expect(
        () => GuessOptionBuilder.build(
          sessionId: 'session-3',
          current: current,
          scopeCards: scopeCards,
        ),
        throwsUnsupportedError,
      );
    },
  );

  test('build only includes the correct option when no valid decoys exist', () {
    final Flashcard current = _flashcard('card-current', 'front', 'library');
    final List<Flashcard> scopeCards = <Flashcard>[current];

    expect(
      GuessOptionBuilder.canBuild(current: current, scopeCards: scopeCards),
      isFalse,
    );
    expect(
      () => GuessOptionBuilder.build(
        sessionId: 'session-4',
        current: current,
        scopeCards: scopeCards,
      ),
      throwsUnsupportedError,
    );
  });
}
