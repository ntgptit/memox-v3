import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_tag_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/data/repositories/tag_repository_impl.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Tag management BE: WBS 8.3.1. Decision rows TG5/TG6/TG7
  // (`docs/decision-tables/tags-bulk-export.md`).
  group('TagRepositoryImpl', () {
    late AppDatabase db;
    late FlashcardTagDao tagDao;
    late FlashcardDao flashcardDao;
    late DeckDao deckDao;
    late FolderDao folderDao;
    late FlashcardRepositoryImpl flashcardRepo;
    late TagRepositoryImpl repo;
    late int clock;
    late String deckId;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      tagDao = FlashcardTagDao(db);
      flashcardDao = FlashcardDao(db);
      deckDao = DeckDao(db);
      folderDao = FolderDao(db);
      clock = 1000;
      final FolderRepositoryImpl folderRepo = FolderRepositoryImpl(
        dao: folderDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(1)),
        nowMs: () => clock++,
      );
      flashcardRepo = FlashcardRepositoryImpl(
        dao: flashcardDao,
        deckDao: deckDao,
        folderDao: folderDao,
        idGenerator: IdGenerator(Random(42)),
        nowMs: () => clock++,
      );
      repo = TagRepositoryImpl(dao: tagDao);
      final folder = await folderRepo.createRootFolder(name: 'F');
      final deck = await folderRepo.createDeck(
        folderId: folder.data!.id,
        name: 'D',
        targetLanguage: TargetLanguage.korean,
      );
      deckId = deck.data!.id;
    });
    tearDown(() => db.close());

    Future<String> addCard(List<String> tags) async {
      final card = await flashcardRepo.createFlashcard(
        deckId: deckId,
        front: 'F${clock++}',
        back: 'B',
        tags: tags,
      );
      return card.data!.id;
    }

    Future<List<String>> tagsOf(String cardId) async {
      final rows = await db.select(db.flashcardTags).get();
      return rows
          .where((r) => r.flashcardId == cardId)
          .map((r) => r.tag)
          .toList()
        ..sort();
    }

    test(
      'watchAllWithCount lists distinct tags ordered by count then name',
      () async {
        await addCard(<String>['grammar', 'weak']);
        await addCard(<String>['grammar']);

        final List<TagWithCount> tags = await repo.watchAllWithCount().first;

        expect(tags.map((t) => t.name).toList(), <String>['grammar', 'weak']);
        expect(tags.first.cardCount, 2);
        expect(tags[1].cardCount, 1);
      },
    );

    test(
      'rename updates every card and is case-insensitive no-op on equal',
      () async {
        final String c1 = await addCard(<String>['grammar']);
        final String c2 = await addCard(<String>['grammar']);

        final renamed = await repo.rename(
          normalizedOldName: 'grammar',
          normalizedNewName: 'syntax',
        );
        expect(renamed.isSuccess, isTrue);
        expect(await tagsOf(c1), <String>['syntax']);
        expect(await tagsOf(c2), <String>['syntax']);

        // No-op when names are equal.
        final noop = await repo.rename(
          normalizedOldName: 'syntax',
          normalizedNewName: 'syntax',
        );
        expect(noop.isSuccess, isTrue);
      },
    );

    test('rename onto an existing tag returns ConflictFailure', () async {
      await addCard(<String>['grammar']);
      await addCard(<String>['weak']);

      final result = await repo.rename(
        normalizedOldName: 'grammar',
        normalizedNewName: 'weak',
      );

      expect(result.failure, isA<ConflictFailure>());
      // Original rows untouched.
      final tags = await repo.watchAllWithCount().first;
      expect(tags.map((t) => t.name).toSet(), <String>{'grammar', 'weak'});
    });

    test(
      'merge re-tags source cards to destination, de-duped, source removed',
      () async {
        final String both = await addCard(<String>['grammar', 'syntax']);
        final String onlySource = await addCard(<String>['grammar']);

        final result = await repo.merge(
          normalizedSource: 'grammar',
          normalizedDestination: 'syntax',
        );

        expect(result.isSuccess, isTrue);
        expect(result.data, isA<MergeResult>());
        expect(result.data!.destination, 'syntax');
        expect(result.data!.affectedCardCount, 2);
        // No card keeps the source tag; de-dup leaves a single 'syntax' each.
        expect(await tagsOf(both), <String>['syntax']);
        expect(await tagsOf(onlySource), <String>['syntax']);
        final tags = await repo.watchAllWithCount().first;
        expect(tags.map((t) => t.name).toList(), <String>['syntax']);
        expect(tags.first.cardCount, 2);
      },
    );

    test('delete removes the tag from all cards but keeps the cards', () async {
      final String c1 = await addCard(<String>['grammar', 'weak']);
      await addCard(<String>['grammar']);

      final result = await repo.delete('grammar');

      expect(result.isSuccess, isTrue);
      expect(result.data, 2); // affected card count
      expect(await tagsOf(c1), <String>['weak']); // card + other tag survive
      expect(await flashcardDao.findFlashcardById(c1), isNotNull);
      final tags = await repo.watchAllWithCount().first;
      expect(tags.map((t) => t.name).toList(), <String>['weak']);
    });

    test('existsCaseInsensitive reports presence', () async {
      await addCard(<String>['grammar']);

      expect((await repo.existsCaseInsensitive('grammar')).data, isTrue);
      expect((await repo.existsCaseInsensitive('missing')).data, isFalse);
    });
  });
}
