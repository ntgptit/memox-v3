import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Flashcard CRUD contract: WBS 2.11.1 (create), 2.12.1 (update), 2.13.1
  // (delete), 2.14.1 (reorder), 3.4.1 (list load). Decision rows C1, C2, C3,
  // C5, C6, C8, C33, C34, C35 (`docs/decision-tables/flashcard.md`).
  group('FlashcardRepositoryImpl', () {
    late AppDatabase db;
    late FlashcardDao flashcardDao;
    late DeckDao deckDao;
    late FolderDao folderDao;
    late FolderRepositoryImpl folderRepo;
    late FlashcardRepositoryImpl repo;
    late int clock;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      flashcardDao = FlashcardDao(db);
      deckDao = DeckDao(db);
      folderDao = FolderDao(db);
      clock = 1000;
      folderRepo = FolderRepositoryImpl(
        dao: folderDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(1)),
        nowMs: () => clock++,
      );
      repo = FlashcardRepositoryImpl(
        dao: flashcardDao,
        deckDao: deckDao,
        folderDao: folderDao,
        idGenerator: IdGenerator(Random(42)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<String> newDeck() async {
      final folder = await folderRepo.createRootFolder(name: 'F${clock++}');
      final deck = await folderRepo.createDeck(
        folderId: folder.data!.id,
        name: 'Deck${clock++}',
        targetLanguage: TargetLanguage.korean,
      );
      return deck.data!.id;
    }

    test(
      'C1: creates a card with initial progress + tags transactionally',
      () async {
        final String deckId = await newDeck();

        final result = await repo.createFlashcard(
          deckId: deckId,
          front: '  Hello  ',
          back: '  Xin chao  ',
          exampleSentence: '  Hi  ',
          pronunciation: '   ',
          hint: '',
          tags: const <String>['Greeting', 'greeting', ' Casual '],
        );

        final Flashcard card = result.data!;
        expect(card.front, 'Hello');
        expect(card.back, 'Xin chao');
        expect(card.exampleSentence, 'Hi');
        expect(card.pronunciation, isNull, reason: 'blank → null');
        expect(card.hint, isNull, reason: 'empty → null');
        expect(card.tags, const <String>[
          'greeting',
          'casual',
        ], reason: 'lowercased + deduped case-insensitively');
        expect(card.sortOrder, 0);

        final progress = await flashcardDao.findProgress(card.id);
        expect(progress, isNotNull);
        expect(progress!.boxNumber, 1);
        expect(progress.dueAt, isNull, reason: 'NEW card unscheduled');
        expect(progress.reviewCount, 0);
        expect(progress.lapseCount, 0);

        final tags = await flashcardDao.tagsForFlashcards(<String>[card.id]);
        expect(tags.map((t) => t.tag).toSet(), <String>{'greeting', 'casual'});
      },
    );

    test('C2: rejects blank front after trim', () async {
      final String deckId = await newDeck();
      final result = await repo.createFlashcard(
        deckId: deckId,
        front: '   ',
        back: 'B',
      );
      expect(result.failure, isA<ValidationFailure>());
      final ValidationFailure f = result.failure! as ValidationFailure;
      expect(f.field, 'front');
      expect(f.code, ValidationCode.empty);
    });

    test('C3: rejects blank back after trim', () async {
      final String deckId = await newDeck();
      final result = await repo.createFlashcard(
        deckId: deckId,
        front: 'F',
        back: '  ',
      );
      final ValidationFailure f = result.failure! as ValidationFailure;
      expect(f.field, 'back');
      expect(f.code, ValidationCode.empty);
    });

    test('C8: missing deck yields NotFoundFailure', () async {
      final result = await repo.createFlashcard(
        deckId: 'nope',
        front: 'F',
        back: 'B',
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('appends sort_order after existing cards', () async {
      final String deckId = await newDeck();
      await repo.createFlashcard(deckId: deckId, front: 'a', back: '1');
      final second = await repo.createFlashcard(
        deckId: deckId,
        front: 'b',
        back: '2',
      );
      expect(second.data!.sortOrder, 1);
    });

    test('C5: update replaces tags and keeps progress by default', () async {
      final String deckId = await newDeck();
      final created = await repo.createFlashcard(
        deckId: deckId,
        front: 'a',
        back: '1',
        tags: const <String>['old'],
      );
      final String id = created.data!.id;
      // Simulate learned progress.
      await flashcardDao.updateProgressColumns(
        id,
        const FlashcardProgressCompanion(
          boxNumber: Value(3),
          reviewCount: Value(5),
        ),
      );

      final updated = await repo.updateFlashcard(
        flashcardId: id,
        front: 'a2',
        back: '1b',
        tags: const <String>['New', 'new'],
      );

      expect(updated.data!.front, 'a2');
      expect(updated.data!.tags, const <String>['new']);
      final tags = await flashcardDao.tagsForFlashcards(<String>[id]);
      expect(tags.map((t) => t.tag).toList(), const <String>['new']);

      final progress = await flashcardDao.findProgress(id);
      expect(progress!.boxNumber, 3, reason: 'keepProgress preserves box');
      expect(progress.reviewCount, 5);
    });

    test('C5: resetProgress returns the card to the fresh state', () async {
      final String deckId = await newDeck();
      final created = await repo.createFlashcard(
        deckId: deckId,
        front: 'a',
        back: '1',
      );
      final String id = created.data!.id;
      await flashcardDao.updateProgressColumns(
        id,
        const FlashcardProgressCompanion(
          boxNumber: Value(4),
          dueAt: Value(99999),
          reviewCount: Value(7),
          lapseCount: Value(2),
        ),
      );

      await repo.updateFlashcard(
        flashcardId: id,
        front: 'a',
        back: '1',
        progressPolicy: FlashcardProgressEditPolicy.resetProgress,
      );

      final progress = await flashcardDao.findProgress(id);
      expect(progress!.boxNumber, 1);
      expect(progress.dueAt, isNull);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
    });

    test('update of a missing card yields NotFoundFailure', () async {
      final result = await repo.updateFlashcard(
        flashcardId: 'nope',
        front: 'a',
        back: 'b',
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('C6: delete removes the card and cascades progress + tags', () async {
      final String deckId = await newDeck();
      final created = await repo.createFlashcard(
        deckId: deckId,
        front: 'a',
        back: '1',
        tags: const <String>['t'],
      );
      final String id = created.data!.id;

      final result = await repo.deleteFlashcard(flashcardId: id);
      expect(result.isSuccess, isTrue);
      expect(await flashcardDao.findFlashcardById(id), isNull);
      expect(
        await flashcardDao.findProgress(id),
        isNull,
        reason: 'progress cascades',
      );
      expect(
        await flashcardDao.tagsForFlashcards(<String>[id]),
        isEmpty,
        reason: 'tags cascade',
      );
    });

    test('delete of a missing card yields NotFoundFailure', () async {
      final result = await repo.deleteFlashcard(flashcardId: 'nope');
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('C33: reorder writes sort_order by list position', () async {
      final String deckId = await newDeck();
      final a = (await repo.createFlashcard(
        deckId: deckId,
        front: 'a',
        back: '1',
      )).data!;
      final b = (await repo.createFlashcard(
        deckId: deckId,
        front: 'b',
        back: '2',
      )).data!;
      final c = (await repo.createFlashcard(
        deckId: deckId,
        front: 'c',
        back: '3',
      )).data!;

      final result = await repo.reorderFlashcards(
        deckId: deckId,
        orderedIds: <String>[c.id, a.id, b.id],
      );
      expect(result.isSuccess, isTrue);

      final cards = await flashcardDao.flashcardsInDeck(deckId);
      expect(cards.map((r) => r.id).toList(), <String>[c.id, a.id, b.id]);
      expect(cards.map((r) => r.sortOrder).toList(), <int>[0, 1, 2]);
    });

    test(
      'C34: reorder rejects a non-matching list and preserves order',
      () async {
        final String deckId = await newDeck();
        final a = (await repo.createFlashcard(
          deckId: deckId,
          front: 'a',
          back: '1',
        )).data!;
        final b = (await repo.createFlashcard(
          deckId: deckId,
          front: 'b',
          back: '2',
        )).data!;

        // Partial list (missing b).
        final partial = await repo.reorderFlashcards(
          deckId: deckId,
          orderedIds: <String>[a.id],
        );
        expect(
          (partial.failure! as ValidationFailure).code,
          ValidationCode.invalidFormat,
        );

        // Duplicate id.
        final dup = await repo.reorderFlashcards(
          deckId: deckId,
          orderedIds: <String>[a.id, a.id],
        );
        expect(dup.failure, isA<ValidationFailure>());

        // Order unchanged.
        final cards = await flashcardDao.flashcardsInDeck(deckId);
        expect(cards.map((r) => r.id).toList(), <String>[a.id, b.id]);
      },
    );

    test('C35: watch emits deck + breadcrumb + cards + totalCount', () async {
      final String deckId = await newDeck();
      await repo.createFlashcard(deckId: deckId, front: 'apple', back: 'tao');
      await repo.createFlashcard(
        deckId: deckId,
        front: 'banana',
        back: 'chuoi',
      );

      final FlashcardListDetail detail =
          (await repo.watchFlashcardList(deckId).first).data!;
      expect(detail.deck.id, deckId);
      expect(detail.breadcrumb, isNotEmpty);
      expect(detail.cards.length, 2);
      expect(detail.totalCount, 2);
    });

    test(
      'C35: search filters cards but totalCount stays the full deck total',
      () async {
        final String deckId = await newDeck();
        await repo.createFlashcard(deckId: deckId, front: 'apple', back: 'tao');
        await repo.createFlashcard(
          deckId: deckId,
          front: 'banana',
          back: 'chuoi',
        );

        final FlashcardListDetail detail =
            (await repo.watchFlashcardList(deckId, searchTerm: 'APP').first)
                .data!;
        expect(detail.cards.length, 1);
        expect(detail.cards.single.front, 'apple');
        expect(
          detail.totalCount,
          2,
          reason: 'totalCount independent of search → no-results detectable',
        );
      },
    );

    test('C35: watch on a missing deck yields NotFoundFailure', () async {
      // No card stream rows for a nonexistent deck — but the stream still emits
      // once with an empty list, mapping to a NotFound result.
      final result = await repo.watchFlashcardList('nope').first;
      expect(result.failure, isA<NotFoundFailure>());
    });

    test(
      'C38: empty tag filter returns all cards; multi-tag uses AND',
      () async {
        final String deckId = await newDeck();
        await repo.createFlashcard(
          deckId: deckId,
          front: 'a',
          back: '1',
          tags: const <String>['grammar', 'weak'],
        );
        await repo.createFlashcard(
          deckId: deckId,
          front: 'b',
          back: '2',
          tags: const <String>['grammar'],
        );
        await repo.createFlashcard(deckId: deckId, front: 'c', back: '3');

        // Empty filter → all cards.
        final empty =
            (await repo
                    .watchFlashcardList(deckId, tags: const <String>[])
                    .first)
                .data!;
        expect(empty.cards.length, 3);

        // Single tag → deck-scoped subset.
        final single =
            (await repo
                    .watchFlashcardList(deckId, tags: const <String>['grammar'])
                    .first)
                .data!;
        expect(single.cards.map((c) => c.front).toSet(), <String>{'a', 'b'});

        // Multi-tag AND (trim + case normalized to match storage) → only the
        // card carrying both.
        final both =
            (await repo
                    .watchFlashcardList(
                      deckId,
                      tags: const <String>[' Grammar ', 'WEAK'],
                    )
                    .first)
                .data!;
        expect(both.cards.map((c) => c.front).toList(), <String>['a']);
      },
    );

    test(
      'C39: tag filter composes with search; totalCount stays full deck',
      () async {
        final String deckId = await newDeck();
        await repo.createFlashcard(
          deckId: deckId,
          front: 'apple',
          back: '1',
          tags: const <String>['fruit'],
        );
        await repo.createFlashcard(
          deckId: deckId,
          front: 'apricot',
          back: '2',
          tags: const <String>['fruit'],
        );
        await repo.createFlashcard(
          deckId: deckId,
          front: 'apple',
          back: '3',
          tags: const <String>['veg'],
        );

        final detail =
            (await repo
                    .watchFlashcardList(
                      deckId,
                      searchTerm: 'apple',
                      tags: const <String>['fruit'],
                    )
                    .first)
                .data!;
        // front contains 'apple' AND tagged 'fruit' → only the first card.
        expect(detail.cards.map((c) => c.back).toList(), <String>['1']);
        expect(detail.totalCount, 3); // full deck total, filter-independent

        // No-results case still reports the full deck total.
        final none =
            (await repo
                    .watchFlashcardList(deckId, tags: const <String>['missing'])
                    .first)
                .data!;
        expect(none.cards, isEmpty);
        expect(none.totalCount, 3);
      },
    );
  });
}
