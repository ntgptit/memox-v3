/// Small pure string helpers shared across layers.
abstract final class StringUtils {
  const StringUtils._();

  /// Normalize a search query: trim, lowercase, and collapse runs of internal
  /// whitespace to a single space. Used by `GlobalSearchUseCase` before the
  /// min-length check and before binding the LIKE pattern (case-insensitive,
  /// whitespace-collapsed query — `docs/business/search/global-search.md`).
  static String normalizeQuery(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Escape the LIKE wildcards `%` and `_` plus the escape character `\` itself
  /// so a raw user query is matched literally. The caller must declare
  /// `ESCAPE '\'` on the LIKE clause. Order matters: escape the backslash first.
  static String escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
