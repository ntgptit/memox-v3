import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Stable database name for the web (IndexedDB-backed) store.
const String memoxDatabaseName = 'memox';

/// Opens the web Drift executor backed by the `sqlite3.wasm` + `drift_worker.js`
/// assets (place them under `web/`; see https://drift.simonbinder.eu/web/).
QueryExecutor openMemoxConnection() => LazyDatabase(() async {
  final WasmDatabaseResult result = await WasmDatabase.open(
    databaseName: memoxDatabaseName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
});
