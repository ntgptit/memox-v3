/// Build flavor for the running app instance.
///
/// Controls developer-facing diagnostics (console logs, Riverpod observer)
/// without leaking into release builds.
enum AppFlavor { development, staging, production }

/// Immutable application configuration resolved once at bootstrap.
///
/// Wiring layer only: feature code reads this via DI, never constructs it.
final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.enableTalkerConsoleLogs,
    required this.enableRiverpodDiagnostics,
  });

  /// Local development: verbose logging + Riverpod observer on.
  const AppConfig.development()
    : this(
        flavor: AppFlavor.development,
        enableTalkerConsoleLogs: true,
        enableRiverpodDiagnostics: true,
      );

  /// Pre-release: console logs on, provider diagnostics off (less noise).
  const AppConfig.staging()
    : this(
        flavor: AppFlavor.staging,
        enableTalkerConsoleLogs: true,
        enableRiverpodDiagnostics: false,
      );

  /// Release: diagnostics off; errors still routed to the crash reporter.
  const AppConfig.production()
    : this(
        flavor: AppFlavor.production,
        enableTalkerConsoleLogs: false,
        enableRiverpodDiagnostics: false,
      );

  final AppFlavor flavor;
  final bool enableTalkerConsoleLogs;
  final bool enableRiverpodDiagnostics;

  bool get isProduction => flavor == AppFlavor.production;
  bool get isDevelopment => flavor == AppFlavor.development;
}
