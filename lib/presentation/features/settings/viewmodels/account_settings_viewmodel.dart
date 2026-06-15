import 'package:memox/app/di/cloud_account_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_settings_viewmodel.g.dart';

/// Loads the stored account link and resolves the display status for the
/// Account settings screen. On a storage failure the provider throws the
/// [Failure] so the screen's `AsyncValue.error` branch renders the error state.
@riverpod
Future<AccountSettingsView> accountSettingsView(Ref ref) async {
  final bool isConfigured = ref.watch(googleOAuthConfiguredProvider);
  final bool isSupported = ref.watch(googleSignInSupportedProvider);
  final result = await ref.watch(loadCloudAccountLinkUseCaseProvider).call();
  return result.fold(
    // ignore: only_throw_errors -- reason: Riverpod surfaces repository Failure as AsyncError.
    (Failure failure) => throw failure,
    (CloudAccountLink? link) => AccountSettingsView(
      status: resolveAccountLinkStatus(
        link: link,
        isConfigured: isConfigured,
        isSupported: isSupported,
      ),
      link: link,
    ),
  );
}
