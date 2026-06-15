import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/cloud_account_link.dart';

/// Read access to the linked cloud account
/// (`docs/contracts/usecase-contracts/account-sync.md`). Sign-in / sign-out /
/// disconnect land with WBS 8.6.1.
abstract interface class CloudAccountRepository {
  /// Loads the current link, or `Ok(null)` when not linked.
  Future<Result<CloudAccountLink?>> loadLink();
}
