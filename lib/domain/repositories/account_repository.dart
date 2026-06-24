import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/account_link_status.dart';

/// Port for reading the Google-account link status (kit screen 21). V1 is
/// read-only and display-only: interactive sign-in / Drive sync (which would add
/// `signIn`/`disconnect`/`authorizeDrive` here) land in WBS 8.6.1/8.6.2.
///
/// See `docs/contracts/repository-contracts/account-repository.md`.
abstract interface class AccountRepository {
  /// Read the current link status from `CloudAccountStore`. A missing or
  /// corrupt link resolves to [AccountLinkStatus.signedOut].
  ///
  /// Fails with [StorageFailure] on a SharedPreferences read error.
  Future<Result<AccountLinkStatus>> loadStatus();
}
