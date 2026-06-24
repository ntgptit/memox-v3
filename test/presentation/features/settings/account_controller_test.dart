import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/data/repositories/account_repository_impl.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/usecases/account_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements AccountRepository {
  _FakeRepo(this.status);
  AccountLinkStatus status;
  @override
  Future<Result<AccountLinkStatus>> loadStatus() async =>
      (failure: null, data: status);
}

void main() {
  group('AccountRepositoryImpl', () {
    test('no stored link → signedOut', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final AccountRepositoryImpl repo = AccountRepositoryImpl(
        store: CloudAccountStore(prefs),
      );
      final Result<AccountLinkStatus> result = await repo.loadStatus();
      expect(result.data, AccountLinkStatus.signedOut);
    });

    test('a stored link payload → signedIn', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        CloudAccountStore.cloudAccountLinkKey: '{"subjectId":"x"}',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final AccountRepositoryImpl repo = AccountRepositoryImpl(
        store: CloudAccountStore(prefs),
      );
      final Result<AccountLinkStatus> result = await repo.loadStatus();
      expect(result.data, AccountLinkStatus.signedIn);
    });
  });

  group('AccountController', () {
    test('loads the status (signedOut in V1)', () async {
      final _FakeRepo repo = _FakeRepo(AccountLinkStatus.signedOut);
      final ProviderContainer container = ProviderContainer(
        overrides: [
          loadAccountStatusUseCaseProvider.overrideWith(
            (ref) async => LoadAccountStatusUseCase(repository: repo),
          ),
        ],
      );
      addTearDown(container.dispose);

      final AccountLinkStatus status = await container.read(
        accountControllerProvider.future,
      );
      expect(status, AccountLinkStatus.signedOut);
    });
  });
}
