import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/repositories/search_repository.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';

const SearchResults _empty = SearchResults(
  folders: <FolderSearchHit>[],
  decks: <DeckSearchHit>[],
  flashcards: <FlashcardSearchHit>[],
  folderTotal: 0,
  deckTotal: 0,
  flashcardTotal: 0,
);

final class _RecordingSearchRepository implements SearchRepository {
  int calls = 0;
  String? lastQuery;
  int? lastCap;

  @override
  Future<Result<SearchResults>> search({
    required String query,
    required int sectionCap,
  }) async {
    calls++;
    lastQuery = query;
    lastCap = sectionCap;
    return const Result<SearchResults>.ok(_empty);
  }
}

void main() {
  test(
    'rejects a sub-minimum query as tooShort without hitting the repo',
    () async {
      final repo = _RecordingSearchRepository();
      final useCase = GlobalSearchUseCase(repo);

      final Result<SearchResults> result = await useCase.call(query: 'a');

      expect(repo.calls, 0);
      expect(
        (result as Err<SearchResults>).failure,
        isA<ValidationFailure>()
            .having(
              (ValidationFailure f) => f.code,
              'code',
              ValidationCode.tooShort,
            )
            .having((ValidationFailure f) => f.field, 'field', 'query'),
      );
    },
  );

  test('rejects a whitespace-only query as tooShort', () async {
    final repo = _RecordingSearchRepository();
    final useCase = GlobalSearchUseCase(repo);

    final Result<SearchResults> result = await useCase.call(query: '   ');

    expect(repo.calls, 0);
    expect(result, isA<Err<SearchResults>>());
  });

  test('normalizes the query and forwards the section cap', () async {
    final repo = _RecordingSearchRepository();
    final useCase = GlobalSearchUseCase(repo);

    await useCase.call(query: '  KOR   ean  ');

    expect(repo.calls, 1);
    // Trimmed, lowercased, internal whitespace collapsed.
    expect(repo.lastQuery, 'kor ean');
    expect(repo.lastCap, GlobalSearchUseCase.sectionCap);
  });
}
