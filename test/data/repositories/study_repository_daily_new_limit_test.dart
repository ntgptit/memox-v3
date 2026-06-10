import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

late DateTime _studyTestNow;

class _StudyDbFixture {
  _StudyDbFixture(this.db, {DateTime? now}) : _now = now ?? _studyTestNow;

  final AppDatabase db;
  final DateTime _now;

  int get _nowMs => _now.toUtc().millisecondsSinceEpoch;

  Future<void> insertFolder({required String id}) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          name: 'Folder $id',
          contentMode: const Value<String>('decks'),
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
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    int sortOrder = 0,
  }) => db
      .into(db.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          id: id,
          deckId: deckId,
          front: 'Front $id',
          back: 'Back $id',
          sortOrder: Value<int>(sortOrder),
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertResumableSession({
    required String id,
    required String entryType,
    required String? entryRefId,
    required String studyType,
    String status = 'in_progress',
    int? startedAt,
    int? updatedAt,
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: entryType,
            entryRefId: Value<String?>(entryRefId),
            studyType: studyType,
            status: status,
            startedAt: startedAt ?? _nowMs,
            updatedAt: updatedAt ?? _nowMs,
          ),
        );
  }

  Future<void> insertStudySessionItem({
    required String id,
    required String sessionId,
    required String flashcardId,
    int sortOrder = 0,
    int? answeredAt,
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: sortOrder,
            answeredAt: Value<int?>(answeredAt),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    _studyTestNow = DateTime(2026, 1, 15, 15, 30);
    repository = StudyRepositoryImpl(
      StudySessionDao(db),
      now: () => _studyTestNow,
    );
  });

  tearDown(() async => db.close());

  test('deck scope skips new cards already consumed earlier today', () async {
    const String folderId = 'folder-daily-consumed';
    const String deckId = 'deck-daily-consumed';
    const String consumedSessionId = 'session-daily-consumed';
    final int twoHoursAgo = _studyTestNow
        .subtract(const Duration(hours: 2))
        .toUtc()
        .millisecondsSinceEpoch;
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }
    await fixture.insertResumableSession(
      id: consumedSessionId,
      entryType: EntryType.deck.name,
      entryRefId: deckId,
      studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      status: 'cancelled',
      startedAt: twoHoursAgo,
      updatedAt: twoHoursAgo,
    );
    for (int index = 0; index < 15; index++) {
      await fixture.insertStudySessionItem(
        id: 'item-daily-consumed-$index',
        sessionId: consumedSessionId,
        flashcardId: 'card-$index',
        sortOrder: index,
      );
    }

    final result = await repository.startStudySession(
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: deckId,
        studyType: StudyType.newCards,
      ),
    );

    final value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;
    final items = await (db.select(
      db.studySessionItems,
    )..where((StudySessionItems row) => row.sessionId.equals(sessionId))).get();

    expect(items, hasLength(5));
    expect(
      items.map((row) => row.flashcardId),
      List<String>.generate(5, (int index) => 'card-${index + 15}'),
    );
    expect(
      items.map((row) => row.sortOrder),
      List<int>.generate(5, (int index) => index),
    );
  });

  test(
    'restartStudySession leaves the previous session untouched when the daily new quota is exhausted',
    () async {
      const String folderId = 'folder-restart-daily-empty';
      const String deckId = 'deck-restart-daily-empty';
      const String consumedSessionId = 'session-restart-daily-consumed';
      const String previousSessionId = 'session-restart-daily-old';
      final int threeHoursAgo = _studyTestNow
          .subtract(const Duration(hours: 3))
          .toUtc()
          .millisecondsSinceEpoch;
      final int yesterday = _studyTestNow
          .subtract(const Duration(days: 1))
          .toUtc()
          .millisecondsSinceEpoch;
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 25; index++) {
        await fixture.insertFlashcard(
          id: 'card-restart-daily-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }
      await fixture.insertResumableSession(
        id: consumedSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'cancelled',
        startedAt: threeHoursAgo,
        updatedAt: threeHoursAgo,
      );
      for (int index = 0; index < 20; index++) {
        await fixture.insertStudySessionItem(
          id: 'item-restart-daily-consumed-$index',
          sessionId: consumedSessionId,
          flashcardId: 'card-restart-daily-$index',
          sortOrder: index,
        );
      }
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: yesterday,
        updatedAt: yesterday,
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-daily-old',
        sessionId: previousSessionId,
        flashcardId: 'card-restart-daily-20',
      );

      final result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(
        (await db.select(db.studySessions).get())
            .firstWhere((StudySessionRow row) => row.id == previousSessionId)
            .status,
        'in_progress',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(21));
    },
  );
}
