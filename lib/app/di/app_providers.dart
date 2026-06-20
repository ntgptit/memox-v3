import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_providers.g.dart';

/// App-level infrastructure providers shared across features.
///
/// This is the **only** place allowed to call `SharedPreferences.getInstance()`
/// (enforced by the `memox.architecture.centralized_shared_preferences_provider`
/// guard); feature DI must depend on [sharedPreferencesProvider] rather than
/// resolving the instance itself.

/// The app-scoped [SharedPreferences] instance. Long-lived, so `keepAlive`.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();
