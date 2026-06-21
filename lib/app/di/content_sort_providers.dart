import 'package:memox/app/di/app_providers.dart';
import 'package:memox/data/datasources/local/preferences/content_sort_store.dart';
import 'package:memox/data/repositories/content_sort_repository_impl.dart';
import 'package:memox/domain/repositories/content_sort_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'content_sort_providers.g.dart';

/// DI for the global content-sort preference repository. Composition root: the
/// only place allowed to wire the data-layer store to the domain interface the
/// presentation notifier (`librarySortProvider`) depends on.
@Riverpod(keepAlive: true)
Future<ContentSortRepository> contentSortRepository(Ref ref) async {
  final SharedPreferences prefs = await ref.watch(
    sharedPreferencesProvider.future,
  );
  return ContentSortRepositoryImpl(ContentSortStore(prefs));
}
