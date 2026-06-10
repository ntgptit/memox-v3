import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/flashcard/watch_flashcard_list_usecase.dart';

void main() {
  group('WatchFlashcardListUseCase', () {
    test('forwards default filter values for existing callers', () async {
      final _FakeFlashcardRepository repo = _FakeFlashcardRepository();
      final WatchFlashcardListUseCase useCase = WatchFlashcardListUseCase(repo);

      await useCase('deck-1', searchTerm: ' hello ').first;

      expect(repo.called, isTrue);
      expect(repo.deckId, 'deck-1');
      expect(repo.searchTerm, ' hello ');
      expect(repo.sort, ContentSortMode.manual);
      expect(repo.statusFilter, FlashcardStatusFilter.all);
      expect(repo.selectedTags, isEmpty);
      expect(repo.now, isNull);
    });

    test('normalizes selected tags before reaching the repository', () async {
      final _FakeFlashcardRepository repo = _FakeFlashcardRepository();
      final WatchFlashcardListUseCase useCase = WatchFlashcardListUseCase(repo);

      await useCase(
        'deck-1',
        selectedTags: <String>['#Weak', 'WEAK', 'Grammar'],
      ).first;

      expect(repo.selectedTags, <String>['weak', 'grammar']);
    });
  });
}

class _FakeFlashcardRepository implements FlashcardRepository {
  bool called = false;
  String? deckId;
  String? searchTerm;
  ContentSortMode? sort;
  FlashcardStatusFilter? statusFilter;
  List<String> selectedTags = <String>[];
  DateTime? now;

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) {
    called = true;
    this.deckId = deckId;
    this.searchTerm = searchTerm;
    this.sort = sort;
    this.statusFilter = statusFilter;
    this.selectedTags = List<String>.from(selectedTags);
    this.now = now;
    return Stream<Result<FlashcardListDetail>>.value(
      const Result<FlashcardListDetail>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: 'fake',
          table: 'flashcards',
        ),
      ),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
