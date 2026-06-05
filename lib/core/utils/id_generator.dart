import 'dart:math';

/// Generates UUID-like text identifiers for entity primary keys.
///
/// `docs/database/schema-contract.md`: "IDs are text (UUID-like, generated via
/// `IdGenerator`)". Produces a RFC-4122 version-4 string without pulling in an
/// external `uuid` dependency.
abstract final class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  /// A new random v4 UUID, e.g. `3f2504e0-4f89-41d3-9a0c-0305e82c3301`.
  static String newId() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // Version 4 + RFC 4122 variant bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int start, int end) {
      final StringBuffer buffer = StringBuffer();
      for (int i = start; i < end; i++) {
        buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
      }
      return buffer.toString();
    }

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
