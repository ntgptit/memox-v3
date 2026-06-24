import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';

part 'deck_import_state.freezed.dart';

/// The Deck Import wizard state (kit screen 10): a small state machine driving
/// the nine import states (empty → file selected → parsing → preview → importing
/// → success / partial / failed). The mock is a file-picker flow (the pre-redesign
/// paste-CSV + separator-dropdown design in `docs/wireframes/10-deck-import.md` is
/// superseded — mock-authoritative). WBS 6.3.1.
@freezed
sealed class DeckImportState with _$DeckImportState {
  /// No file chosen yet — the "Import cards from a file" prompt.
  const factory DeckImportState.empty() = DeckImportEmpty;

  /// A file is chosen and ready to parse (the file chip + "Parse file").
  const factory DeckImportState.fileSelected({
    required String fileName,
    required int sizeBytes,
    required String rawText,
  }) = DeckImportFileSelected;

  /// Parsing + duplicate-detection in progress.
  const factory DeckImportState.parsing() = DeckImportParsing;

  /// The parsed preview: the file summary + the per-row valid/skip list, ready
  /// to commit. [preview] carries the validated rows + issues; [preparation]
  /// carries the deduplicated commit set.
  const factory DeckImportState.preview({
    required String fileName,
    required int foundCount,
    required FlashcardImportPreview preview,
    required FlashcardImportPreparation preparation,
  }) = DeckImportPreview;

  /// Committing the valid rows.
  const factory DeckImportState.importing() = DeckImportImporting;

  /// All valid rows imported, nothing skipped.
  const factory DeckImportState.success({required int count}) =
      DeckImportSuccess;

  /// Some rows imported, others skipped (invalid / duplicate).
  const factory DeckImportState.partial({
    required int imported,
    required int skipped,
  }) = DeckImportPartial;

  /// The import could not run (read/parse/commit error) — nothing imported.
  const factory DeckImportState.failed() = DeckImportFailed;

  const DeckImportState._();
}
