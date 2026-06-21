import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/flashcard/export_deck_csv_usecase.dart';

class _FakeFlashcardRepository implements FlashcardRepository {
  DeckId? requestedDeckId;

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required DeckId deckId}) async {
    requestedDeckId = deckId;
    return (
      failure: null,
      data: const DeckCsvExport(
        deckId: 'd1',
        deckName: 'Deck',
        fileName: 'Deck.csv',
        csvText: 'front,back',
        exportedRowCount: 0,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test('delegates the export to the repository with the deck id', () async {
    final repo = _FakeFlashcardRepository();
    final useCase = ExportDeckCsvUseCase(repository: repo);

    final result = await useCase.call(deckId: 'd1');

    expect(result.failure, isNull);
    expect(repo.requestedDeckId, 'd1');
    expect(result.data!.fileName, 'Deck.csv');
  });

  test('a blank deck id is rejected without touching the repository', () async {
    final repo = _FakeFlashcardRepository();
    final useCase = ExportDeckCsvUseCase(repository: repo);

    final result = await useCase.call(deckId: '  ');

    expect(result.data, isNull);
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.requestedDeckId, isNull, reason: 'short-circuits before repo');
  });
}
