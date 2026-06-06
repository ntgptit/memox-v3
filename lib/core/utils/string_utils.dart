/// Canonical home for runtime string trimming, case normalization, matching,
/// and sorting.
///
/// Per the MemoX guard rule `app_string_normalization_uses_string_utils`, this
/// is the **only** place allowed to call `.trim()`, `.toLowerCase()`, and
/// `.toUpperCase()` directly. Routing all normalization here keeps search, tag,
/// comparison, and answer-matching semantics consistent across layers.
abstract final class StringUtils {
  StringUtils._();

  /// Whitespace-trimmed copy.
  static String trimmed(String value) => value.trim();

  /// Lowercased copy.
  static String lowercased(String value) => value.toLowerCase();

  /// Uppercased copy (e.g. for ALL-CAPS overline labels).
  static String uppercased(String value) => value.toUpperCase();

  /// Canonical form for comparison/search/tags: trimmed then lowercased.
  static String normalize(String value) => value.trim().toLowerCase();

  /// Canonical form for free-text search queries: trimmed, lowercased, and with
  /// internal whitespace runs collapsed to a single space
  /// (`docs/business/search/global-search.md` §V1 query input).
  static String normalizeQuery(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// First character upper-cased; remainder unchanged.
  static String capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  /// Case-insensitive equality on the normalized forms.
  static bool equalsIgnoreCase(String a, String b) =>
      a.toLowerCase() == b.toLowerCase();

  /// Case-insensitive comparator suitable for `List.sort`.
  static int compareIgnoreCase(String a, String b) =>
      a.toLowerCase().compareTo(b.toLowerCase());
}
