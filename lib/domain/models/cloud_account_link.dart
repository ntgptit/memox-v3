import 'package:memox/domain/types/cloud_account.dart';

/// Persisted record of a linked cloud account.
///
/// Stored in SharedPreferences (NOT Drift — that would create a chicken-and-egg
/// with the per-account database). See
/// `docs/business/account-sync/account-sync.md` §Storage of account link.
/// Corruption-tolerant: a malformed or version-mismatched payload decodes to
/// `null` and is treated as not linked.
class CloudAccountLink {
  const CloudAccountLink({
    required this.provider,
    required this.subjectId,
    required this.email,
    required this.grantedScopes,
    required this.driveAuthorizationState,
    required this.linkedAt,
    required this.lastSignedInAt,
    this.displayName,
    this.photoUrl,
  });

  /// Persisted schema version. A stored payload with a different version loads
  /// as `null` (re-link required).
  static const int schemaVersion = 1;

  /// The only OAuth scope MemoX requests.
  static const String googleDriveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';

  final CloudProvider provider;

  /// Google subject id (`sub` claim). Stable identifier across email changes.
  final String subjectId;
  final String email;
  final String? displayName;
  final String? photoUrl;

  /// OAuth scopes the user actually granted.
  final Set<String> grantedScopes;
  final DriveAuthorizationState driveAuthorizationState;

  /// First link time, epoch ms. Preserved across re-sign-in of the same
  /// [subjectId].
  final int linkedAt;

  /// Last successful auth, epoch ms.
  final int lastSignedInAt;

  /// True only when Drive is authorized AND the AppData scope was granted.
  bool get driveAppDataAuthorized =>
      driveAuthorizationState == DriveAuthorizationState.authorized &&
      grantedScopes.contains(googleDriveAppDataScope);

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'provider': provider.name,
    'subjectId': subjectId,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'grantedScopes': grantedScopes.toList(),
    'driveAuthorizationState': driveAuthorizationState.name,
    'linkedAt': linkedAt,
    'lastSignedInAt': lastSignedInAt,
  };

  /// Decodes a stored payload, or `null` on version mismatch / malformed data.
  static CloudAccountLink? fromJson(Map<String, Object?> json) {
    final Object? version = json['schemaVersion'];
    if (version is! int || version != schemaVersion) {
      return null;
    }
    final CloudProvider? provider = _enumByName(
      CloudProvider.values,
      json['provider'],
    );
    final DriveAuthorizationState? driveState = _enumByName(
      DriveAuthorizationState.values,
      json['driveAuthorizationState'],
    );
    final Object? subjectId = json['subjectId'];
    final Object? email = json['email'];
    final Object? linkedAt = json['linkedAt'];
    final Object? lastSignedInAt = json['lastSignedInAt'];
    if (provider == null ||
        driveState == null ||
        subjectId is! String ||
        subjectId.isEmpty ||
        email is! String ||
        linkedAt is! int ||
        lastSignedInAt is! int) {
      return null;
    }
    final Object? scopesRaw = json['grantedScopes'];
    return CloudAccountLink(
      provider: provider,
      subjectId: subjectId,
      email: email,
      displayName: json['displayName'] is String
          ? json['displayName'] as String
          : null,
      photoUrl: json['photoUrl'] is String ? json['photoUrl'] as String : null,
      grantedScopes: scopesRaw is List
          ? scopesRaw.whereType<String>().toSet()
          : <String>{},
      driveAuthorizationState: driveState,
      linkedAt: linkedAt,
      lastSignedInAt: lastSignedInAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudAccountLink &&
          other.provider == provider &&
          other.subjectId == subjectId &&
          other.email == email &&
          other.displayName == displayName &&
          other.photoUrl == photoUrl &&
          other.driveAuthorizationState == driveAuthorizationState &&
          other.linkedAt == linkedAt &&
          other.lastSignedInAt == lastSignedInAt &&
          _setEquals(other.grantedScopes, grantedScopes);

  @override
  int get hashCode => Object.hash(
    provider,
    subjectId,
    email,
    displayName,
    photoUrl,
    driveAuthorizationState,
    linkedAt,
    lastSignedInAt,
    Object.hashAllUnordered(grantedScopes),
  );
}

bool _setEquals(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) {
    return null;
  }
  for (final T value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}
