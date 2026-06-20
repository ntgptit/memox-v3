/// The column separator used when parsing [ImportSourceFormat.structuredText].
///
/// Pins the import type-contract (WBS 6.0.1); the parsing logic lands in
/// WBS 6.9.1. See `docs/business/flashcard/flashcard-management.md`
/// §Import sources and `docs/contracts/types-catalog.md` §ImportTextSeparator.
enum ImportTextSeparator {
  /// Infer the separator by frequency analysis of the first non-empty line.
  /// A tie between candidates is treated as invalid input.
  auto,

  /// Tab (`\t`).
  tab,

  /// Comma (`,`).
  comma,

  /// Colon (`:`).
  colon,

  /// Slash (`/`).
  slash,

  /// Semicolon (`;`).
  semicolon,

  /// Pipe (`|`).
  pipe,
}
