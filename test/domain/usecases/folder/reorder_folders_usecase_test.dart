import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/folder/reorder_folders_usecase.dart';

import '../test_doubles/folder_repository_test_double.dart';

void main() {
  group('ReorderFoldersUseCase', () {
    test(
      'rejects an empty reorder list before calling the repository',
      () async {
        final FolderRepositoryTestDouble repository =
            FolderRepositoryTestDouble();
        final ReorderFoldersUseCase useCase = ReorderFoldersUseCase(repository);

        final Result<void> result = await useCase.call(
          parentId: null,
          orderedIds: const <FolderId>[],
        );

        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure, isA<ValidationFailure>());
        expect(repository.lastReorderFoldersCall, isNull);
      },
    );

    test('forwards the parent and complete order unchanged', () async {
      final FolderRepositoryTestDouble repository =
          FolderRepositoryTestDouble();
      final ReorderFoldersUseCase useCase = ReorderFoldersUseCase(repository);

      final Result<void> result = await useCase.call(
        parentId: 'parent',
        orderedIds: <FolderId>['f3', 'f1', 'f2'],
      );

      expect(result, isA<Ok<void>>());
      expect(repository.lastReorderFoldersCall, isNotNull);
      expect(repository.lastReorderFoldersCall!.parentId, 'parent');
      expect(repository.lastReorderFoldersCall!.orderedIds, <FolderId>[
        'f3',
        'f1',
        'f2',
      ]);
    });
  });
}
