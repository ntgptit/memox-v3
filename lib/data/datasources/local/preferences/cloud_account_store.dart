import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the cloud-account link payload.
///
/// The link is persisted in SharedPreferences ONLY (never Drift — that would
/// create a chicken-and-egg with the per-account DB), per
/// `docs/contracts/usecase-contracts/account-sync.md` §Account entity & store.
///
/// V1 (display-only) never writes a link — nothing is signed in yet — so
/// [readLink] always returns `null`. The full `CloudAccountLink` JSON
/// serialization lands with interactive sign-in (WBS 8.6.1).
class CloudAccountStore {
  CloudAccountStore(this._prefs);

  final SharedPreferences _prefs;

  /// Persisted SharedPreferences key, per
  /// `docs/database/storage-boundaries.md` §Account link.
  static const String cloudAccountLinkKey = 'account.cloudAccountLink';

  /// The stored `CloudAccountLink` JSON payload, or `null` when not linked.
  /// Reading a value stored under the wrong type returns `null` (treated as not
  /// linked) instead of throwing.
  String? readLink() {
    final Object? value = _prefs.get(cloudAccountLinkKey);
    return value is String ? value : null;
  }

  Future<void> writeLink(String payload) =>
      _prefs.setString(cloudAccountLinkKey, payload);

  Future<void> clear() => _prefs.remove(cloudAccountLinkKey);
}
