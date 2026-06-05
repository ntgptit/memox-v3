import 'package:memox/data/datasources/local/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

/// The app-wide Drift [AppDatabase].
///
/// Infrastructure provider — `keepAlive` so the expensive connection is not
/// torn down with screen-scoped consumers
/// (`memox.infrastructure_provider_keep_alive_required`). Closed on dispose
/// (e.g. account switch invalidation).
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
