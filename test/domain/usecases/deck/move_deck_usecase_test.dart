import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/deck/move_deck_usecase.dart';

final Deck _deck = Deck(
  id: 'd',
  folderId: 'dest',
  name: 'D',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

class _FakeFolderRepository implements FolderRepository {
  String? deckId;
  String? newFolderId;
  Result<Deck> response = (failure: null, data: _deck);

  @override
  Future<Result<Deck>> moveDeck({
    required String deckId,
    required String newFolderId,
  }) async {
    this.deckId = deckId;
    this.newFolderId = newFolderId;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MoveDeckUseCase', () {
    test('forwards id and newParentId and returns the moved deck', () async {
      final repo = _FakeFolderRepository();
      final useCase = MoveDeckUseCase(repository: repo);

      final result = await useCase.call(id: 'd', newParentId: 'dest');

      expect(repo.deckId, 'd');
      expect(repo.newFolderId, 'dest');
      expect(result.data, _deck);
    });
  });
}
