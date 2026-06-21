import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/delete_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/reorder_flashcards_usecase.dart';
import 'package:memox/domain/usecases/flashcard/update_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/watch_flashcard_list_usecase.dart';

final Flashcard _card = Flashcard(
  id: 'c',
  deckId: 'd',
  front: 'F',
  back: 'B',
  sortOrder: 0,
  createdAt: DateTime.utc(2024),
  updatedAt: DateTime.utc(2024),
);

/// Records arguments and returns canned [Result]s; unused methods route through
/// [noSuchMethod].
class _FakeFlashcardRepository implements FlashcardRepository {
  // create
  String? createDeckId;
  String? front;
  String? back;
  String? exampleSentence;
  String? pronunciation;
  String? hint;
  List<String>? tags;
  // update
  String? updateId;
  FlashcardProgressEditPolicy? progressPolicy;
  // delete
  String? deletedId;
  // reorder
  String? reorderDeckId;
  List<String>? orderedIds;
  // watch
  String? watchedDeckId;
  String? searchTerm;
  ContentSortMode? sort;

  Result<Flashcard> cardResponse = (failure: null, data: _card);
  Result<void> voidResponse = (failure: null, data: null);

  @override
  Future<Result<Flashcard>> createFlashcard({
    required String deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    createDeckId = deckId;
    this.front = front;
    this.back = back;
    this.exampleSentence = exampleSentence;
    this.pronunciation = pronunciation;
    this.hint = hint;
    this.tags = tags;
    return cardResponse;
  }

  @override
  Future<Result<Flashcard>> updateFlashcard({
    required String flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    updateId = flashcardId;
    this.front = front;
    this.back = back;
    this.tags = tags;
    this.progressPolicy = progressPolicy;
    return cardResponse;
  }

  @override
  Future<Result<void>> deleteFlashcard({required String flashcardId}) async {
    deletedId = flashcardId;
    return voidResponse;
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedIds,
  }) async {
    reorderDeckId = deckId;
    this.orderedIds = orderedIds;
    return voidResponse;
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    String deckId, {
    String? searchTerm,
    List<String> tags = const <String>[],
    FlashcardStatusFilter status = FlashcardStatusFilter.all,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    watchedDeckId = deckId;
    this.searchTerm = searchTerm;
    this.sort = sort;
    return const Stream<Result<FlashcardListDetail>>.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CreateFlashcardUseCase', () {
    test('forwards every field to the repository', () async {
      final repo = _FakeFlashcardRepository();
      final result = await CreateFlashcardUseCase(repository: repo).call(
        deckId: 'd',
        front: 'Hello',
        back: 'Xin chao',
        exampleSentence: 'Hi there',
        pronunciation: 'heh-loh',
        hint: 'greeting',
        tags: const <String>['Greeting'],
      );

      expect(repo.createDeckId, 'd');
      expect(repo.front, 'Hello');
      expect(repo.back, 'Xin chao');
      expect(repo.exampleSentence, 'Hi there');
      expect(repo.pronunciation, 'heh-loh');
      expect(repo.hint, 'greeting');
      expect(repo.tags, const <String>['Greeting']);
      expect(result.data, _card);
    });
  });

  group('UpdateFlashcardUseCase', () {
    test('defaults to keepProgress and forwards fields', () async {
      final repo = _FakeFlashcardRepository();
      await UpdateFlashcardUseCase(
        repository: repo,
      ).call(flashcardId: 'c', front: 'a', back: 'b');

      expect(repo.updateId, 'c');
      expect(repo.progressPolicy, FlashcardProgressEditPolicy.keepProgress);
    });

    test('forwards the reset progress policy when chosen', () async {
      final repo = _FakeFlashcardRepository();
      await UpdateFlashcardUseCase(repository: repo).call(
        flashcardId: 'c',
        front: 'a',
        back: 'b',
        progressPolicy: FlashcardProgressEditPolicy.resetProgress,
      );

      expect(repo.progressPolicy, FlashcardProgressEditPolicy.resetProgress);
    });
  });

  group('DeleteFlashcardUseCase', () {
    test('forwards the flashcard id', () async {
      final repo = _FakeFlashcardRepository();
      final result = await DeleteFlashcardUseCase(
        repository: repo,
      ).call(flashcardId: 'c');

      expect(repo.deletedId, 'c');
      expect(result.isSuccess, isTrue);
    });
  });

  group('ReorderFlashcardsUseCase', () {
    test('forwards deck id and ordered ids', () async {
      final repo = _FakeFlashcardRepository();
      await ReorderFlashcardsUseCase(
        repository: repo,
      ).call(deckId: 'd', orderedIds: const <String>['c2', 'c1']);

      expect(repo.reorderDeckId, 'd');
      expect(repo.orderedIds, const <String>['c2', 'c1']);
    });
  });

  group('WatchFlashcardListUseCase', () {
    test('forwards deck id, search term and sort', () async {
      final repo = _FakeFlashcardRepository();
      WatchFlashcardListUseCase(repository: repo).call('d', searchTerm: 'hi');

      expect(repo.watchedDeckId, 'd');
      expect(repo.searchTerm, 'hi');
      expect(repo.sort, ContentSortMode.manual);
    });
  });
}
