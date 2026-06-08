import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _StudyDbFixture {
  _StudyDbFixture(this.db);

  final AppDatabase db;

  Future<void> insertFolder({
    required String id,
    String? parentId,
    String contentMode = 'decks',
  }) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          parentId: Value<String?>(parentId),
          name: 'Folder $id',
          contentMode: Value<String>(contentMode),
          sortOrder: const Value<int>(0),
          createdAt: _nowMs,
          updatedAt: _nowMs,
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
          sortOrder: const Value<int>(0),
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    int? dueAt,
    int? boxNumber,
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
            sortOrder: const Value<int>(0),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    if (dueAt != null ||
        boxNumber != null ||
        buriedUntil != null ||
        isSuspended) {
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion(
              flashcardId: Value<String>(id),
              boxNumber: boxNumber == null
                  ? const Value<int>(1)
                  : Value<int>(boxNumber),
              dueAt: Value<int?>(dueAt),
              buriedUntil: Value<int?>(buriedUntil),
              isSuspended: Value<bool>(isSuspended),
              reviewCount: const Value<int>(0),
              lapseCount: const Value<int>(0),
              lastStudiedAt: const Value<int?>(null),
            ),
          );
    }
  }

  int get _nowMs => DateTime.now().toUtc().millisecondsSinceEpoch;
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late StudySessionDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = StudySessionDao(db);
    repository = StudyRepositoryImpl(dao);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'deck scope with zero cards returns empty and persists no session',
    () async {
      const String folderId = 'folder-empty';
      const String deckId = 'deck-empty';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.deckNoCards,
      );
      expect(await db.select(db.studySessions).get(), isEmpty);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
    },
  );

  test('deck scope with missing progress creates a session and item', () async {
    const String folderId = 'folder-deck';
    const String deckId = 'deck-study';
    const String cardId = 'card-study';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    await fixture.insertFlashcard(id: cardId, deckId: deckId);

    final Result<StudyEntryStartResult> result = await repository
        .startStudySession(
          scope: const StudyScope(
            entryType: EntryType.deck,
            entryRefId: deckId,
            studyType: StudyType.newCards,
          ),
        );

    final StudyEntryStartResult? value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;

    final List<StudySessionRow> sessions = await db
        .select(db.studySessions)
        .get();
    final List<StudySessionItemRow> items = await db
        .select(db.studySessionItems)
        .get();

    expect(sessions, hasLength(1));
    expect(sessions.single.id, sessionId);
    expect(sessions.single.status, 'in_progress');
    expect(items, hasLength(1));
    expect(items.single.sessionId, sessionId);
    expect(items.single.flashcardId, cardId);
    expect(items.single.sortOrder, 0);
  });

  test(
    'folder scope with eligible cards creates a session and items',
    () async {
      const String folderId = 'folder-root';
      const String deckId = 'deck-child';
      const String cardId = 'card-folder';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.folder,
              entryRefId: folderId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartStarted>());
      expect(await db.select(db.studySessions).get(), hasLength(1));
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'today scope with future due cards returns an all-done empty state',
    () async {
      const String folderId = 'folder-today';
      const String deckId = 'deck-today';
      const String cardId = 'card-future';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: DateTime.now()
            .toUtc()
            .add(const Duration(days: 1))
            .millisecondsSinceEpoch,
        boxNumber: 2,
      );

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.today,
              entryRefId: null,
              studyType: StudyType.srsReview,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.todayAllDone,
      );
      expect(await db.select(db.studySessions).get(), isEmpty);
    },
  );

  test(
    'createSession rolls back session writes when an item insert fails',
    () async {
      final Result<StudySession> result = await repository.createSession(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'deck-missing',
          studyType: StudyType.newCards,
        ),
        flashcardIds: const <String>['missing-card'],
      );

      expect(result.isErr, isTrue);
      expect(await db.select(db.studySessions).get(), isEmpty);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
    },
  );
}
