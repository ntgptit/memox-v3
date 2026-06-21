import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // FolderRepository.getDeckMoveTargets (WBS 2.19.2): every folder annotated as
  // a deck-move destination. Decision rows D9/D10 — a deck may move to an
  // unlocked or decks-mode folder; a subfolders-locked folder is blocked; the
  // current parent is always selectable. No Library-root option (a deck always
  // belongs to a folder).
  late AppDatabase db;
  late FolderRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = FolderRepositoryImpl(
      dao: FolderDao(db),
      deckDao: DeckDao(db),
      idGenerator: IdGenerator(Random(7)),
      nowMs: () => 1000,
    );
  });
  tearDown(() => db.close());

  Future<String> deckIn(String folderId, String name) async =>
      (await repo.createDeck(
        folderId: folderId,
        name: name,
        targetLanguage: TargetLanguage.korean,
      )).data!.id;

  test('returns NotFound for a missing deck', () async {
    final result = await repo.getDeckMoveTargets(deckId: 'missing');
    expect(result.data, isNull);
    expect(result.failure, isNotNull);
  });

  test(
    'annotates current parent, decks-mode, and subfolders-locked folders',
    () async {
      // A folder that holds a deck (→ decks-mode, the current parent).
      final String home = (await repo.createRootFolder(name: 'Home')).data!.id;
      final String deckId = await deckIn(home, 'Deck A');
      // A second folder that also holds a deck (decks-mode, selectable).
      final String other = (await repo.createRootFolder(
        name: 'Other',
      )).data!.id;
      await deckIn(other, 'Deck B');
      // A folder locked to subfolders (holds a subfolder) — cannot take a deck.
      final String parent = (await repo.createRootFolder(
        name: 'Parent',
      )).data!.id;
      await repo.createSubfolder(parentId: parent, name: 'Child');
      // A fresh unlocked folder — can take a deck.
      final String fresh = (await repo.createRootFolder(
        name: 'Fresh',
      )).data!.id;

      final result = await repo.getDeckMoveTargets(deckId: deckId);
      expect(result.failure, isNull);
      final Map<String, DeckMoveTarget> byId = <String, DeckMoveTarget>{
        for (final DeckMoveTarget t in result.data!) t.id: t,
      };

      // No Library-root option: every target is a real folder.
      expect(result.data!.every((DeckMoveTarget t) => t.id.isNotEmpty), isTrue);

      expect(byId[home]!.isCurrentParent, isTrue);
      expect(byId[home]!.isSelectable, isTrue);
      expect(byId[other]!.isCurrentParent, isFalse);
      expect(byId[other]!.isSelectable, isTrue); // decks-mode accepts a deck
      expect(byId[fresh]!.isSelectable, isTrue); // unlocked accepts a deck
      expect(byId[parent]!.isSelectable, isFalse); // subfolders-locked
      expect(byId[parent]!.block, DeckMoveBlock.lockedToSubfolders);
    },
  );
}
