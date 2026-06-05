import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';

/// End-to-end coverage for the aggregate read queries that moved into
/// `drift/folder_queries.drift` (libraryOverview / subfolderItems / deckItems /
/// folderBreadcrumb), run against a real in-memory database so the recursive
/// subtree counts, the empty-string search sentinel, and the dynamic ORDER BY
/// are all exercised.
void main() {
  late AppDatabase db;
  late FolderRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FolderRepositoryImpl(FolderDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> root(String name) async =>
      ((await repo.createRootFolder(name: name)) as Ok<Folder>).value.id;

  Future<String> sub(String parentId, String name) async =>
      ((await repo.createSubfolder(parentId: parentId, name: name))
              as Ok<Folder>)
          .value
          .id;

  Future<String> deck(String folderId, String name) async =>
      ((await repo.createDeck(
                parentFolderId: folderId,
                name: name,
                targetLanguage: TargetLanguage.korean,
              ))
              as Ok<Deck>)
          .value
          .id;

  Future<void> card(String deckId, String id, {required bool due}) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: 'f-$id',
            back: 'b-$id',
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            // due_at in the past => due now; null => brand-new (not due).
            dueAt: Value<int?>(due ? 0 : null),
          ),
        );
  }

  /// A = [ A1(decks) -> deck D(2 cards, 1 due) ]; B = empty root.
  Future<({String a, String a1, String b})> buildTree() async {
    final String a = await root('A');
    final String a1 = await sub(a, 'A1');
    final String d = await deck(a1, 'D');
    await card(d, 'c1', due: true);
    await card(d, 'c2', due: false);
    final String b = await root('B');
    return (a: a, a1: a1, b: b);
  }

  test('library overview reports recursive counts + global totals', () async {
    final ({String a, String a1, String b}) ids = await buildTree();

    final LibraryOverviewReadModel model =
        ((await repo.watchLibraryOverview().first)
                as Ok<LibraryOverviewReadModel>)
            .value;

    // Top-level folders only, in manual (sort_order) order: A then B.
    expect(
      model.folders.map((FolderWithCount f) => f.folder.id).toList(),
      <String>[ids.a, ids.b],
    );
    final FolderWithCount a = model.folders.first;
    expect(a.subfolderCount, 1); // A1
    expect(a.deckCount, 1); // D (in A1)
    expect(a.cardCount, 2); // c1 + c2
    expect(a.dueCount, 1); // c1
    final FolderWithCount b = model.folders.last;
    expect(b.subfolderCount, 0);
    expect(b.cardCount, 0);

    // Globals are repeated per row and read from the first.
    expect(model.totalFolderCount, 3); // A, A1, B
    expect(model.dueToday, 1);
  });

  test('library overview search matches any folder across the tree', () async {
    await buildTree();

    final LibraryOverviewReadModel model =
        ((await repo.watchLibraryOverview(searchTerm: 'a1').first)
                as Ok<LibraryOverviewReadModel>)
            .value;

    expect(model.folders.length, 1);
    expect(model.folders.single.folder.name, 'A1');
  });

  test('folder detail lists children, counts, and breadcrumb', () async {
    final ({String a, String a1, String b}) ids = await buildTree();

    final FolderDetail aDetail =
        ((await repo.watchFolderDetail(ids.a).first) as Ok<FolderDetail>).value;
    expect(aDetail.folder.contentMode, ContentMode.subfolders);
    expect(aDetail.breadcrumb.map((FolderBreadcrumbSegment s) => s.name), <
      String
    >['A']);
    expect(aDetail.subfolders.single.folder.name, 'A1');
    expect(aDetail.decks, isEmpty);

    final FolderDetail a1Detail =
        ((await repo.watchFolderDetail(ids.a1).first) as Ok<FolderDetail>)
            .value;
    expect(a1Detail.folder.contentMode, ContentMode.decks);
    expect(
      a1Detail.breadcrumb.map((FolderBreadcrumbSegment s) => s.name).toList(),
      <String>['A', 'A1'],
    );
    final DeckWithCount d = a1Detail.decks.single;
    expect(d.deck.name, 'D');
    expect(d.cardCount, 2);
    expect(d.dueCount, 1);
  });
}
