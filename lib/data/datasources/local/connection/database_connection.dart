/// Platform-isolated database connection.
///
/// Re-exports the correct `openConnection()` for the build target so platform
/// details never leak into `AppDatabase`: native (mobile/desktop) uses a
/// background `NativeDatabase`; web uses `WasmDatabase`. See
/// `docs/database/drift-guide.md` §Layout.
library;

export 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';
