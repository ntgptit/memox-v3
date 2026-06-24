import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/types/account_link_status.dart';

/// SharedPreferences-backed [AccountRepository] (V1 display-only).
///
/// V1 derives the status from link PRESENCE only: no stored link →
/// [AccountLinkStatus.signedOut]. Because interactive sign-in is not built yet
/// (WBS 8.6.1), no link is ever stored, so this always resolves to `signedOut`.
/// When sign-in lands, parsing the stored `CloudAccountLink` JSON into the full
/// status set replaces the presence check here.
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({required CloudAccountStore store}) : _store = store;

  final CloudAccountStore _store;

  @override
  Future<Result<AccountLinkStatus>> loadStatus() async {
    try {
      final String? link = _store.readLink();
      return (
        failure: null,
        data: link == null
            ? AccountLinkStatus.signedOut
            : AccountLinkStatus.signedIn,
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'cloud_account_link',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
