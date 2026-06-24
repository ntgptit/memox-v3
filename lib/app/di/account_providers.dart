import 'package:memox/app/di/app_providers.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/data/repositories/account_repository_impl.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/usecases/account_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_providers.g.dart';

/// Dependency-injection wiring for the cloud-account link (V1 display-only):
/// SharedPreferences → store → repository → use case. The SharedPreferences
/// instance comes from the app-level [sharedPreferencesProvider].

@Riverpod(keepAlive: true)
Future<AccountRepository> accountRepository(Ref ref) async {
  final SharedPreferences prefs = await ref.watch(
    sharedPreferencesProvider.future,
  );
  return AccountRepositoryImpl(store: CloudAccountStore(prefs));
}

// Async because the dependency chain bottoms out at the async
// [sharedPreferencesProvider]; consumers await `.future` / observe `AsyncValue`.
@riverpod
Future<LoadAccountStatusUseCase> loadAccountStatusUseCase(Ref ref) async =>
    LoadAccountStatusUseCase(
      repository: await ref.watch(accountRepositoryProvider.future),
    );
