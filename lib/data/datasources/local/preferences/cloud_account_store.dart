import 'dart:convert';

import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage boundary for the linked cloud account
/// (`docs/business/account-sync/account-sync.md` §Storage of account link).
abstract interface class CloudAccountStore {
  /// Returns the stored link, or `null` when absent / version-mismatched /
  /// corrupt.
  Future<CloudAccountLink?> load();

  Future<void> save(CloudAccountLink link);

  Future<void> clear();
}

/// SharedPreferences-backed [CloudAccountStore]. Corruption-tolerant: any
/// malformed payload loads as `null` (treated as not linked).
class SharedPreferencesCloudAccountStore implements CloudAccountStore {
  SharedPreferencesCloudAccountStore(this._prefs);

  static const String _cloudAccountLinkKey = 'account.cloudAccountLink';

  final SharedPreferencesAsync _prefs;

  @override
  Future<CloudAccountLink?> load() async {
    final String? raw = await _readString(_cloudAccountLinkKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      return CloudAccountLink.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(CloudAccountLink link) async {
    await _prefs.setString(_cloudAccountLinkKey, jsonEncode(link.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_cloudAccountLinkKey);
  }

  Future<String?> _readString(String key) async {
    try {
      return await _prefs.getString(key);
    } on Object {
      return null;
    }
  }
}
