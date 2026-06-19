import 'package:memox/data/datasources/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

/// Singleton [AppDatabase] provider.
///
/// The database is a long-lived, app-scoped resource (one connection per
/// account), so it is `keepAlive`; it is closed when the provider is disposed.
/// DAOs/repositories depend on this provider — never construct [AppDatabase]
/// directly outside it.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
