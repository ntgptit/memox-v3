part of 'flashcard_repository_impl.dart';

Future<Result<List<Flashcard>>> _existingByFrontBackPairs(
  FlashcardRepositoryImpl repo,
  String deckId,
  List<({String front, String back})> pairs,
) async {
  final String trimmedDeckId = StringUtils.trimmed(deckId);
  if (trimmedDeckId.isEmpty) {
    return Future<Result<List<Flashcard>>>.value(
      const Result<List<Flashcard>>.err(
        Failure.validation(field: 'deckId', code: ValidationCode.empty),
      ),
    );
  }
  if (pairs.isEmpty) {
    return const Result<List<Flashcard>>.ok(<Flashcard>[]);
  }

  try {
    final DeckRow? deckRow = await repo._folderDao.findDeck(trimmedDeckId);
    if (deckRow == null) {
      return Result<List<Flashcard>>.err(
        Failure.notFound(entity: 'deck', id: trimmedDeckId),
      );
    }

    final Set<String> requestedKeys = <String>{
      for (final ({String front, String back}) pair in pairs)
        _pairKey(pair.front, pair.back),
    };
    final List<Flashcard> cards =
        (await repo._dao.getFlashcards(
              deckId: trimmedDeckId,
              sort: ContentSortMode.manual,
              statusFilter: FlashcardStatusFilter.all,
              nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
            ))
            .map(FlashcardMapper.fromRow)
            .where(
              (Flashcard card) =>
                  requestedKeys.contains(_pairKey(card.front, card.back)),
            )
            .toList(growable: false);

    return Result<List<Flashcard>>.ok(cards);
  } catch (error) {
    return Result<List<Flashcard>>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'flashcards',
      ),
    );
  }
}

Future<Result<int>> _commitDeckImport(
  FlashcardRepositoryImpl repo, {
  required String deckId,
  required List<DeckImportPreviewRow> rows,
}) async {
  if (StringUtils.trimmed(deckId).isEmpty) {
    return Future<Result<int>>.value(
      const Result<int>.err(
        Failure.validation(field: 'deckId', code: ValidationCode.empty),
      ),
    );
  }
  if (rows.isEmpty) {
    return Future<Result<int>>.value(
      const Result<int>.err(
        Failure.validation(
          field: 'preview',
          code: ValidationCode.insufficientContent,
        ),
      ),
    );
  }

  try {
    final DeckRow? deckRow = await repo._folderDao.findDeck(deckId);
    if (deckRow == null) {
      return Result<int>.err(Failure.notFound(entity: 'deck', id: deckId));
    }
    final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final int committed = await repo._dao.transaction(() async {
      int count = 0;
      for (final DeckImportPreviewRow row in rows) {
        await _insertFlashcard(
          repo,
          deckId: deckId,
          front: row.front,
          back: row.back,
          tags: const <String>[],
          nowMs: nowMs,
        );
        count++;
      }
      return count;
    });
    return Result<int>.ok(committed);
  } on _RuleViolation catch (violation) {
    return Result<int>.err(violation.failure);
  } catch (error) {
    return Result<int>.err(
      Failure.storage(
        operation: StorageOp.write,
        cause: error.toString(),
        table: 'flashcards',
      ),
    );
  }
}

String? _optionalText(String? value) {
  if (value == null) {
    return null;
  }
  final String trimmed = StringUtils.trimmed(value);
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _normalizeTags(List<String> tags) {
  final Set<String> seenTags = <String>{};
  final List<String> normalizedTags = <String>[];
  for (final String tag in tags) {
    final String normalizedTag = TagValidator.storageValue(tag);
    if (normalizedTag.isEmpty || !seenTags.add(normalizedTag)) {
      continue;
    }
    normalizedTags.add(normalizedTag);
  }
  return normalizedTags;
}

Future<FlashcardRow> _insertFlashcard(
  FlashcardRepositoryImpl repo, {
  required String deckId,
  required String front,
  required String back,
  String? exampleSentence,
  String? pronunciation,
  String? hint,
  required List<String> tags,
  required int nowMs,
}) async {
  final String trimmedFront = StringUtils.trimmed(front);
  if (trimmedFront.isEmpty) {
    throw const _RuleViolation(
      Failure.validation(field: 'front', code: ValidationCode.empty),
    );
  }

  final String trimmedBack = StringUtils.trimmed(back);
  if (trimmedBack.isEmpty) {
    throw const _RuleViolation(
      Failure.validation(field: 'back', code: ValidationCode.empty),
    );
  }

  final String id = IdGenerator.newId();
  final int nextSortOrder = (await repo._dao.maxFlashcardSortOrder(deckId)) + 1;

  await repo._dao
      .into(repo._dao.flashcards)
      .insert(
        FlashcardsCompanion.insert(
          id: id,
          deckId: deckId,
          front: trimmedFront,
          back: trimmedBack,
          exampleSentence: Value<String?>(exampleSentence),
          pronunciation: Value<String?>(pronunciation),
          hint: Value<String?>(hint),
          sortOrder: Value<int>(nextSortOrder),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );
  await repo._dao
      .into(repo._dao.attachedDatabase.flashcardProgress)
      .insert(
        FlashcardProgressCompanion.insert(
          flashcardId: id,
          dueAt: Value<int?>(nowMs),
        ),
      );
  for (final String tag in tags) {
    await repo._dao
        .into(repo._dao.attachedDatabase.flashcardTags)
        .insert(FlashcardTagsCompanion.insert(flashcardId: id, tag: tag));
  }
  return (await repo._dao.findFlashcard(id))!;
}

String _pairKey(String front, String back) =>
    '${StringUtils.normalize(front)}\u0000${StringUtils.normalize(back)}';

class _RuleViolation implements Exception {
  const _RuleViolation(this.failure);

  final Failure failure;
}
