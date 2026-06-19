/// Application-wide constants that are not theme tokens, routes, or copy.
abstract final class AppConstants {
  const AppConstants._();

  /// Base name of the local Drift database file. The active account suffixes
  /// this (guest vs Google account) for per-account database isolation — see
  /// `docs/database/schema-contract.md` §Per-account database isolation. The
  /// baseline ships the guest database only.
  static const String localDatabaseName = 'memox';
}
