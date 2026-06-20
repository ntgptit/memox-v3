import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Folder/deck due+card counts: WBS 3.7.1. Decision rows F12 (deck count) and
  // F13 (recursive card count incl. all cards; due count excludes NEW cards and
  // future-scheduled cards). Suspend/bury columns do not exist yet, so their
  // exclusion is trivially satisfied.
  const int fixedNow = 1000000;

  late AppDatabase db;
  late FolderDao folderDao;
  late DeckDao deckDao;
  late FlashcardDao flashcardDao;
  late FolderRepositoryImpl repo;
  late FlashcardRepositoryImpl flashcardRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    folderDao = FolderDao(db);
    deckDao = DeckDao(db);
    flashcardDao = FlashcardDao(db);
    repo = FolderRepositoryImpl(
      dao: folderDao,
      deckDao: deckDao,
      idGenerator: IdGenerator(Random(11)),
      nowMs: () => fixedNow,
    );
    flashcardRepo = FlashcardRepositoryImpl(
      dao: flashcardDao,
      deckDao: deckDao,
      folderDao: folderDao,
      idGenerator: IdGenerator(Random(99)),
      nowMs: () => fixedNow,
    );
  });
  tearDown(() => db.close());

  int cardSeq = 0;
  Future<String> addCard(String deckId, {int? dueAt}) async {
    final card = await flashcardRepo.createFlashcard(
      deckId: deckId,
      front: 'F${cardSeq++}',
      back: 'B',
    );
    final String id = card.data!.id;
    if (dueAt != null) {
      await db.customStatement(
        'UPDATE flashcard_progress SET due_at = ? WHERE flashcard_id = ?',
        <Object>[dueAt, id],
      );
    }
    return id;
  }

  test('F12/F13: folder detail reports direct deck count and recursive '
      'card/due counts', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Lang',
    )).data!.id;
    final String deckId = (await repo.createDeck(
      folderId: folderId,
      name: 'Vocab',
      targetLanguage: TargetLanguage.korean,
    )).data!.id;

    await addCard(deckId, dueAt: fixedNow - 1); // due (past)
    await addCard(deckId, dueAt: fixedNow); // due (exactly now)
    await addCard(deckId, dueAt: fixedNow + 5000); // scheduled future, not due
    await addCard(deckId); // NEW (due_at NULL), not due

    final FolderDetail detail = (await repo.watchFolderDetail(folderId).first)!;

    expect(detail.deckCount, 1);
    expect(detail.cardCount, 4); // all cards incl. NEW + future
    expect(detail.dueCount, 2); // only the two due_at <= now
  });

  test(
    'F13: card/due counts roll up recursively from descendant folders',
    () async {
      // Root holds a subfolder (locks root to subfolders), the subfolder holds a
      // deck with cards. The root's counts must aggregate the subtree.
      final String rootId = (await repo.createRootFolder(
        name: 'Root',
      )).data!.id;
      final String subId = (await repo.createSubfolder(
        parentId: rootId,
        name: 'Sub',
      )).data!.id;
      final String deckId = (await repo.createDeck(
        folderId: subId,
        name: 'Deck',
        targetLanguage: TargetLanguage.korean,
      )).data!.id;
      await addCard(deckId, dueAt: fixedNow - 1); // due
      await addCard(deckId); // NEW

      final LibraryOverview overview = await repo.watchLibraryOverview().first;
      final FolderSummary rootSummary = overview.folders.firstWhere(
        (FolderSummary f) => f.folder.id == rootId,
      );

      expect(rootSummary.subfolderCount, 1);
      expect(rootSummary.deckCount, 0); // no DIRECT decks under root
      expect(rootSummary.cardCount, 2); // recursive from the subfolder's deck
      expect(rootSummary.dueCount, 1);
    },
  );

  test('counts are zero for an empty folder', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Empty',
    )).data!.id;

    final FolderDetail detail = (await repo.watchFolderDetail(folderId).first)!;

    expect(detail.deckCount, 0);
    expect(detail.cardCount, 0);
    expect(detail.dueCount, 0);
  });
}
