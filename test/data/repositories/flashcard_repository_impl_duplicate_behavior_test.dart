import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  late AppDatabase db;
  late FolderRepositoryImpl folderRepo;
  late FlashcardRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final FolderDao folderDao = FolderDao(db);
    folderRepo = FolderRepositoryImpl(folderDao);
    repo = FlashcardRepositoryImpl(FlashcardDao(db), folderDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Folder> createRoot(String name) async =>
      (await folderRepo.createRootFolder(name: name) as Ok<Folder>).value;

  Future<void> seedExistingCard(
    String deckId,
    String id,
    String front,
    String back,
  ) async {
    final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            sortOrder: const Value<int>(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            dueAt: Value<int?>(now),
          ),
        );
  }

  test('create still allows duplicate front/back pairs', () async {
    final Folder folder = await createRoot('Folder');
    final Deck deck =
        (await folderRepo.createDeck(
                  parentFolderId: folder.id,
                  name: 'Deck',
                  targetLanguage: TargetLanguage.korean,
                )
                as Ok<Deck>)
            .value;
    await seedExistingCard(deck.id, 'c1', 'Hello', 'World');

    final Result<Flashcard> result = await repo.createFlashcard(
      deckId: deck.id,
      front: ' hello ',
      back: ' world ',
    );

    expect(result, isA<Ok<Flashcard>>());
    expect(await db.select(db.flashcards).get(), hasLength(2));
  });

  test('update still allows duplicate front/back pairs', () async {
    final Folder folder = await createRoot('Folder');
    final Deck deck =
        (await folderRepo.createDeck(
                  parentFolderId: folder.id,
                  name: 'Deck',
                  targetLanguage: TargetLanguage.korean,
                )
                as Ok<Deck>)
            .value;
    await seedExistingCard(deck.id, 'c1', 'Hello', 'World');
    await seedExistingCard(deck.id, 'c2', 'Bye', 'See ya');

    final Result<Flashcard> result = await repo.updateFlashcard(
      flashcardId: 'c2',
      front: ' hello ',
      back: ' world ',
      progressPolicy: FlashcardProgressEditPolicy.keepProgress,
    );

    expect(result, isA<Ok<Flashcard>>());
    expect(await db.select(db.flashcards).get(), hasLength(2));
  });
}
