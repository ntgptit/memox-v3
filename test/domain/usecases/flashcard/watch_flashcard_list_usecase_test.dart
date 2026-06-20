import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/usecases/flashcard/watch_flashcard_list_usecase.dart';

class _FakeFlashcardRepository implements FlashcardRepository {
  String? deckId;
  String? searchTerm;
  List<String>? tags;
  ContentSortMode? sort;

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    String deckId, {
    String? searchTerm,
    List<String> tags = const <String>[],
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    this.deckId = deckId;
    this.searchTerm = searchTerm;
    this.tags = tags;
    this.sort = sort;
    return const Stream<Result<FlashcardListDetail>>.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // WBS 2.18.1 — decision rows C38/C39. The use case forwards the deck id,
  // search term, and the multi-select tag filter to the repository unchanged.
  test('WatchFlashcardListUseCase forwards deckId, search and tags', () {
    final repo = _FakeFlashcardRepository();
    WatchFlashcardListUseCase(repository: repo).call(
      'deck-1',
      searchTerm: 'app',
      tags: const <String>['grammar', 'weak'],
    );

    expect(repo.deckId, 'deck-1');
    expect(repo.searchTerm, 'app');
    expect(repo.tags, <String>['grammar', 'weak']);
    expect(repo.sort, ContentSortMode.manual);
  });

  test('WatchFlashcardListUseCase defaults to an empty tag filter', () {
    final repo = _FakeFlashcardRepository();
    WatchFlashcardListUseCase(repository: repo).call('deck-2');

    expect(repo.tags, isEmpty);
  });
}
