import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/types/account_link_status.dart';

/// Loads the current Google-account link status (kit screen 21). Pure
/// delegation — presence/corruption handling lives in the repository.
class LoadAccountStatusUseCase {
  const LoadAccountStatusUseCase({required this.repository});

  final AccountRepository repository;

  Future<Result<AccountLinkStatus>> call() => repository.loadStatus();
}
