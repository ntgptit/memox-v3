import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';

void main() {
  // Manual duplicate soft-warning behavior (WBS 2.20.1). Non-blocking:
  // create/update never reject; checkManualDuplicate reports the clash.
  // Decision row C40.
  group('FlashcardRepositoryImpl manual duplicate', () {
    late AppDatabase db;
    late FlashcardRepositoryImpl repo;
    late int clock;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      clock = 1000;
      repo = FlashcardRepositoryImpl(
        dao: FlashcardDao(db),
        deckDao: DeckDao(db),
        idGenerator: IdGenerator(Random(11)),
        nowMs: () => clock++,
      );
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder',
              name: 'Root',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'deck',
              folderId: 'folder',
              name: 'Deck',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
    });
    tearDown(() => db.close());

    test(
      'C40: front+back match (case/whitespace-insensitive) → duplicate',
      () async {
        final created = await repo.createFlashcard(
          deckId: 'deck',
          front: 'Apple',
          back: '사과',
        );

        final result = await repo.checkManualDuplicate(
          deckId: 'deck',
          front: '  apple ',
          back: '사과',
        );

        expect(result.isSuccess, isTrue);
        final FlashcardDuplicateCheckResult check = result.data!;
        expect(check.isDuplicate, isTrue);
        expect(check.matchingFlashcardIds, <String>[created.data!.id]);
      },
    );

    test('C40: different back is not a duplicate', () async {
      await repo.createFlashcard(deckId: 'deck', front: 'apple', back: '사과');

      final result = await repo.checkManualDuplicate(
        deckId: 'deck',
        front: 'apple',
        back: 'different',
      );

      expect(result.data!.isDuplicate, isFalse);
      expect(result.data!.matchingFlashcardIds, isEmpty);
    });

    test(
      'C40: matching front only (different back) is not a duplicate',
      () async {
        await repo.createFlashcard(deckId: 'deck', front: 'apple', back: '사과');

        final result = await repo.checkManualDuplicate(
          deckId: 'deck',
          front: 'apple',
          back: 'banana',
        );

        expect(result.data!.isDuplicate, isFalse);
      },
    );

    test('excludeId skips the card itself on edit', () async {
      final created = await repo.createFlashcard(
        deckId: 'deck',
        front: 'apple',
        back: '사과',
      );

      final result = await repo.checkManualDuplicate(
        deckId: 'deck',
        front: 'apple',
        back: '사과',
        excludeId: created.data!.id,
      );

      expect(result.data!.isDuplicate, isFalse);
    });

    test(
      'soft-warning never blocks: a duplicate front+back still saves',
      () async {
        await repo.createFlashcard(deckId: 'deck', front: 'apple', back: '사과');

        final result = await repo.createFlashcard(
          deckId: 'deck',
          front: 'apple',
          back: '사과',
        );

        // Create succeeds even though it duplicates an existing card.
        expect(result.isSuccess, isTrue);
        final cards = await FlashcardDao(db).flashcardsInDeck('deck');
        expect(cards, hasLength(2));
      },
    );

    test('duplicate check is scoped to the deck', () async {
      // A card with the same content in ANOTHER deck is not a duplicate.
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'deck2',
              folderId: 'folder',
              name: 'Other',
              sortOrder: 1,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await repo.createFlashcard(deckId: 'deck2', front: 'apple', back: '사과');

      final result = await repo.checkManualDuplicate(
        deckId: 'deck',
        front: 'apple',
        back: '사과',
      );

      expect(result.data!.isDuplicate, isFalse);
    });
  });
}
