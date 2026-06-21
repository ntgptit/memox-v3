/// Application-wide constants that are not theme tokens, routes, or copy.
abstract final class AppConstants {
  const AppConstants._();

  /// Base name of the local Drift database file. The active account suffixes
  /// this (guest vs Google account) for per-account database isolation — see
  /// `docs/database/schema-contract.md` §Per-account database isolation. The
  /// baseline ships the guest database only.
  static const String localDatabaseName = 'memox';

  /// Local-store generation, embedded in every on-device store name
  /// ([guestDatabaseStore]). Bumping it abandons all existing local databases
  /// in one move — a deliberate, destructive reset with no migration.
  ///
  /// Used only when a pre-release schema renumber leaves old dev stores carrying
  /// objects inconsistent with the current migration chain (the 2026-06 rebuild
  /// renumbered schema versions, so a stale store can have v6 study objects but
  /// a `user_version` ≤ 5 → `onUpgrade` re-runs a create step and fails, e.g.
  /// `index idx_study_sessions_resumable already exists`). Pre-release, local-
  /// first → there is no production data to migrate. See
  /// `docs/database/storage-boundaries.md` §Local store generation.
  static const int localStoreGeneration = 2;

  /// The guest database store name (web: IndexedDB/OPFS database name; native:
  /// file stem). Includes [localStoreGeneration] so a bump opens a fresh store.
  static String get guestDatabaseStore =>
      '${localDatabaseName}_guest_g$localStoreGeneration';
}
