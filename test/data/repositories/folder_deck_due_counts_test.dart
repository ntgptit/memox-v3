import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';

class _CountFixture {
  _CountFixture(this.db, {DateTime? now}) : _now = now ?? DateTime.now();

  final AppDatabase db;
  final DateTime _now;

  int get nowMs => _now.toUtc().millisecondsSinceEpoch;

  Future<void> insertRootFolder({
    required String id,
    String contentMode = 'subfolders',
  }) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          name: 'Folder $id',
          contentMode: Value<String>(contentMode),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

  Future<void> insertSubfolder({
    required String id,
    required String parentId,
    String contentMode = 'decks',
  }) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          parentId: Value<String?>(parentId),
          name: 'Folder $id',
          contentMode: Value<String>(contentMode),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

  Future<void> insertDeck({required String id, required String folderId}) => db
      .into(db.decks)
      .insert(
        DecksCompanion.insert(
          id: id,
          folderId: folderId,
          name: 'Deck $id',
          targetLanguage: const Value<String>('korean'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

  Future<void> insertCard({
    required String id,
    required String deckId,
    required int dueAt,
    int? buriedUntil,
    bool isSuspended = false,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: 'Front $id',
            back: 'Back $id',
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: Value<String>(id),
            dueAt: Value<int?>(dueAt),
            buriedUntil: Value<int?>(buriedUntil),
            isSuspended: Value<bool>(isSuspended),
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late FolderRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = FolderRepositoryImpl(FolderDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'F12: deck-level counts include suspended and buried cards while dueCount excludes them and still counts expired buried cards',
    () async {
      final DateTime now = DateTime.now();
      final int currentDueAt =
          now.millisecondsSinceEpoch - const Duration(hours: 1).inMilliseconds;
      final int currentBuriedUntil = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1, seconds: 1)).millisecondsSinceEpoch;
      final int expiredBuriedUntil = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch;
      const String rootId = 'folder-root-deck-counts';
      const String childId = 'folder-child-deck-counts';
      const String deckId = 'deck-counts';
      final _CountFixture fixture = _CountFixture(db);
      await fixture.insertRootFolder(id: rootId);
      await fixture.insertSubfolder(id: childId, parentId: rootId);
      await fixture.insertDeck(id: deckId, folderId: childId);
      await fixture.insertCard(
        id: 'card-active',
        deckId: deckId,
        dueAt: currentDueAt,
      );
      await fixture.insertCard(
        id: 'card-suspended',
        deckId: deckId,
        dueAt: currentDueAt,
        isSuspended: true,
      );
      await fixture.insertCard(
        id: 'card-buried',
        deckId: deckId,
        dueAt: currentDueAt,
        buriedUntil: currentBuriedUntil,
      );
      await fixture.insertCard(
        id: 'card-expired-buried',
        deckId: deckId,
        dueAt: currentDueAt,
        buriedUntil: expiredBuriedUntil,
      );

      final Result<FolderDetail> detailResult = await repository
          .watchFolderDetail(childId)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      final DeckWithCount deck = detail.decks.single;

      expect(deck.cardCount, 4);
      expect(deck.dueCount, 2);
      expect(
        deck.lastStudiedAt,
        null,
        reason: 'card counts are read-only and do not synthesize study history',
      );
    },
  );

  test(
    'F13: recursive folder counts include suspended and buried cards while dueCount excludes them and still counts expired buried cards',
    () async {
      final DateTime now = DateTime.now();
      final int currentDueAt =
          now.millisecondsSinceEpoch - const Duration(hours: 1).inMilliseconds;
      final int currentBuriedUntil = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1, seconds: 1)).millisecondsSinceEpoch;
      final int expiredBuriedUntil = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(seconds: 1)).millisecondsSinceEpoch;
      const String rootId = 'folder-root-recursive-counts';
      const String childId = 'folder-child-recursive-counts';
      const String deckId = 'deck-recursive-counts';
      final _CountFixture fixture = _CountFixture(db);
      await fixture.insertRootFolder(id: rootId);
      await fixture.insertSubfolder(id: childId, parentId: rootId);
      await fixture.insertDeck(id: deckId, folderId: childId);
      await fixture.insertCard(
        id: 'card-active',
        deckId: deckId,
        dueAt: currentDueAt,
      );
      await fixture.insertCard(
        id: 'card-suspended',
        deckId: deckId,
        dueAt: currentDueAt,
        isSuspended: true,
      );
      await fixture.insertCard(
        id: 'card-buried',
        deckId: deckId,
        dueAt: currentDueAt,
        buriedUntil: currentBuriedUntil,
      );
      await fixture.insertCard(
        id: 'card-expired-buried',
        deckId: deckId,
        dueAt: currentDueAt,
        buriedUntil: expiredBuriedUntil,
      );

      final Result<LibraryOverviewReadModel> overviewResult = await repository
          .watchLibraryOverview()
          .first;
      final LibraryOverviewReadModel overview =
          (overviewResult as Ok<LibraryOverviewReadModel>).value;
      final FolderWithCount root = overview.folders.single;

      expect(root.cardCount, 4);
      expect(root.dueCount, 2);
      expect(
        root.subfolderCount,
        1,
        reason: 'recursive overview must still count the nested folder subtree',
      );
    },
  );
}
