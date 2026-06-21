import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the native (mobile/desktop) database executor.
///
/// Runs off the UI isolate via `NativeDatabase.createInBackground` and enables
/// WAL journaling in the connection `setup` (foreign keys are enabled in the
/// migration `beforeOpen`). The file is the guest database; per-account naming
/// is layered on later — see `docs/database/schema-contract.md`.
QueryExecutor openConnection() => LazyDatabase(() async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File(
    p.join(dir.path, '${AppConstants.guestDatabaseStore}.sqlite'),
  );
  return NativeDatabase.createInBackground(
    file,
    setup: (database) => database.execute('PRAGMA journal_mode = WAL;'),
  );
});
