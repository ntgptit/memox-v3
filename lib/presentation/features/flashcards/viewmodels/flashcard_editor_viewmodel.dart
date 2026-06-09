import 'dart:async';

import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
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

/// Loads the detail for a flashcard edit session.
@Riverpod(keepAlive: true)
Future<FlashcardDetail> flashcardEditorDetailQuery(
  Ref ref,
  FlashcardId flashcardId,
) async {
  final useCase = ref.watch(getFlashcardDetailUseCaseProvider);
  final Result<FlashcardDetail> result = await useCase.call(
    flashcardId: flashcardId,
  );
  return result.fold(
    // ignore: only_throw_errors
    (Failure failure) => throw failure,
    (FlashcardDetail detail) => detail,
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

  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<Flashcard> result = await ref
        .read(updateFlashcardUseCaseProvider)
        .call(
          flashcardId: flashcardId,
          front: front,
          back: back,
          exampleSentence: exampleSentence,
          pronunciation: pronunciation,
          hint: hint,
          tags: tags,
          progressPolicy: progressPolicy,
        );
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (Flashcard _) => const AsyncValue<void>.data(null),
    );
    return result;
  }

  Future<Result<void>> deleteFlashcard({
    required FlashcardId flashcardId,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(deleteFlashcardUseCaseProvider)
        .call(flashcardId);
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (void _) => const AsyncValue<void>.data(null),
    );
    return result;
  }
}
