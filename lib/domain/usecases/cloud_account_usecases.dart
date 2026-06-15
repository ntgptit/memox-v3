import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';

/// Reads the current cloud account link from the store
/// (`docs/contracts/usecase-contracts/account-sync.md` §LoadCloudAccountLinkUseCase).
class LoadCloudAccountLinkUseCase {
  const LoadCloudAccountLinkUseCase(this._repository);

  final CloudAccountRepository _repository;

  Future<Result<CloudAccountLink?>> call() => _repository.loadLink();
}
