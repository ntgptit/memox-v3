/// Small pure string helpers shared across layers.
abstract final class StringUtils {
  const StringUtils._();

  /// Normalize a search query: trim, lowercase, and collapse runs of internal
  /// whitespace to a single space. Used by `GlobalSearchUseCase` before the
  /// min-length check and before binding the LIKE pattern (case-insensitive,
  /// whitespace-collapsed query — `docs/business/search/global-search.md`).
  static String normalizeQuery(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Trim leading/trailing whitespace. The single sanctioned trim entry point
  /// for domain/presentation code (`memox.coding.string_normalization_via_string_utils`).
  static String trimmed(String value) => value.trim();

  /// Case-fold a value for case-insensitive comparison/matching (lowercase
  /// only, no trimming or whitespace collapse). Centralizes case normalization
  /// so comparison semantics stay consistent across search, dedupe, and
  /// matching, satisfying the `memox.coding.string_normalization_via_string_utils`
  /// guard rule for domain/presentation code.
  static String caseFold(String value) => value.toLowerCase();

  /// Upper-case a value for display (e.g. an overline label). The sanctioned
  /// upper-case entry point so presentation code does not call `toUpperCase`
  /// inline (`memox.coding.string_normalization_via_string_utils`).
  static String upperFold(String value) => value.toUpperCase();

  /// Normalize a tag name to its stored identity: trim, strip any leading `#`
  /// hash(es) (`#weak` → `weak`, decision row TG1), then lowercase (no internal
  /// whitespace collapse). The single normalization point for tags across the
  /// validator, use cases, and repository.
  static String normalizeTag(String value) =>
      value.trim().replaceFirst(RegExp(r'^#+\s*'), '').toLowerCase();

  /// Escape the LIKE wildcards `%` and `_` plus the escape character `\` itself
  /// so a raw user query is matched literally. The caller must declare
  /// `ESCAPE '\'` on the LIKE clause. Order matters: escape the backslash first.
  static String escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
