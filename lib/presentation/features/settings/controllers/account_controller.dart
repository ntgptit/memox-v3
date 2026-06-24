import 'package:memox/app/di/account_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/usecases/account_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

/// Drives the Account screen (kit screen 21). V1 is read-only and display-only:
/// it loads the [AccountLinkStatus] (always `signedOut` until interactive
/// sign-in lands in WBS 8.6.1) and the screen renders the sign-in hero. Sign-in
/// / Drive backup-restore actions (the other kit states) are Future.
@riverpod
class AccountController extends _$AccountController {
  @override
  Future<AccountLinkStatus> build() async {
    final LoadAccountStatusUseCase useCase = await ref.watch(
      loadAccountStatusUseCaseProvider.future,
    );
    final Result<AccountLinkStatus> result = await useCase.call();
    final Failure? failure = result.failure;
    if (failure != null) {
      throw _AccountException(failure);
    }
    return result.data ?? AccountLinkStatus.signedOut;
  }
}

/// Carries a domain [Failure] through `AsyncError` so the screen renders its
/// load-error state.
class _AccountException implements Exception {
  const _AccountException(this.failure);

  final Failure failure;

  @override
  String toString() => 'AccountException($failure)';
}
