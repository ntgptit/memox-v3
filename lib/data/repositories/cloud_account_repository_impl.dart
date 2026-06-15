import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';

class CloudAccountRepositoryImpl implements CloudAccountRepository {
  CloudAccountRepositoryImpl(this._store);

  final CloudAccountStore _store;

  @override
  Future<Result<CloudAccountLink?>> loadLink() async {
    try {
      return Result<CloudAccountLink?>.ok(await _store.load());
    } on Object catch (error) {
      return Result<CloudAccountLink?>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'shared_preferences',
        ),
      );
    }
  }
}
