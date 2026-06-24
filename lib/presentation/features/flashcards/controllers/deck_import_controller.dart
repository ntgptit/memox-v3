import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/types/import_text_separator.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deck_import_controller.g.dart';

/// Drives the Deck Import wizard (kit screen 10) for [deckId]: pick a file →
/// parse + dedup → preview → commit. The separator is auto-detected (the kit
/// flow has no separator picker; the pre-redesign dropdown is superseded).
/// WBS 6.3.1.
@riverpod
class DeckImportController extends _$DeckImportController {
  @override
  DeckImportState build(String deckId) => const DeckImportState.empty();

  /// Allowed import extensions (CSV / TSV / plain text; Anki `.apkg` is Future —
  /// the CSV parser cannot read it).
  static const List<String> allowedExtensions = <String>['csv', 'tsv', 'txt'];

  /// Opens the system file picker; on a selection, decodes the bytes to text and
  /// moves to [DeckImportFileSelected]. A cancel leaves the state unchanged; a
  /// read error → [DeckImportFailed].
  Future<void> pickFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      state = const DeckImportState.failed();
      return;
    }
    loadFile(
      fileName: file.name,
      sizeBytes: file.size,
      rawText: utf8.decode(bytes, allowMalformed: true),
    );
  }

  /// Sets the selected-file state from already-read content (the testable seam
  /// behind [pickFile]).
  void loadFile({
    required String fileName,
    required int sizeBytes,
    required String rawText,
  }) => state = DeckImportState.fileSelected(
    fileName: fileName,
    sizeBytes: sizeBytes,
    rawText: rawText,
  );

  /// Clears the chosen file, back to the empty prompt.
  void clear() => state = const DeckImportState.empty();

  /// Parses the selected file + runs duplicate detection, moving to the preview
  /// (or [DeckImportFailed] when nothing is parseable / the deck read fails).
  Future<void> parse() async {
    final DeckImportState current = state;
    if (current is! DeckImportFileSelected) {
      return;
    }
    state = const DeckImportState.parsing();
    final FlashcardImportPreview preview = ref
        .read(parseDeckImportCsvUseCaseProvider)
        .call(rawCsv: current.rawText, separator: ImportTextSeparator.auto);
    final int foundCount = preview.rows.length + preview.issues.length;
    if (foundCount == 0) {
      state = const DeckImportState.failed();
      return;
    }
    final Result<FlashcardImportPreparation> prepared = await ref
        .read(prepareDeckImportUseCaseProvider)
        .call(deckId: deckId, preview: preview);
    final FlashcardImportPreparation? preparation = prepared.data;
    if (prepared.failure != null || preparation == null) {
      state = const DeckImportState.failed();
      return;
    }
    state = DeckImportState.preview(
      fileName: current.fileName,
      foundCount: foundCount,
      preview: preview,
      preparation: preparation,
    );
  }

  /// Commits the deduplicated valid rows; resolves to success (nothing skipped)
  /// or partial (some skipped), or [DeckImportFailed] on a write error.
  Future<void> commit() async {
    final DeckImportState current = state;
    if (current is! DeckImportPreview) {
      return;
    }
    state = const DeckImportState.importing();
    final Result<int> result = await ref
        .read(commitDeckImportUseCaseProvider)
        .call(deckId: deckId, preparation: current.preparation);
    final int? imported = result.data;
    if (result.failure != null || imported == null) {
      state = const DeckImportState.failed();
      return;
    }
    final int skipped = current.foundCount - current.preparation.importCount;
    state = skipped > 0
        ? DeckImportState.partial(imported: imported, skipped: skipped)
        : DeckImportState.success(count: imported);
  }

  /// Resets the wizard to the empty prompt (Try again / Choose another file).
  void reset() => state = const DeckImportState.empty();
}
