part of 'flashcard_repository_impl.dart';

Future<Result<DeckCsvExport>> _exportDeckCsv(
  FlashcardRepositoryImpl repo, {
  required String deckId,
}) async {
  final String trimmedDeckId = StringUtils.trimmed(deckId);
  if (trimmedDeckId.isEmpty) {
    return Future<Result<DeckCsvExport>>.value(
      const Result<DeckCsvExport>.err(
        Failure.validation(field: 'deckId', code: ValidationCode.empty),
      ),
    );
  }

  try {
    final DeckRow? deckRow = await repo._folderDao.findDeck(trimmedDeckId);
    if (deckRow == null) {
      return Result<DeckCsvExport>.err(
        Failure.notFound(entity: 'deck', id: trimmedDeckId),
      );
    }

    final List<Flashcard> cards = (await repo._dao.getFlashcards(
      deckId: trimmedDeckId,
      sort: ContentSortMode.manual,
      statusFilter: FlashcardStatusFilter.all,
      nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    )).map(FlashcardMapper.fromRow).toList(growable: false);

    final String csvText = FlashcardExportWriter.buildCsv(
      cards.map((Flashcard card) => (front: card.front, back: card.back)),
    );
    return Result<DeckCsvExport>.ok(
      DeckCsvExport(
        deckId: trimmedDeckId,
        deckName: deckRow.name,
        fileName: FlashcardExportWriter.buildDeckFileName(
          deckName: deckRow.name,
          deckId: trimmedDeckId,
        ),
        csvText: csvText,
        exportedRowCount: cards.length,
      ),
    );
  } catch (error) {
    return Result<DeckCsvExport>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'flashcards',
      ),
    );
  }
}
