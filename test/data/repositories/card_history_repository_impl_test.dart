import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/card_history_repository_impl.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/folder_detail.dart';

class _Fixture {
  _Fixture(this.db);

  final AppDatabase db;

  Future<void> seedCard({
    int boxNumber = 1,
    int reviewCount = 0,
    int lapseCount = 0,
    int? dueAtMs,
    bool isSuspended = false,
    int? lastResetAtMs,
  }) async {
    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'f1',
            name: 'Korean',
            contentMode: const Value<String>('decks'),
            sortOrder: const Value<int>(0),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: 'd1',
            folderId: 'f1',
            name: 'N5',
            sortOrder: const Value<int>(0),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: 'c1',
            deckId: 'd1',
            front: '안녕하세요',
            back: 'Hello',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: const Value<String>('c1'),
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(dueAtMs),
            isSuspended: Value<bool>(isSuspended),
            reviewCount: Value<int>(reviewCount),
            lapseCount: Value<int>(lapseCount),
            lastResetAt: Value<int?>(lastResetAtMs),
          ),
        );
  }

  Future<void> seedAttempt({
    required String id,
    required int attemptedAtMs,
    String result = 'perfect',
    String mode = 'review',
    int boxBefore = 1,
    int boxAfter = 2,
    String sessionStatus = 'completed',
  }) async {
    final String sessionId = 's_$id';
    final String itemId = 'i_$id';
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: sessionId,
            entryType: 'deck',
            studyType: 'srs_review',
            status: sessionStatus,
            startedAt: attemptedAtMs,
            updatedAt: attemptedAtMs,
          ),
        );
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: itemId,
            sessionId: sessionId,
            flashcardId: 'c1',
            sortOrder: 0,
            createdAt: attemptedAtMs,
            updatedAt: attemptedAtMs,
          ),
        );
    await db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: itemId,
            result: result,
            studyMode: mode,
            boxBefore: Value<int>(boxBefore),
            boxAfter: Value<int>(boxAfter),
            attemptedAt: attemptedAtMs,
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late CardHistoryRepositoryImpl repo;
  late _Fixture fx;

  final DateTime fixedNow = DateTime.utc(2026, 6, 13, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CardHistoryRepositoryImpl(
      CardHistoryDao(db),
      FolderDao(db),
      now: () => fixedNow,
    );
    fx = _Fixture(db);
  });

  tearDown(() async => db.close());

  group('loadHeader (H4)', () {
    test('NotFoundFailure when the card does not exist', () async {
      final Result<CardHistoryHeader> result = await repo.loadHeader(
        flashcardId: 'missing',
      );
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('accuracy is cumulative from stored counters', () async {
      await fx.seedCard(boxNumber: 3, reviewCount: 50, lapseCount: 5);
      final CardHistoryHeader header = (await repo.loadHeader(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(header.reviewCount, 50);
      expect(header.lapseCount, 5);
      expect(header.accuracy, closeTo((50 - 5) / 50, 1e-9));
    });

    test('never-studied card returns box 1 and no reviews', () async {
      await fx.seedCard();
      final CardHistoryHeader header = (await repo.loadHeader(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(header.boxNumber, 1);
      expect(header.hasReviews, isFalse);
      expect(header.accuracy, isNull);
    });

    test('correct streak counts leading non-forgot run; events = total; '
        'breadcrumb + deck resolved', () async {
      await fx.seedCard();
      await fx.seedAttempt(id: 'a1', attemptedAtMs: 1000, result: 'forgot');
      await fx.seedAttempt(id: 'a2', attemptedAtMs: 2000, result: 'perfect');
      await fx.seedAttempt(id: 'a3', attemptedAtMs: 3000, result: 'recovered');

      final CardHistoryHeader header = (await repo.loadHeader(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(header.correctStreak, 2);
      expect(header.totalEvents, 3);
      expect(header.deckName, 'N5');
      expect(
        header.breadcrumb.map((FolderBreadcrumbSegment s) => s.name).toList(),
        <String>['Korean'],
      );
    });
  });

  group('loadAttempts (H1)', () {
    test('returns attempts newest-first', () async {
      await fx.seedCard();
      await fx.seedAttempt(id: 'a1', attemptedAtMs: 1000);
      await fx.seedAttempt(id: 'a2', attemptedAtMs: 3000);
      await fx.seedAttempt(id: 'a3', attemptedAtMs: 2000);

      final CardHistoryPage page = (await repo.loadAttempts(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(
        page.attempts.map((CardHistoryAttempt a) => a.id).toList(),
        <String>['a2', 'a3', 'a1'],
      );
      expect(page.hasMore, isFalse);
    });

    test(
      'cursor pagination yields deterministic, non-overlapping pages',
      () async {
        await fx.seedCard();
        await fx.seedAttempt(id: 'a1', attemptedAtMs: 1000);
        await fx.seedAttempt(id: 'a2', attemptedAtMs: 2000);
        await fx.seedAttempt(id: 'a3', attemptedAtMs: 3000);

        final CardHistoryPage first = (await repo.loadAttempts(
          flashcardId: 'c1',
          limit: 2,
        )).valueOrNull!;
        expect(
          first.attempts.map((CardHistoryAttempt a) => a.id).toList(),
          <String>['a3', 'a2'],
        );
        expect(first.hasMore, isTrue);

        final CardHistoryPage second = (await repo.loadAttempts(
          flashcardId: 'c1',
          before: first.nextCursor,
          limit: 2,
        )).valueOrNull!;
        expect(
          second.attempts.map((CardHistoryAttempt a) => a.id).toList(),
          <String>['a1'],
        );
        expect(second.hasMore, isFalse);
      },
    );

    test('empty when the card has no attempts', () async {
      await fx.seedCard();
      final CardHistoryPage page = (await repo.loadAttempts(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(page.attempts, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('resetProgress (H3)', () {
    test('resets box/due/last_reset_at but keeps cumulative counters and '
        'attempts', () async {
      await fx.seedCard(boxNumber: 6, reviewCount: 50, lapseCount: 5);
      await fx.seedAttempt(id: 'a1', attemptedAtMs: 1000);

      final Result<void> result = await repo.resetProgress(flashcardId: 'c1');
      expect(result.isOk, isTrue);

      final CardHistoryHeader header = (await repo.loadHeader(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(header.boxNumber, 1);
      expect(header.reviewCount, 50);
      expect(header.lapseCount, 5);
      expect(header.dueAt, fixedNow);
      expect(header.lastResetAt, fixedNow);

      final CardHistoryPage page = (await repo.loadAttempts(
        flashcardId: 'c1',
      )).valueOrNull!;
      expect(page.attempts, hasLength(1));
    });
  });
}
