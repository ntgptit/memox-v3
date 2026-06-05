/// Google OAuth configuration for Drive AppData sync.
///
/// The only scope MemoX requests is Drive AppData (the app sees only files it
/// created in a hidden per-app folder). Client IDs are injected at build time
/// via `--dart-define` so no secret lives in source; when they are absent the
/// account/sync layer reports the `unconfigured` state.
///
/// See `docs/business/account-sync/account-sync.md`. The scope constant mirrors
/// `googleDriveAppDataScope` on the domain `CloudAccountLink` entity.
abstract final class GoogleOAuthConfig {
  GoogleOAuthConfig._();

  static const String driveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';

  /// All OAuth scopes requested at sign-in.
  static const List<String> scopes = <String>[driveAppDataScope];

  /// Web/Android server client id (`--dart-define=GOOGLE_SERVER_CLIENT_ID=...`).
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// iOS/macOS client id (`--dart-define=GOOGLE_IOS_CLIENT_ID=...`).
  static const String iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  /// True when at least one platform client id was provided at build time.
  static bool get isConfigured =>
      serverClientId.isNotEmpty || iosClientId.isNotEmpty;
}
