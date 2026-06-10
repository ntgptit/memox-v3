import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

late DateTime _eligibilityTestNow;

class _EligibilityFixture {
  _EligibilityFixture(this.db, {DateTime? now})
    : _now = now ?? _eligibilityTestNow;

  final AppDatabase db;
  final DateTime _now;

  int get nowMs => _now.toUtc().millisecondsSinceEpoch;

  Future<void> insertFolder({required String id}) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          name: 'Folder $id',
          contentMode: const Value<String>('decks'),
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

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    int? dueAt,
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
    if (dueAt != null || buriedUntil != null || isSuspended) {
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
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    _eligibilityTestNow = DateTime(2026, 1, 15, 15, 30);
    repository = StudyRepositoryImpl(
      StudySessionDao(db),
      now: () => _eligibilityTestNow,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'BS10: suspended deck card is excluded from a fresh deck new-card study entry',
    () async {
      const String folderId = 'folder-new-suspended';
      const String deckId = 'deck-new-suspended';
      const String cardId = 'card-new-suspended';
      final _EligibilityFixture fixture = _EligibilityFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        isSuspended: true,
      );

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
        StudyEntryEmptyVariant.allSuspended,
      );
    },
  );

  test(
    'BS11: currently buried deck card is excluded from a fresh deck new-card study entry',
    () async {
      const String folderId = 'folder-new-buried';
      const String deckId = 'deck-new-buried';
      const String cardId = 'card-new-buried';
      final _EligibilityFixture fixture = _EligibilityFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        buriedUntil: DateTime(2026, 1, 16, 0, 0, 1).millisecondsSinceEpoch,
      );

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
        StudyEntryEmptyVariant.allBuried,
      );
    },
  );

  test(
    'BS12: a card whose buried_until is in the past becomes eligible again',
    () async {
      const String folderId = 'folder-buried-past';
      const String deckId = 'deck-buried-past';
      const String cardId = 'card-buried-past';
      final _EligibilityFixture fixture = _EligibilityFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        buriedUntil: DateTime(2026, 1, 14, 0, 0, 1).millisecondsSinceEpoch,
      );

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
      expect((value as StudyEntryStartStarted).sessionId, isNotEmpty);
    },
  );

  test(
    'BS13: suspended due card is excluded from a fresh today study entry',
    () async {
      const String folderId = 'folder-today-suspended';
      const String deckId = 'deck-today-suspended';
      const String cardId = 'card-today-suspended';
      final _EligibilityFixture fixture = _EligibilityFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: fixture.nowMs - const Duration(hours: 1).inMilliseconds,
        isSuspended: true,
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
        StudyEntryEmptyVariant.allSuspended,
      );
    },
  );

  test(
    'BS14: currently buried due card is excluded from a fresh today study entry',
    () async {
      const String folderId = 'folder-today-buried';
      const String deckId = 'deck-today-buried';
      const String cardId = 'card-today-buried';
      final _EligibilityFixture fixture = _EligibilityFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: fixture.nowMs - const Duration(hours: 1).inMilliseconds,
        buriedUntil: DateTime(2026, 1, 16, 0, 0, 1).millisecondsSinceEpoch,
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
        StudyEntryEmptyVariant.allBuried,
      );
    },
  );
}
