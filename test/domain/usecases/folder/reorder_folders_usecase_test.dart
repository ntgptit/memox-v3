import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/folder/reorder_folders_usecase.dart';

/// Records the reorder call and returns a canned [Result]; every other
/// [FolderRepository] member is unused (routed through [noSuchMethod]).
class _FakeFolderRepository implements FolderRepository {
  String? capturedParentId;
  List<String>? capturedOrderedIds;
  Result<void> response = (failure: null, data: null);

  @override
  Future<Result<void>> reorderFolders({
    required String? parentId,
    required List<String> orderedIds,
  }) async {
    capturedParentId = parentId;
    capturedOrderedIds = orderedIds;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReorderFoldersUseCase', () {
    late _FakeFolderRepository repo;
    late ReorderFoldersUseCase useCase;

    setUp(() {
      repo = _FakeFolderRepository();
      useCase = ReorderFoldersUseCase(repository: repo);
    });

    test('forwards parentId and orderedIds to the repository', () async {
      await useCase.call(parentId: 'p1', orderedIds: <String>['a', 'b']);

      expect(repo.capturedParentId, 'p1');
      expect(repo.capturedOrderedIds, <String>['a', 'b']);
    });

    test('passes a failure result through unchanged', () async {
      repo.response = (
        failure: const Failure.validation(
          field: 'orderedIds',
          code: ValidationCode.invalidFormat,
        ),
        data: null,
      );

      final result = await useCase.call(parentId: null, orderedIds: <String>[]);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
