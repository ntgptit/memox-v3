import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/usecases/deck/create_deck_usecase.dart';

final Deck _deck = Deck(
  id: 'd',
  folderId: 'f',
  name: 'D',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

/// Records the `createDeck` call and returns a canned [Result]; the rest of
/// [FolderRepository] is unused (routed through [noSuchMethod]).
class _FakeFolderRepository implements FolderRepository {
  String? folderId;
  String? name;
  TargetLanguage? targetLanguage;
  Result<Deck> response = (failure: null, data: _deck);

  @override
  Future<Result<Deck>> createDeck({
    required String folderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) async {
    this.folderId = folderId;
    this.name = name;
    this.targetLanguage = targetLanguage;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CreateDeckUseCase', () {
    test(
      'forwards folder, name and target language to the repository',
      () async {
        final repo = _FakeFolderRepository();
        final useCase = CreateDeckUseCase(repository: repo);

        final result = await useCase.call(
          parentFolderId: 'f',
          name: 'Verbs',
          targetLanguage: TargetLanguage.english,
        );

        expect(repo.folderId, 'f');
        expect(repo.name, 'Verbs');
        expect(repo.targetLanguage, TargetLanguage.english);
        expect(result.data, _deck);
      },
    );
  });
}
