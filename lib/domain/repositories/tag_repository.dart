import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/types/ids.dart';

/// Tag data access contract for the global `flashcard_tags` surface.
abstract interface class TagRepository {
  Stream<Result<List<TagWithCount>>> watchAllWithCount({String? searchTerm});

  Stream<Result<List<String>>> watchTagsForDeck(DeckId deckId);

  Stream<Result<List<String>>> watchTagsForCard(FlashcardId flashcardId);

  Future<Result<bool>> existsCaseInsensitive(String name);

  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  });

  Future<Result<MergeResult>> merge({
    required List<String> sourceNames,
    required String targetName,
  });

  Future<Result<int>> delete({required String name});
}
