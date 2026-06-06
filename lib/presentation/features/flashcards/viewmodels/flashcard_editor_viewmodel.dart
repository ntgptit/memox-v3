import 'dart:async';

import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_editor_viewmodel.g.dart';

/// Loads the deck context used by the flashcard create screen.
///
/// Reuses the flashcard list read model so the editor can show the breadcrumb
/// and deck label without introducing a separate deck lookup path.
@Riverpod(keepAlive: true)
Stream<FlashcardListDetail> flashcardEditorContextQuery(
  Ref ref,
  DeckId deckId,
) {
  final useCase = ref.watch(watchFlashcardListUseCaseProvider);
  return useCase
      .call(deckId)
      .map(
        (Result<FlashcardListDetail> result) => result.fold(
          // ignore: only_throw_errors
          (Failure failure) => throw failure,
          (FlashcardListDetail detail) => detail,
        ),
      );
}

/// Executes the create mutation for the flashcard editor screen.
@riverpod
class FlashcardEditorController extends _$FlashcardEditorController {
  @override
  FutureOr<void> build() {}

  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<Flashcard> result = await ref
        .read(createFlashcardUseCaseProvider)
        .call(
          deckId: deckId,
          front: front,
          back: back,
          exampleSentence: exampleSentence,
          pronunciation: pronunciation,
          hint: hint,
          tags: tags,
        );
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (Flashcard _) => const AsyncValue<void>.data(null),
    );
    return result;
  }
}
