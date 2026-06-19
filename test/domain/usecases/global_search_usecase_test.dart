import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/search_results.dart';
import 'package:memox/domain/repositories/search_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';

/// In-memory [SearchRepository] returning canned rows; lets the use-case test
/// focus on normalization, min-length, ranking, and caps without a database.
class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.folders = const <Folder>[], this.failure});

  List<Folder> folders;
  List<Deck> decks = const <Deck>[];
  List<Flashcard> flashcards = const <Flashcard>[];
  Failure? failure;
  final List<String> queries = <String>[];

  @override
  Future<Result<List<Folder>>> searchFolders(String normalizedQuery) async {
    queries.add(normalizedQuery);
    if (failure != null) return (failure: failure, data: null);
    return (failure: null, data: folders);
  }

  @override
  Future<Result<List<Deck>>> searchDecks(String normalizedQuery) async {
    if (failure != null) return (failure: failure, data: null);
    return (failure: null, data: decks);
  }

  @override
  Future<Result<List<Flashcard>>> searchFlashcards(
    String normalizedQuery,
  ) async {
    if (failure != null) return (failure: failure, data: null);
    return (failure: null, data: flashcards);
  }
}

Folder _folder(String id, String name, {int updatedAtMs = 0}) => Folder(
  id: id,
  parentId: null,
  name: name,
  contentMode: ContentMode.unlocked,
  sortOrder: 0,
  createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs, isUtc: true),
);

void main() {
  // GlobalSearchUseCase: WBS 3.5.1, decision rows SR1, SR5, SR6.
  group('GlobalSearchUseCase', () {
    test(
      'SR1: query shorter than 2 chars → tooShort, repo not called',
      () async {
        // decision: SR1
        final _FakeSearchRepository repo = _FakeSearchRepository();
        final GlobalSearchUseCase useCase = GlobalSearchUseCase(
          repository: repo,
        );

        final Result<SearchResults> result = await useCase.call(query: ' a ');

        expect(result.isFailure, isTrue);
        final Failure failure = result.failure!;
        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).code, ValidationCode.tooShort);
        expect(repo.queries, isEmpty);
      },
    );

    test('normalizes the query before querying the repository', () async {
      final _FakeSearchRepository repo = _FakeSearchRepository();
      final GlobalSearchUseCase useCase = GlobalSearchUseCase(repository: repo);

      await useCase.call(query: '  Hello   World  ');

      expect(repo.queries.single, 'hello world');
    });

    test(
      'SR5: ranks exact → starts-with → substring, recency tie-break',
      () async {
        final _FakeSearchRepository repo = _FakeSearchRepository(
          folders: <Folder>[
            _folder('sub', 'My Korean Notes'), // substring
            _folder('starts', 'Korean Basics'), // starts-with
            _folder('exact', 'korean'), // exact
            _folder(
              'sub2',
              'Best Korean',
              updatedAtMs: 999,
            ), // substring, newer
          ],
        );
        final GlobalSearchUseCase useCase = GlobalSearchUseCase(
          repository: repo,
        );

        final Result<SearchResults> result = await useCase.call(
          query: 'korean',
        );

        expect(result.data!.folders.map((Folder f) => f.id), <String>[
          'exact',
          'starts',
          'sub2',
          'sub',
        ]);
      },
    );

    test('SR6: caps each section at sectionCap and reports total', () async {
      final _FakeSearchRepository repo = _FakeSearchRepository(
        folders: List<Folder>.generate(
          8,
          (int i) => _folder('f$i', 'korean $i', updatedAtMs: i),
        ),
      );
      final GlobalSearchUseCase useCase = GlobalSearchUseCase(repository: repo);

      final Result<SearchResults> result = await useCase.call(query: 'korean');

      expect(result.data!.folders, hasLength(GlobalSearchUseCase.sectionCap));
      expect(result.data!.folderTotal, 8);
    });

    test('propagates a repository StorageFailure', () async {
      final _FakeSearchRepository repo = _FakeSearchRepository(
        failure: const Failure.storage(operation: StorageOp.read, cause: 'x'),
      );
      final GlobalSearchUseCase useCase = GlobalSearchUseCase(repository: repo);

      final Result<SearchResults> result = await useCase.call(query: 'korean');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<StorageFailure>());
    });

    test('returns empty results when nothing matches', () async {
      final GlobalSearchUseCase useCase = GlobalSearchUseCase(
        repository: _FakeSearchRepository(),
      );

      final Result<SearchResults> result = await useCase.call(query: 'korean');

      expect(result.data!.isEmpty, isTrue);
      expect(result.data!.totalCount, 0);
    });
  });
}
