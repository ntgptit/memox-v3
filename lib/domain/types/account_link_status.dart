/// The Google-account link status (kit screen 21 — Account sync). Canonical
/// model: `docs/business/account-sync/account-sync.md` §Account link statuses.
///
/// V1 (display-only, WBS 8.5.1) only ever resolves [signedOut] — interactive
/// Google sign-in + Drive sync (the other statuses) land in WBS 8.6.1/8.6.2.
enum AccountLinkStatus {
  /// No link, or the user signed out.
  signedOut,

  /// Linked and Drive authorized.
  signedIn,

  /// Linked but the Drive scope is missing/revoked.
  needsDriveAuthorization,

  /// The app lacks OAuth config for the current platform.
  unconfigured,

  /// The platform does not support Google sign-in.
  unsupported,

  /// The last operation failed.
  error,
}
