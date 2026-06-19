import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/deck/delete_deck_usecase.dart';

class _FakeFolderRepository implements FolderRepository {
  String? deckId;
  Result<void> response = (failure: null, data: null);

  @override
  Future<Result<void>> deleteDeck({required String deckId}) async {
    this.deckId = deckId;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DeleteDeckUseCase', () {
    test('forwards the deck id to the repository', () async {
      final repo = _FakeFolderRepository();
      final useCase = DeleteDeckUseCase(repository: repo);

      final result = await useCase.call(id: 'd1');

      expect(repo.deckId, 'd1');
      expect(result.isSuccess, isTrue);
    });

    test('propagates a repository failure', () async {
      final repo = _FakeFolderRepository()
        ..response = (
          failure: const Failure.notFound(entity: 'deck'),
          data: null,
        );
      final useCase = DeleteDeckUseCase(repository: repo);

      final result = await useCase.call(id: 'missing');

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
