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
  // F13 (recursive card count incl. all cards; due count excludes NEW cards,
  // future-scheduled cards, and suspended / currently-buried cards — mirroring
  // the `study_scope_queries.drift` eligibility predicate).
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
  Future<String> addCard(
    String deckId, {
    int? dueAt,
    bool suspended = false,
    int? buriedUntil,
    int box = 1,
  }) async {
    final card = await flashcardRepo.createFlashcard(
      deckId: deckId,
      front: 'F${cardSeq++}',
      back: 'B',
    );
    final String id = card.data!.id;
    await db.customStatement(
      'UPDATE flashcard_progress SET due_at = ?, is_suspended = ?, '
      'buried_until = ?, box_number = ? WHERE flashcard_id = ?',
      <Object?>[dueAt, suspended ? 1 : 0, buriedUntil, box, id],
    );
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

  test('F13: due count excludes suspended and currently-buried cards but '
      'card count still includes them', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Lang',
    )).data!.id;
    final String deckId = (await repo.createDeck(
      folderId: folderId,
      name: 'Vocab',
      targetLanguage: TargetLanguage.korean,
    )).data!.id;

    await addCard(deckId, dueAt: fixedNow - 1); // due + active
    await addCard(
      deckId,
      dueAt: fixedNow - 1,
      suspended: true,
    ); // due but suspended
    await addCard(
      deckId,
      dueAt: fixedNow - 1,
      buriedUntil: fixedNow + 5000,
    ); // due but currently buried (buried_until > now)
    await addCard(
      deckId,
      dueAt: fixedNow - 1,
      buriedUntil: fixedNow - 1,
    ); // due, bury expired (buried_until <= now) → still due

    final FolderDetail detail = (await repo.watchFolderDetail(folderId).first)!;
    expect(detail.cardCount, 4); // F13: card count includes suspended/buried
    expect(detail.dueCount, 2); // active due + expired-bury due only

    final LibraryOverview overview = await repo.watchLibraryOverview().first;
    final FolderSummary summary = overview.folders.firstWhere(
      (FolderSummary f) => f.folder.id == folderId,
    );
    expect(summary.cardCount, 4);
    expect(summary.dueCount, 2); // root summary applies the same exclusion

    // folderDeckSummaries (deck tile due count) applies the exclusion too.
    final FolderDetail detailWithDecks = (await repo
        .watchFolderDetail(folderId)
        .first)!;
    expect(detailWithDecks.decks.single.dueCount, 2);
  });

  test('F13: childFolderSummaries (subfolder rows) exclude suspended/buried '
      'from due count', () async {
    // Parent → subfolder → deck. The parent-detail child-row summary is driven
    // by childFolderSummaries; assert its recursive due count applies F13.
    final String parentId = (await repo.createRootFolder(
      name: 'Parent',
    )).data!.id;
    final String subId = (await repo.createSubfolder(
      parentId: parentId,
      name: 'Sub',
    )).data!.id;
    final String deckId = (await repo.createDeck(
      folderId: subId,
      name: 'Deck',
      targetLanguage: TargetLanguage.korean,
    )).data!.id;
    await addCard(deckId, dueAt: fixedNow - 1); // active due
    await addCard(deckId, dueAt: fixedNow - 1, suspended: true); // excluded
    await addCard(
      deckId,
      dueAt: fixedNow - 1,
      buriedUntil: fixedNow + 5000,
    ); // currently buried → excluded

    final FolderDetail parentDetail = (await repo
        .watchFolderDetail(parentId)
        .first)!;
    final FolderSummary childRow = parentDetail.subfolders.single;
    expect(childRow.folder.id, subId);
    expect(childRow.cardCount, 3); // all cards incl. suspended/buried
    expect(childRow.dueCount, 1); // only the active due card
  });

  test('counts are zero for an empty folder', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Empty',
    )).data!.id;

    final FolderDetail detail = (await repo.watchFolderDetail(folderId).first)!;

    expect(detail.deckCount, 0);
    expect(detail.cardCount, 0);
    expect(detail.dueCount, 0);
  });

  test('newCount = active NEW cards (due_at NULL) excluding suspended; '
      'mastery = mean box / 8', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Lang',
    )).data!.id;
    final String deckId = (await repo.createDeck(
      folderId: folderId,
      name: 'Vocab',
      targetLanguage: TargetLanguage.korean,
    )).data!.id;

    await addCard(deckId, dueAt: fixedNow - 1, box: 2); // studied/due
    await addCard(deckId, dueAt: fixedNow + 5000, box: 6); // scheduled future
    await addCard(deckId, box: 4); // NEW (due_at NULL), active
    await addCard(
      deckId,
      box: 8,
      suspended: true,
    ); // NEW but suspended → not new
    await addCard(
      deckId,
      box: 3,
      buriedUntil: fixedNow + 5000,
    ); // NEW but currently buried → not new

    final LibraryOverview overview = await repo.watchLibraryOverview().first;
    final FolderSummary summary = overview.folders.firstWhere(
      (FolderSummary f) => f.folder.id == folderId,
    );

    expect(summary.newCount, 1); // only the active box-4 NEW card
    // mean box over all 5 cards = (2 + 6 + 4 + 8 + 3) / 5 = 4.6 → mastery 4.6/8.
    expect(summary.mastery, closeTo(4.6 / 8, 1e-9));
  });

  test('mastery is null and newCount 0 for a folder with no cards', () async {
    final String folderId = (await repo.createRootFolder(
      name: 'Empty',
    )).data!.id;
    await repo.createDeck(
      folderId: folderId,
      name: 'EmptyDeck',
      targetLanguage: TargetLanguage.korean,
    );

    final LibraryOverview overview = await repo.watchLibraryOverview().first;
    final FolderSummary summary = overview.folders.firstWhere(
      (FolderSummary f) => f.folder.id == folderId,
    );

    expect(summary.newCount, 0);
    expect(summary.mastery, isNull);
  });
}
