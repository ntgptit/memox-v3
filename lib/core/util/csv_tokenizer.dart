import 'package:csv/csv.dart';

/// Thin wrapper around the `csv` package's RFC-4180 parser (WBS 6.2.1).
///
/// Lives in `core/util` so the third-party parsing engine stays out of the
/// domain layer — domain use cases depend on this typed helper, the same way
/// they depend on `StringUtils`. Returns each record as a `List<String>`
/// (cells trimmed, fully typed); row/field semantics (header, blank lines,
/// column count, validation) are the caller's concern.
abstract final class CsvTokenizer {
  /// Tokenizes [raw] into records of trimmed string cells, splitting on
  /// [fieldDelimiter] (a single character; defaults to comma). Row delimiters
  /// CRLF / CR / LF are all normalized to LF before parsing — note this also
  /// normalizes any CR/CRLF that appears INSIDE a quoted field to LF (acceptable
  /// for clipboard/paste import). Quoted separators, `""`-escaped quotes, and
  /// LF-in-quotes are handled by the library. An empty/blank input returns `[]`.
  static List<List<String>> tokenize(
    String raw, {
    String fieldDelimiter = ',',
  }) {
    if (raw.trim().isEmpty) {
      return const <List<String>>[];
    }
    final String normalized = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final String delimiter = fieldDelimiter.isEmpty
        ? ','
        : fieldDelimiter.substring(0, 1);
    final List<List<Object?>> records = CsvToListConverter(
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(normalized).cast<List<Object?>>();
    return <List<String>>[
      for (final List<Object?> record in records)
        <String>[for (final Object? cell in record) '${cell ?? ''}'.trim()],
    ];
  }
}
