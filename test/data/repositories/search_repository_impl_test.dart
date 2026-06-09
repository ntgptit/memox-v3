import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/data/repositories/search_repository_impl.dart';
import 'package:memox/domain/models/search_results.dart';

/// End-to-end coverage for the global-search section queries
/// (`drift/search_queries.drift`) run against a real in-memory database, so the
/// LIKE escaping, the exact→prefix→substring ordering, and the per-section cap +
/// total are all exercised.
void main() {
  late AppDatabase db;
  late SearchRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SearchRepositoryImpl(SearchDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> folder(String id, String name) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(id: id, name: name, createdAt: 0, updatedAt: 0),
      );

  Future<void> deck(String id, String folderId, String name) => db
      .into(db.decks)
      .insert(
        DecksCompanion.insert(
          id: id,
          folderId: folderId,
          name: name,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

  Future<void> card(
    String id,
    String deckId, {
    required String front,
    required String back,
    String? example,
  }) => db
      .into(db.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          id: id,
          deckId: deckId,
          front: front,
          back: back,
          exampleSentence: Value<String?>(example),
          createdAt: 0,
          updatedAt: 0,
        ),
      );

  SearchResults ok(Result<SearchResults> r) => (r as Ok<SearchResults>).value;

  test('matches folder, deck, and flashcard sections in one pass', () async {
    await folder('f1', 'Korean');
    await deck('d1', 'f1', 'Korean basics');
    await card('c1', 'd1', front: 'annyeong', back: 'hello korea');

    final SearchResults results = ok(
      await repo.search(query: 'kor', sectionCap: 5),
    );

    expect(results.folders.single.name, 'Korean');
    expect(results.decks.single.name, 'Korean basics');
    expect(results.flashcards.single.front, 'annyeong');
    expect(results.flashcards.single.deckId, 'd1');
    expect(results.isEmpty, isFalse);
  });

  test('flashcards match on front, back, or example sentence', () async {
    await folder('f1', 'Deck home');
    await deck('d1', 'f1', 'D');
    await card('c1', 'd1', front: 'verb', back: 'meaning', example: 'a melon');

    final SearchResults results = ok(
      await repo.search(query: 'melon', sectionCap: 5),
    );

    expect(results.flashcards.single.id, 'c1');
  });

  test('escapes LIKE wildcards so % matches literally', () async {
    await folder('f1', '100% effort');
    await folder('f2', 'plain folder');

    final SearchResults results = ok(
      await repo.search(query: '100%', sectionCap: 5),
    );

    expect(results.folders.map((FolderSearchHit f) => f.name), <String>[
      '100% effort',
    ]);
  });

  test('caps each section at sectionCap but reports the true total', () async {
    await folder('home', 'home');
    for (int i = 0; i < 7; i++) {
      await deck('d$i', 'home', 'tag deck $i');
    }

    final SearchResults results = ok(
      await repo.search(query: 'tag', sectionCap: 5),
    );

    expect(results.decks.length, 5);
    expect(results.deckTotal, 7);
  });

  test('orders results exact, then starts-with, then substring', () async {
    await folder('f1', 'flashcard'); // substring
    await folder('f2', 'cards'); // starts-with
    await folder('f3', 'card'); // exact

    final SearchResults results = ok(
      await repo.search(query: 'card', sectionCap: 5),
    );

    expect(
      results.folders.map((FolderSearchHit f) => f.name).toList(),
      <String>['card', 'cards', 'flashcard'],
    );
  });

  test('no match yields an empty result with zero totals', () async {
    await folder('f1', 'Korean');

    final SearchResults results = ok(
      await repo.search(query: 'zzz', sectionCap: 5),
    );

    expect(results.isEmpty, isTrue);
    expect(results.totalCount, 0);
  });

  test(
    'case-insensitive: upper-cased data matches lower-cased query',
    () async {
      await folder('f1', 'KOREAN');

      final SearchResults results = ok(
        await repo.search(query: 'korean', sectionCap: 5),
      );

      expect(results.folders.single.name, 'KOREAN');
    },
  );
}
