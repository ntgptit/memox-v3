import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/usecases/deck/move_deck_usecase.dart';

import '../test_doubles/folder_repository_test_double.dart';

void main() {
  group('MoveDeckUseCase', () {
    test('forwards a trimmed folder move request to the repository', () async {
      final FolderRepositoryTestDouble repository =
          FolderRepositoryTestDouble();
      final MoveDeckUseCase useCase = MoveDeckUseCase(repository);

      final Result<Deck> result = await useCase.call(
        id: 'd1',
        newParentId: 'f2',
      );

      expect(result, isA<Ok<Deck>>());
      expect(repository.lastMoveDeckCall, isNotNull);
      expect(repository.lastMoveDeckCall!.deckId, 'd1');
      expect(repository.lastMoveDeckCall!.newParentId, 'f2');
    });

    test('forwards repository failures unchanged', () async {
      final FolderRepositoryTestDouble repository = FolderRepositoryTestDouble(
        moveDeckResult: const Result<Deck>.err(
          Failure.notFound(entity: 'deck', id: 'missing'),
        ),
      );
      final MoveDeckUseCase useCase = MoveDeckUseCase(repository);

      final Result<Deck> result = await useCase.call(
        id: 'missing',
        newParentId: 'f2',
      );

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<NotFoundFailure>());
    });
  });
}
