/// The source format a deck import is parsed from.
///
/// Pins the import type-contract (WBS 6.0.1) so every import use case
/// (parse/prepare/commit) shares one vocabulary; the parsing logic itself lands
/// in WBS 6.2.x. See `docs/business/flashcard/flashcard-management.md`
/// §Import sources and `docs/contracts/types-catalog.md` §ImportSourceFormat.
enum ImportSourceFormat {
  /// Pasted CSV text. The only Current V1 source: parse → validation preview →
  /// transactional commit of valid rows only. Optional columns are ignored;
  /// CSV V1 does not parse tags.
  csv,

  /// Spreadsheet (first sheet). **Future** — deferred, needs dependency
  /// approval. `excelHasHeader` decides whether row 1 is skipped.
  excel,

  /// Delimiter-separated text. Backend-supported; UI entry deferred. The
  /// separator is one of [ImportTextSeparator].
  structuredText,
}
