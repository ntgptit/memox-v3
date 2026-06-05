// Platform-agnostic entry point for opening the Drift executor. The concrete
// implementation is selected at compile time so platform-specific connection
// details stay isolated from `AppDatabase`:
//   * native (mobile/desktop) → `database_connection_native.dart`
//   * web                     → `database_connection_web.dart`
export 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';
