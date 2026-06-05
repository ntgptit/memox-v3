/// Minimal account identity returned by a successful Google sign-in.
///
/// Kept free of PII in logs: only [subjectId] (opaque) is loggable; never log
/// [email] (`docs/quality/observability-contract.md`).
class GoogleAccountInfo {
  const GoogleAccountInfo({
    required this.subjectId,
    required this.email,
    required this.grantedScopes,
  });

  /// Stable opaque Google account id (the OAuth `sub`).
  final String subjectId;
  final String email;
  final Set<String> grantedScopes;
}

/// Port for interactive Google authentication + Drive AppData authorization.
///
/// Defined in core so domain/data depend on the abstraction, not the
/// `google_sign_in` plugin. The concrete `google_sign_in`-backed implementation
/// ships with the account-sync feature (it returns/consumes the domain
/// `CloudAccountLink` types); see
/// `docs/business/account-sync/account-sync.md` and
/// `lib/core/config/google_oauth_config.dart`.
abstract interface class GoogleAuthGateway {
  /// Interactive sign-in, requesting the Drive AppData scope.
  Future<GoogleAccountInfo> signIn();

  /// Adds the Drive AppData scope to an already-linked account.
  Future<GoogleAccountInfo> authorizeDrive();

  /// Local sign-out (does not revoke server-side grants).
  Future<void> signOut();

  /// Revokes the grant server-side; next sign-in re-prompts for Drive scope.
  Future<void> disconnect();

  /// A short-lived Drive access token for a single API call, or `null` when no
  /// account is authorized.
  Future<String?> driveAccessToken();
}
