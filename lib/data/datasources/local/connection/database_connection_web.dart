import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:memox/core/constants/app_constants.dart';

/// Opens the web database executor backed by `WasmDatabase`.
///
/// Requires `sqlite3.wasm` and `drift_worker.js` to be served as web assets.
/// See `docs/database/drift-guide.md` §Layout.
QueryExecutor openConnection() => LazyDatabase(() async {
  final WasmDatabaseResult result = await WasmDatabase.open(
    databaseName: '${AppConstants.localDatabaseName}_guest',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return result.resolvedExecutor;
});
