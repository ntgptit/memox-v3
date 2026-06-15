/// Cloud sync provider. Only Google is supported in V1
/// (`docs/business/account-sync/account-sync.md` §Provider).
enum CloudProvider { google }

/// Account link status surfaced by the Account settings screen
/// (`docs/business/account-sync/account-sync.md` §Account link statuses).
enum AccountLinkStatus {
  /// No link, or the user signed out.
  signedOut,

  /// Linked and Drive AppData authorized.
  signedIn,

  /// Linked but the Drive scope is missing or was revoked.
  needsDriveAuthorization,

  /// The build lacks OAuth config for the current platform.
  unconfigured,

  /// The platform does not support Google sign-in.
  unsupported,

  /// The last operation failed.
  error,
}

/// Drive AppData authorization state for a linked account.
enum DriveAuthorizationState {
  notRequested,
  authorized,
  authorizationRequired,
  denied,
}
