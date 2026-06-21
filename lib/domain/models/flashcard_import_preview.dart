import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/flashcard_import_duplicate.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';

part 'flashcard_import_preview.freezed.dart';

/// Import preview/preparation contract (ENABLER — WBS 6.0.1).
///
/// These are pure, immutable data holders pinned so every import use case
/// (parse → prepare → commit) and the preview screen share one shape; the
/// parsing / duplicate-detection / commit logic lands in WBS 6.2.x–6.9.1. No
/// behavior lives here. See `docs/business/flashcard/flashcard-management.md`
/// §Import preview flow, `docs/contracts/usecase-contracts/flashcard.md`
/// §Import, and `docs/contracts/types-catalog.md`.
///
/// Two stages:
/// - [FlashcardImportPreview] — output of parse + per-row validation
///   (candidate rows + [ImportValidationIssue]s). Drives the preview screen.
/// - [FlashcardImportPreparation] — output of duplicate detection over a clean
///   preview ([FlashcardImportDuplicatePolicy.skipExactDuplicates]): the
///   committable [previewItems] plus the [skippedDuplicates] breakdown.

/// A single candidate card parsed from the import source. V1 CSV carries
/// `front` + `back` only (no tags). Values are as-parsed; trimming/validation
/// is applied by the parse stage.
@freezed
sealed class FlashcardImportRow with _$FlashcardImportRow {
  const factory FlashcardImportRow({
    /// 1-based index of the record in the source (for issue/skip reporting).
    /// Equals the physical line for files without embedded newlines; a quoted
    /// field spanning lines counts as one record.
    required int lineNumber,
    required String front,
    required String back,
  }) = _FlashcardImportRow;
}

/// A per-row validation problem surfaced in the preview.
@freezed
sealed class ImportValidationIssue with _$ImportValidationIssue {
  const factory ImportValidationIssue({
    /// The category of the problem.
    required ImportRowIssueType kind,

    /// 1-based source line number the problem was found on.
    required int lineNumber,

    /// Localized, user-facing message (e.g. "Line 4: front is required.").
    required String message,
  }) = _ImportValidationIssue;
}

/// A row dropped by duplicate detection, with where it clashed.
@freezed
sealed class FlashcardImportSkippedDuplicate
    with _$FlashcardImportSkippedDuplicate {
  const factory FlashcardImportSkippedDuplicate({
    required int lineNumber,
    required String front,
    required String back,
    required FlashcardImportDuplicateSource source,
  }) = _FlashcardImportSkippedDuplicate;
}

/// Output of parse + validation: the candidate [rows] and any [issues].
///
/// Drives the preview screen summary ("Will import: N cards. Issues: K.") and
/// gates the commit CTA: commit is allowed only on a clean preview
/// ([canCommit]). The preview is read-only in V1 — the user edits the source
/// and re-parses, or cancels.
@freezed
sealed class FlashcardImportPreview with _$FlashcardImportPreview {
  const factory FlashcardImportPreview({
    @Default(<FlashcardImportRow>[]) List<FlashcardImportRow> rows,
    @Default(<ImportValidationIssue>[]) List<ImportValidationIssue> issues,
  }) = _FlashcardImportPreview;
  const FlashcardImportPreview._();

  /// True when there is at least one parsed row and no validation issues — the
  /// only state from which a commit may proceed (no silent partial import).
  bool get canCommit => rows.isNotEmpty && issues.isEmpty;

  /// True when any validation issue exists.
  bool get hasIssues => issues.isNotEmpty;

  /// The empty preview (no rows, no issues).
  static const FlashcardImportPreview empty = FlashcardImportPreview();
}

/// Output of duplicate detection over a clean [FlashcardImportPreview]: the
/// [previewItems] that will actually be committed plus the
/// [skippedDuplicates] breakdown by [FlashcardImportDuplicateSource].
@freezed
sealed class FlashcardImportPreparation with _$FlashcardImportPreparation {
  const factory FlashcardImportPreparation({
    @Default(<FlashcardImportRow>[]) List<FlashcardImportRow> previewItems,
    @Default(<FlashcardImportSkippedDuplicate>[])
    List<FlashcardImportSkippedDuplicate> skippedDuplicates,
  }) = _FlashcardImportPreparation;
  const FlashcardImportPreparation._();

  /// Number of rows that will be committed.
  int get importCount => previewItems.length;

  /// Number of rows skipped as duplicates.
  int get skippedCount => skippedDuplicates.length;

  /// The empty preparation.
  static const FlashcardImportPreparation empty = FlashcardImportPreparation();
}
