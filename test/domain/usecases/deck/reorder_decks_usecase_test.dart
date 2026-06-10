import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/usecases/deck/reorder_decks_usecase.dart';

import '../test_doubles/folder_repository_test_double.dart';

void main() {
  group('ReorderDecksUseCase', () {
    test(
      'rejects an empty reorder list before calling the repository',
      () async {
        final FolderRepositoryTestDouble repository =
            FolderRepositoryTestDouble();
        final ReorderDecksUseCase useCase = ReorderDecksUseCase(repository);

        final Result<void> result = await useCase.call(
          parentId: 'parent',
          orderedIds: const <String>[],
        );

        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure, isA<ValidationFailure>());
        expect(repository.lastReorderDecksCall, isNull);
      },
    );

    test('forwards the parent and complete order unchanged', () async {
      final FolderRepositoryTestDouble repository =
          FolderRepositoryTestDouble();
      final ReorderDecksUseCase useCase = ReorderDecksUseCase(repository);

      final Result<void> result = await useCase.call(
        parentId: 'parent',
        orderedIds: <String>['d3', 'd1', 'd2'],
      );

      expect(result, isA<Ok<void>>());
      expect(repository.lastReorderDecksCall, isNotNull);
      expect(repository.lastReorderDecksCall!.parentId, 'parent');
      expect(repository.lastReorderDecksCall!.orderedIds, <String>[
        'd3',
        'd1',
        'd2',
      ]);
    });
  });
}
