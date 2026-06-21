import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/usecases/flashcard/watch_flashcard_list_usecase.dart';

class _FakeFlashcardRepository implements FlashcardRepository {
  String? deckId;
  String? searchTerm;
  List<String>? tags;
  FlashcardStatusFilter? status;
  ContentSortMode? sort;

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    String deckId, {
    String? searchTerm,
    List<String> tags = const <String>[],
    FlashcardStatusFilter status = FlashcardStatusFilter.all,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    this.deckId = deckId;
    this.searchTerm = searchTerm;
    this.tags = tags;
    this.status = status;
    this.sort = sort;
    return const Stream<Result<FlashcardListDetail>>.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // WBS 2.18.1 / 2.17.1 — decision rows C36/C37/C38/C39. The use case forwards
  // the deck id, search term, multi-select tag filter, and status filter to the
  // repository unchanged.
  test(
    'WatchFlashcardListUseCase forwards deckId, search, tags and status',
    () {
      final repo = _FakeFlashcardRepository();
      WatchFlashcardListUseCase(repository: repo).call(
        'deck-1',
        searchTerm: 'app',
        tags: const <String>['grammar', 'weak'],
        status: FlashcardStatusFilter.suspended,
      );

      expect(repo.deckId, 'deck-1');
      expect(repo.searchTerm, 'app');
      expect(repo.tags, <String>['grammar', 'weak']);
      expect(repo.status, FlashcardStatusFilter.suspended);
      expect(repo.sort, ContentSortMode.manual);
    },
  );

  test('WatchFlashcardListUseCase defaults to empty tags and all status', () {
    final repo = _FakeFlashcardRepository();
    WatchFlashcardListUseCase(repository: repo).call('deck-2');

    expect(repo.tags, isEmpty);
    expect(repo.status, FlashcardStatusFilter.all);
  });
}
