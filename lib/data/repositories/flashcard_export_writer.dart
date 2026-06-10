import 'package:memox/core/utils/string_utils.dart';

/// Shared helpers for deck CSV export.
abstract final class FlashcardExportWriter {
  FlashcardExportWriter._();

  static const String csvMimeType = 'text/csv';
  static const String csvExtension = '.csv';

  static String buildCsv(Iterable<({String front, String back})> rows) {
    final StringBuffer buffer = StringBuffer('front,back');
    for (final ({String front, String back}) row in rows) {
      buffer
        ..write('\n')
        ..write(escapeCsvCell(row.front))
        ..write(',')
        ..write(escapeCsvCell(row.back));
    }
    return buffer.toString();
  }

  static String buildDeckFileName({
    required String deckName,
    required String deckId,
  }) {
    final String sanitizedDeckName = _sanitizeFileNameBase(deckName);
    if (sanitizedDeckName.isNotEmpty) {
      return '$sanitizedDeckName$csvExtension';
    }

    final String sanitizedDeckId = _sanitizeFileNameBase(deckId);
    if (sanitizedDeckId.isNotEmpty) {
      return 'deck_export_$sanitizedDeckId$csvExtension';
    }

    return 'deck_export$csvExtension';
  }

  static String escapeCsvCell(String value) {
    final bool needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.startsWith(' ') ||
        value.endsWith(' ');
    if (!needsQuotes) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  static String _sanitizeFileNameBase(String value) {
    final String trimmed = StringUtils.trimmed(value);
    if (trimmed.isEmpty) {
      return '';
    }

    final String unsafeReplaced = trimmed.replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F\s]+'),
      '_',
    );
    final String sanitized = unsafeReplaced
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[_.]+|[_.]+$'), '');
    if (sanitized.isEmpty || _isReservedWindowsName(sanitized)) {
      return '';
    }
    return sanitized;
  }

  static bool _isReservedWindowsName(String value) {
    final String upper = StringUtils.uppercased(value);
    return _reservedWindowsNames.contains(upper);
  }

  static const Set<String> _reservedWindowsNames = <String>{
    'AUX',
    'CON',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
    'NUL',
    'PRN',
  };
}
