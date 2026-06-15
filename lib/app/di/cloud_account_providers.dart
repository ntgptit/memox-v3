import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/data/repositories/cloud_account_repository_impl.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';
import 'package:memox/domain/usecases/cloud_account_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_account_providers.g.dart';

@Riverpod(keepAlive: true)
CloudAccountStore cloudAccountStore(Ref ref) =>
    SharedPreferencesCloudAccountStore(
      ref.watch(sharedPreferencesAsyncProvider),
    );

@Riverpod(keepAlive: true)
CloudAccountRepository cloudAccountRepository(Ref ref) =>
    CloudAccountRepositoryImpl(ref.watch(cloudAccountStoreProvider));

@Riverpod(keepAlive: true)
LoadCloudAccountLinkUseCase loadCloudAccountLinkUseCase(Ref ref) =>
    LoadCloudAccountLinkUseCase(ref.watch(cloudAccountRepositoryProvider));

/// Whether the build carries OAuth config for the current platform. Drives the
/// `unconfigured` account state.
@riverpod
bool googleOAuthConfigured(Ref ref) => GoogleOAuthConfig.isConfigured;

/// Whether the current platform supports Google sign-in. V1 display-only
/// returns `true`; WBS 8.6.1 refines this per platform.
@riverpod
bool googleSignInSupported(Ref ref) => true;
