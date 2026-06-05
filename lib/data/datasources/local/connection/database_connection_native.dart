import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stable on-disk database file name (kept constant across releases so the same
/// database is reopened).
const String memoxDatabaseFileName = 'memox.sqlite';

/// Opens the native (mobile/desktop) Drift executor.
///
/// Uses [LazyDatabase] so the file path (resolved via `path_provider`) is only
/// looked up on first access, and `createInBackground` so SQLite runs off the
/// UI isolate (the previous `shareAcrossIsolates` behaviour).
QueryExecutor openMemoxConnection() => LazyDatabase(() async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File(p.join(dir.path, memoxDatabaseFileName));
  return NativeDatabase.createInBackground(file);
});
