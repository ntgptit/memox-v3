import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/bulk_delete_result.dart';
import 'package:memox/domain/repositories/flashcard_bulk_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/bulk/delete_flashcards_usecase.dart';

class _BulkDeleteRepository implements FlashcardBulkRepository {
  _BulkDeleteRepository({Result<BulkDeleteResult>? result})
    : result =
          result ??
          const Result<BulkDeleteResult>.ok(
            BulkDeleteResult(deletedCount: 1, skippedCount: 0),
          );

  final Result<BulkDeleteResult> result;
  List<FlashcardId>? lastIds;

  @override
  Future<Result<BulkDeleteResult>> deleteMany({
    required List<FlashcardId> ids,
  }) async {
    lastIds = ids;
    return result;
  }
}

void main() {
  group('DeleteFlashcardsUseCase', () {
    test('rejects an empty selection before calling the repository', () async {
      final _BulkDeleteRepository repository = _BulkDeleteRepository();
      final DeleteFlashcardsUseCase useCase = DeleteFlashcardsUseCase(
        repository,
      );

      final Result<BulkDeleteResult> result = await useCase.call(
        ids: const <FlashcardId>[],
      );

      expect(result, isA<Err<BulkDeleteResult>>());
      expect(
        (result as Err<BulkDeleteResult>).failure,
        isA<ValidationFailure>(),
      );
      expect(repository.lastIds, isNull);
    });

    test('trims ids before delegating to the repository', () async {
      final _BulkDeleteRepository repository = _BulkDeleteRepository();
      final DeleteFlashcardsUseCase useCase = DeleteFlashcardsUseCase(
        repository,
      );

      final Result<BulkDeleteResult> result = await useCase.call(
        ids: <FlashcardId>['  c1  ', ' c2 '],
      );

      expect(result, isA<Ok<BulkDeleteResult>>());
      expect(repository.lastIds, <FlashcardId>['c1', 'c2']);
    });

    test('forwards repository failures unchanged', () async {
      final _BulkDeleteRepository repository = _BulkDeleteRepository(
        result: const Result<BulkDeleteResult>.err(
          Failure.storage(
            operation: StorageOp.transaction,
            cause: 'boom',
            table: 'flashcards',
          ),
        ),
      );
      final DeleteFlashcardsUseCase useCase = DeleteFlashcardsUseCase(
        repository,
      );

      final Result<BulkDeleteResult> result = await useCase.call(
        ids: <FlashcardId>['c1'],
      );

      expect(result, isA<Err<BulkDeleteResult>>());
      expect((result as Err<BulkDeleteResult>).failure, isA<StorageFailure>());
    });
  });
}
