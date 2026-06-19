import 'dart:math';

/// Generates UUID-like text ids for entity primary keys.
///
/// Ids are text (UUID v4 format) per `docs/database/schema-contract.md` §Rules.
/// Dependency-free (no `uuid` package) — adding a dependency needs approval per
/// the project's hard rules. Injected into repositories so tests can supply a
/// deterministic generator.
class IdGenerator {
  IdGenerator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  /// A random RFC-4122 version-4 UUID string (lowercase, hyphenated).
  String newId() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // Version 4 + RFC 4122 variant bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final String hex = bytes
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
