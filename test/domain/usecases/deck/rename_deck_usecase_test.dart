import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/deck/rename_deck_usecase.dart';

final Deck _deck = Deck(
  id: 'd',
  folderId: 'f',
  name: 'Renamed',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

class _FakeFolderRepository implements FolderRepository {
  String? deckId;
  String? newName;
  Result<Deck> response = (failure: null, data: _deck);

  @override
  Future<Result<Deck>> renameDeck({
    required String deckId,
    required String newName,
  }) async {
    this.deckId = deckId;
    this.newName = newName;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RenameDeckUseCase', () {
    test('forwards deckId and name and returns the renamed deck', () async {
      final repo = _FakeFolderRepository();
      final useCase = RenameDeckUseCase(repository: repo);

      final result = await useCase.call(deckId: 'd', name: 'Renamed');

      expect(repo.deckId, 'd');
      expect(repo.newName, 'Renamed');
      expect(result.data, _deck);
    });
  });
}
