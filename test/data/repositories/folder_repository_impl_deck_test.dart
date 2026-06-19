import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Deck mutation contract: WBS 2.7.1 (create), 2.8.1 (rename), 2.10.1
  // (reorder). Decision rows D1, D2, D4, D6, D7, D8 (`docs/decision-tables/deck.md`).
  group('FolderRepositoryImpl deck mutations', () {
    late AppDatabase db;
    late FolderDao folderDao;
    late DeckDao deckDao;
    late FolderRepositoryImpl repo;
    late int clock;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      folderDao = FolderDao(db);
      deckDao = DeckDao(db);
      clock = 1000;
      repo = FolderRepositoryImpl(
        dao: folderDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(42)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<String> newFolder({ContentMode? mode}) async {
      final result = await repo.createRootFolder(name: 'F${clock++}');
      final String id = result.data!.id;
      if (mode != null && mode != ContentMode.unlocked) {
        await folderDao.updateFolderColumns(
          id,
          FoldersCompanion(
            contentMode: Value(FolderMapper.contentModeToStorage(mode)),
          ),
        );
      }
      return id;
    }

    Future<ContentMode> modeOf(String id) async {
      final FolderRow row = (await folderDao.findFolderById(id))!;
      return FolderMapper.contentModeFromStorage(row.contentMode);
    }

    test('D1: creates a deck and locks an unlocked folder to decks', () async {
      final String folderId = await newFolder();

      final result = await repo.createDeck(
        folderId: folderId,
        name: '  Verbs  ',
        targetLanguage: TargetLanguage.english,
      );

      expect(result.isSuccess, isTrue);
      final Deck deck = result.data!;
      expect(deck.name, 'Verbs'); // trimmed
      expect(deck.folderId, folderId);
      expect(deck.targetLanguage, TargetLanguage.english);
      expect(deck.sortOrder, 0);
      expect(await deckDao.findDeckById(deck.id), isNotNull);
      expect(await modeOf(folderId), ContentMode.decks);
    });

    test('D1: appends sort_order for subsequent decks', () async {
      final String folderId = await newFolder();
      final a = await repo.createDeck(
        folderId: folderId,
        name: 'A',
        targetLanguage: TargetLanguage.korean,
      );
      final b = await repo.createDeck(
        folderId: folderId,
        name: 'B',
        targetLanguage: TargetLanguage.korean,
      );

      expect(a.data!.sortOrder, 0);
      expect(b.data!.sortOrder, 1);
    });

    test('D2: rejects an empty/whitespace name and persists nothing', () async {
      final String folderId = await newFolder();

      final result = await repo.createDeck(
        folderId: folderId,
        name: '   ',
        targetLanguage: TargetLanguage.korean,
      );

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.empty,
        ),
      );
      expect(await deckDao.decksInFolder(folderId), isEmpty);
      expect(await modeOf(folderId), ContentMode.unlocked);
    });

    test('rejects a case-insensitive duplicate deck name', () async {
      final String folderId = await newFolder();
      await repo.createDeck(
        folderId: folderId,
        name: 'Nouns',
        targetLanguage: TargetLanguage.korean,
      );
      final dup = await repo.createDeck(
        folderId: folderId,
        name: 'nouns',
        targetLanguage: TargetLanguage.korean,
      );

      expect(
        dup.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('rejects create in a missing folder', () async {
      final result = await repo.createDeck(
        folderId: 'nope',
        name: 'A',
        targetLanguage: TargetLanguage.korean,
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test(
      'a subfolders-locked folder rejects a deck (folder_contains_subfolders)',
      () async {
        final String folderId = await newFolder(mode: ContentMode.subfolders);

        final result = await repo.createDeck(
          folderId: folderId,
          name: 'A',
          targetLanguage: TargetLanguage.korean,
        );

        expect(
          result.failure,
          isA<UnsupportedActionFailure>().having(
            (UnsupportedActionFailure f) => f.message,
            'message',
            'folder_contains_subfolders',
          ),
        );
        expect(await deckDao.decksInFolder(folderId), isEmpty);
      },
    );

    test('D6: renames a deck, preserving folder and sort_order', () async {
      final String folderId = await newFolder();
      final created = await repo.createDeck(
        folderId: folderId,
        name: 'Old',
        targetLanguage: TargetLanguage.korean,
      );

      final result = await repo.renameDeck(
        deckId: created.data!.id,
        newName: '  New  ',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.name, 'New');
      expect(result.data!.folderId, folderId);
      expect(result.data!.sortOrder, created.data!.sortOrder);
    });

    test('D6: rename to the same trimmed name is a no-op success', () async {
      final String folderId = await newFolder();
      final created = await repo.createDeck(
        folderId: folderId,
        name: 'Same',
        targetLanguage: TargetLanguage.korean,
      );

      final result = await repo.renameDeck(
        deckId: created.data!.id,
        newName: 'Same',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.name, 'Same');
    });

    test('D7: rejects a blank rename', () async {
      final String folderId = await newFolder();
      final created = await repo.createDeck(
        folderId: folderId,
        name: 'Keep',
        targetLanguage: TargetLanguage.korean,
      );

      final result = await repo.renameDeck(
        deckId: created.data!.id,
        newName: '   ',
      );

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.empty,
        ),
      );
      final DeckRow row = (await deckDao.findDeckById(created.data!.id))!;
      expect(row.name, 'Keep');
    });

    test('rejects a rename onto a sibling name', () async {
      final String folderId = await newFolder();
      await repo.createDeck(
        folderId: folderId,
        name: 'Alpha',
        targetLanguage: TargetLanguage.korean,
      );
      final beta = await repo.createDeck(
        folderId: folderId,
        name: 'Beta',
        targetLanguage: TargetLanguage.korean,
      );

      final result = await repo.renameDeck(
        deckId: beta.data!.id,
        newName: 'alpha',
      );

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('rename of a missing deck returns notFound', () async {
      final result = await repo.renameDeck(deckId: 'nope', newName: 'X');
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('D4: reorder writes sort_order by list position', () async {
      final String folderId = await newFolder();
      final a = await repo.createDeck(
        folderId: folderId,
        name: 'A',
        targetLanguage: TargetLanguage.korean,
      );
      final b = await repo.createDeck(
        folderId: folderId,
        name: 'B',
        targetLanguage: TargetLanguage.korean,
      );

      final result = await repo.reorderDecks(
        folderId: folderId,
        orderedIds: <String>[b.data!.id, a.data!.id],
      );

      expect(result.isSuccess, isTrue);
      expect(
        DeckMapper.fromRow((await deckDao.findDeckById(b.data!.id))!).sortOrder,
        0,
      );
      expect(
        DeckMapper.fromRow((await deckDao.findDeckById(a.data!.id))!).sortOrder,
        1,
      );
    });

    test('D8: reorder rejects a partial/duplicate/cross-folder list', () async {
      final String folderId = await newFolder();
      final a = await repo.createDeck(
        folderId: folderId,
        name: 'A',
        targetLanguage: TargetLanguage.korean,
      );
      await repo.createDeck(
        folderId: folderId,
        name: 'B',
        targetLanguage: TargetLanguage.korean,
      );

      final partial = await repo.reorderDecks(
        folderId: folderId,
        orderedIds: <String>[a.data!.id],
      );
      final duplicate = await repo.reorderDecks(
        folderId: folderId,
        orderedIds: <String>[a.data!.id, a.data!.id],
      );

      for (final result in <dynamic>[partial, duplicate]) {
        expect(
          result.failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.invalidFormat,
          ),
        );
      }
    });
  });
}
