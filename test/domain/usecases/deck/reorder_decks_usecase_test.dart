import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/deck/reorder_decks_usecase.dart';

class _FakeFolderRepository implements FolderRepository {
  String? folderId;
  List<String>? orderedIds;
  Result<void> response = (failure: null, data: null);

  @override
  Future<Result<void>> reorderDecks({
    required String folderId,
    required List<String> orderedIds,
  }) async {
    this.folderId = folderId;
    this.orderedIds = orderedIds;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReorderDecksUseCase', () {
    test('forwards parentId and orderedIds to the repository', () async {
      final repo = _FakeFolderRepository();
      final useCase = ReorderDecksUseCase(repository: repo);

      final result = await useCase.call(
        parentId: 'f',
        orderedIds: <String>['d2', 'd1'],
      );

      expect(repo.folderId, 'f');
      expect(repo.orderedIds, <String>['d2', 'd1']);
      expect(result.isSuccess, isTrue);
    });
  });
}
