import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/domain/entities/flashcard.dart';

void main() {
  // FlashcardRepositoryImpl create/update + parent-child validation (WBS 2.11.1
  // / 2.12.1 / 2.16.1). Decision rows C1, C2, C3, C8, C41.
  group('FlashcardRepositoryImpl', () {
    late AppDatabase db;
    late DeckDao deckDao;
    late FlashcardDao flashcardDao;
    late FlashcardRepositoryImpl repo;
    late int clock;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      deckDao = DeckDao(db);
      flashcardDao = FlashcardDao(db);
      clock = 1000;
      repo = FlashcardRepositoryImpl(
        dao: flashcardDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(7)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<String> seedDeck() async {
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
      return 'deck';
    }

    test(
      'C1: creates a flashcard, trims content, blank optional → null',
      () async {
        final String deckId = await seedDeck();

        final result = await repo.createFlashcard(
          deckId: deckId,
          front: '  Hello  ',
          back: '  안녕  ',
          exampleSentence: '   ',
          pronunciation: 'annyeong',
        );

        expect(result.isSuccess, isTrue);
        final Flashcard card = result.data!;
        expect(card.front, 'Hello');
        expect(card.back, '안녕');
        expect(card.exampleSentence, isNull); // blank → null
        expect(card.pronunciation, 'annyeong');
        expect(card.isFlagged, isFalse);
        expect(card.sortOrder, 0);
        expect(await flashcardDao.findFlashcardById(card.id), isNotNull);
      },
    );

    test('C1: appends sort_order for subsequent cards', () async {
      final String deckId = await seedDeck();
      await repo.createFlashcard(deckId: deckId, front: 'a', back: '1');
      final second = await repo.createFlashcard(
        deckId: deckId,
        front: 'b',
        back: '2',
      );
      expect(second.data!.sortOrder, 1);
    });

    test(
      'C2: empty-after-trim front → ValidationFailure(front, empty)',
      () async {
        final String deckId = await seedDeck();

        final result = await repo.createFlashcard(
          deckId: deckId,
          front: '   ',
          back: 'back',
        );

        expect(result.failure, isA<ValidationFailure>());
        final ValidationFailure failure = result.failure! as ValidationFailure;
        expect(failure.field, 'front');
        expect(failure.code, ValidationCode.empty);
      },
    );

    test(
      'C3: empty-after-trim back → ValidationFailure(back, empty)',
      () async {
        final String deckId = await seedDeck();

        final result = await repo.createFlashcard(
          deckId: deckId,
          front: 'front',
          back: '   ',
        );

        final ValidationFailure failure = result.failure! as ValidationFailure;
        expect(failure.field, 'back');
        expect(failure.code, ValidationCode.empty);
      },
    );

    test('C41: create under a missing deck → NotFoundFailure(deck)', () async {
      final result = await repo.createFlashcard(
        deckId: 'ghost',
        front: 'front',
        back: 'back',
      );

      expect(result.failure, isA<NotFoundFailure>());
      expect((result.failure! as NotFoundFailure).entity, 'deck');
    });

    test('C41: created flashcard always references its parent deck', () async {
      final String deckId = await seedDeck();
      final result = await repo.createFlashcard(
        deckId: deckId,
        front: 'front',
        back: 'back',
      );
      expect(result.data!.deckId, deckId);
    });

    test('C2: update edits content and preserves deck + sort_order', () async {
      final String deckId = await seedDeck();
      final created = await repo.createFlashcard(
        deckId: deckId,
        front: 'old',
        back: 'old',
      );
      final String id = created.data!.id;

      final result = await repo.updateFlashcard(
        id: id,
        front: ' new front ',
        back: 'new back',
        hint: '',
      );

      expect(result.isSuccess, isTrue);
      final Flashcard card = result.data!;
      expect(card.front, 'new front');
      expect(card.back, 'new back');
      expect(card.hint, isNull);
      expect(card.deckId, deckId);
      expect(card.sortOrder, created.data!.sortOrder);
    });

    test('C3: update with empty front → ValidationFailure', () async {
      final String deckId = await seedDeck();
      final created = await repo.createFlashcard(
        deckId: deckId,
        front: 'a',
        back: 'b',
      );

      final result = await repo.updateFlashcard(
        id: created.data!.id,
        front: '  ',
        back: 'b',
      );

      expect(result.failure, isA<ValidationFailure>());
    });

    test('update on a missing card → NotFoundFailure(flashcard)', () async {
      final result = await repo.updateFlashcard(
        id: 'ghost',
        front: 'a',
        back: 'b',
      );
      expect(result.failure, isA<NotFoundFailure>());
      expect((result.failure! as NotFoundFailure).entity, 'flashcard');
    });

    test(
      'deck delete cascades to its flashcards (FK ON DELETE CASCADE)',
      () async {
        final String deckId = await seedDeck();
        final created = await repo.createFlashcard(
          deckId: deckId,
          front: 'a',
          back: 'b',
        );
        await deckDao.deleteDeckById(deckId);
        expect(await flashcardDao.findFlashcardById(created.data!.id), isNull);
      },
    );
  });
}
