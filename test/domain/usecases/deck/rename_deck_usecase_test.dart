import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/usecases/deck/rename_deck_usecase.dart';

import '../test_doubles/folder_repository_test_double.dart';

void main() {
  group('RenameDeckUseCase', () {
    test('rejects a blank title before calling the repository', () async {
      final FolderRepositoryTestDouble repository =
          FolderRepositoryTestDouble();
      final RenameDeckUseCase useCase = RenameDeckUseCase(repository);

      final Result<Deck> result = await useCase.call(deckId: 'd1', name: '   ');

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<ValidationFailure>());
      expect(repository.lastRenameDeckCall, isNull);
    });

    test('trims the title before delegating', () async {
      final FolderRepositoryTestDouble repository =
          FolderRepositoryTestDouble();
      final RenameDeckUseCase useCase = RenameDeckUseCase(repository);

      final Result<Deck> result = await useCase.call(
        deckId: 'd1',
        name: '  Korean N5  ',
      );

      expect(result, isA<Ok<Deck>>());
      expect(repository.lastRenameDeckCall, isNotNull);
      expect(repository.lastRenameDeckCall!.deckId, 'd1');
      expect(repository.lastRenameDeckCall!.name, 'Korean N5');
    });
  });
}
