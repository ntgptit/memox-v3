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
import 'package:memox/domain/types/flashcard_status_filter.dart';
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
      expect(detail.dueCount, 0); // brand-new cards (due_at NULL) are not due
    });

    test('WP-D1: dueCount = active due cards (F13 exclusion), full-deck', () async {
      final String deckId = await newDeck();
      Future<String> card(String front) async => (await repo.createFlashcard(
        deckId: deckId,
        front: front,
        back: 'b',
      )).data!.id;
      final String due = await card('due');
      final String future = await card('future');
      await card('new'); // due_at NULL → not due
      final String suspended = await card('suspended');
      final String buried = await card('buried');

      // due_at=1 is always <= the incrementing clock → due; a far-future due_at
      // is not due; the suspended card is excluded even though it is due.
      await db.customStatement(
        'UPDATE flashcard_progress SET due_at = 1 WHERE flashcard_id = ?',
        <Object>[due],
      );
      await db.customStatement(
        'UPDATE flashcard_progress SET due_at = 9999999999 WHERE flashcard_id = ?',
        <Object>[future],
      );
      await db.customStatement(
        'UPDATE flashcard_progress SET due_at = 1, is_suspended = 1 '
        'WHERE flashcard_id = ?',
        <Object>[suspended],
      );
      // Past-due but currently buried (buried_until far in the future) → excluded.
      await db.customStatement(
        'UPDATE flashcard_progress SET due_at = 1, buried_until = 9999999999 '
        'WHERE flashcard_id = ?',
        <Object>[buried],
      );

      final FlashcardListDetail detail =
          (await repo.watchFlashcardList(deckId).first).data!;
      expect(detail.totalCount, 5);
      expect(detail.dueCount, 1); // only the active, past-due card
      // Search must not change the full-deck due total.
      final FlashcardListDetail searched =
          (await repo.watchFlashcardList(deckId, searchTerm: 'due').first)
              .data!;
      expect(searched.dueCount, 1);
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

    // ---- Status filter (WBS 2.17.1, decision rows C36/C37, BS8/BS9) ----
    //
    // A fixed `now` so the time-relative `due`/`buried` predicates are
    // deterministic; cards are created with the shared `repo`, then their
    // progress state is set directly and read back through a fixed-clock repo
    // (both share the same db).
    const int now = 5000;
    FlashcardRepositoryImpl repoAtNow() => FlashcardRepositoryImpl(
      dao: flashcardDao,
      deckDao: deckDao,
      folderDao: folderDao,
      idGenerator: IdGenerator(Random(7)),
      nowMs: () => now,
    );
    Future<void> setProgress(
      String cardId, {
      bool suspended = false,
      int? buriedUntil,
      int? dueAt,
    }) => flashcardDao.updateProgressColumns(
      cardId,
      FlashcardProgressCompanion(
        isSuspended: Value<bool>(suspended),
        buriedUntil: Value<int?>(buriedUntil),
        dueAt: Value<int?>(dueAt),
      ),
    );

    test(
      'C36: status filter buckets cards by derived state; totalCount stays full',
      () async {
        final String deckId = await newDeck();
        Future<String> card(String front) async => (await repo.createFlashcard(
          deckId: deckId,
          front: front,
          back: front,
        )).data!.id;
        // newCard: no progress change → box 1, due_at NULL, active, not due.
        await card('new');
        final String suspended = await card('suspended');
        final String buried = await card('buried');
        final String expiredBuried = await card('expiredBuried');
        final String due = await card('due');
        final String futureDue = await card('futureDue');
        await setProgress(suspended, suspended: true);
        await setProgress(buried, buriedUntil: now + 4000); // > now → buried
        await setProgress(expiredBuried, buriedUntil: now - 4000); // <= now
        await setProgress(due, dueAt: now - 4000); // <= now → due
        await setProgress(futureDue, dueAt: now + 4000); // > now → not due

        final FlashcardRepositoryImpl r = repoAtNow();
        Future<Set<String>> fronts(FlashcardStatusFilter s) async =>
            (await r.watchFlashcardList(deckId, status: s).first).data!.cards
                .map((Flashcard c) => c.front)
                .toSet();

        expect(await fronts(FlashcardStatusFilter.all), <String>{
          'new',
          'suspended',
          'buried',
          'expiredBuried',
          'due',
          'futureDue',
        });
        expect(
          await fronts(FlashcardStatusFilter.active),
          <String>{'new', 'expiredBuried', 'due', 'futureDue'},
          reason: 'active excludes suspended + currently-buried, keeps expired',
        );
        expect(
          await fronts(FlashcardStatusFilter.due),
          <String>{'due'},
          reason:
              'due = active AND due_at <= now (new/expired due_at NULL '
              'excluded, future-due excluded)',
        );
        expect(await fronts(FlashcardStatusFilter.suspended), <String>{
          'suspended',
        });
        expect(await fronts(FlashcardStatusFilter.buried), <String>{'buried'});

        final FlashcardListDetail buriedDetail =
            (await r
                    .watchFlashcardList(
                      deckId,
                      status: FlashcardStatusFilter.buried,
                    )
                    .first)
                .data!;
        expect(
          buriedDetail.totalCount,
          6,
          reason: 'totalCount independent of the status filter',
        );
      },
    );

    test(
      'C37: status filter composes with search and keeps stable deck order',
      () async {
        final String deckId = await newDeck();
        Future<String> card(String front) async => (await repo.createFlashcard(
          deckId: deckId,
          front: front,
          back: front,
        )).data!.id;
        await card('apple-active');
        final String appleSuspended = await card('apple-suspended');
        await card('banana-active');
        await setProgress(appleSuspended, suspended: true);

        final FlashcardRepositoryImpl r = repoAtNow();
        final FlashcardListDetail detail =
            (await r
                    .watchFlashcardList(
                      deckId,
                      searchTerm: 'apple',
                      status: FlashcardStatusFilter.active,
                    )
                    .first)
                .data!;
        // 'apple' search AND active status → only the non-suspended apple.
        expect(detail.cards.map((Flashcard c) => c.front).toList(), <String>[
          'apple-active',
        ]);
        expect(detail.totalCount, 3);
      },
    );

    test(
      'loadDeckCardContents returns front/back of every deck card (6.6.1)',
      () async {
        final String deckId = await newDeck();
        await repo.createFlashcard(deckId: deckId, front: 'eat', back: '먹다');
        await repo.createFlashcard(deckId: deckId, front: 'drink', back: '마시다');

        final result = await repo.loadDeckCardContents(deckId: deckId);

        expect(result.failure, isNull);
        expect(
          result.data!.map((c) => '${c.front}/${c.back}').toSet(),
          <String>{'eat/먹다', 'drink/마시다'},
        );
      },
    );

    test('loadDeckCardContents is empty for a deck with no cards', () async {
      final String deckId = await newDeck();
      final result = await repo.loadDeckCardContents(deckId: deckId);
      expect(result.failure, isNull);
      expect(result.data, isEmpty);
    });

    test(
      'commitDeckImport inserts rows + progress, appended in order (6.4.1)',
      () async {
        final String deckId = await newDeck();
        await repo.createFlashcard(
          deckId: deckId,
          front: 'existing',
          back: 'x',
        );

        final result = await repo.commitDeckImport(
          deckId: deckId,
          rows: const [
            (front: 'eat', back: '먹다'),
            (front: 'drink', back: '마시다'),
          ],
        );

        expect(result.failure, isNull);
        expect(result.data, 2);
        final detail = (await repo.watchFlashcardList(deckId).first).data!;
        expect(
          detail.cards.map((c) => c.front),
          <String>['existing', 'eat', 'drink'],
          reason: 'imported rows appended after existing in order',
        );
        // Each imported card has a default NEW progress row.
        for (final card in detail.cards) {
          final p = await flashcardDao.findProgress(card.id);
          expect(p!.boxNumber, 1);
          expect(p.dueAt, isNull);
        }
      },
    );

    test(
      'commitDeckImport on a missing deck is NotFound, writes nothing',
      () async {
        final result = await repo.commitDeckImport(
          deckId: 'nope',
          rows: const [(front: 'a', back: 'b')],
        );
        expect(result.failure, isA<NotFoundFailure>());
        expect(
          await flashcardDao.flashcardsInDeck('nope'),
          isEmpty,
          reason: 'deck check precedes any insert',
        );
      },
    );

    test('commitDeckImport with no rows is a no-op count 0', () async {
      final String deckId = await newDeck();
      final result = await repo.commitDeckImport(
        deckId: deckId,
        rows: const [],
      );
      expect(result.failure, isNull);
      expect(result.data, 0);
    });

    test(
      'commitDeckImport rolls the whole batch back on mid-batch failure',
      () async {
        final String deckId = await newDeck();
        // A generator returning the same id for every card forces a PRIMARY KEY
        // collision on the SECOND row — the first row's writes must roll back
        // (all-or-nothing; no silent partial import — WBS 6.4.1/6.4.2).
        final collidingRepo = FlashcardRepositoryImpl(
          dao: flashcardDao,
          deckDao: deckDao,
          folderDao: folderDao,
          idGenerator: _ConstantIdGenerator('dup'),
          nowMs: () => clock++,
        );

        final result = await collidingRepo.commitDeckImport(
          deckId: deckId,
          rows: const [(front: 'a', back: '1'), (front: 'b', back: '2')],
        );

        expect(result.failure, isA<StorageFailure>());
        expect(
          await flashcardDao.flashcardsInDeck(deckId),
          isEmpty,
          reason: 'first row rolled back — no silent partial import',
        );
      },
    );
  });
}

/// Test IdGenerator that always returns the same id, to force a PK collision.
class _ConstantIdGenerator extends IdGenerator {
  _ConstantIdGenerator(this._id);
  final String _id;
  @override
  String newId() => _id;
}
