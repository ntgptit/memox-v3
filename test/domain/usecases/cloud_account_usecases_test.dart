import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';
import 'package:memox/domain/types/cloud_account.dart';
import 'package:memox/domain/usecases/cloud_account_usecases.dart';

class _FakeRepo implements CloudAccountRepository {
  _FakeRepo(this._result);

  final Result<CloudAccountLink?> _result;

  @override
  Future<Result<CloudAccountLink?>> loadLink() async => _result;
}

void main() {
  test('returns the loaded link', () async {
    const CloudAccountLink link = CloudAccountLink(
      provider: CloudProvider.google,
      subjectId: 's',
      email: 'e@e.com',
      grantedScopes: <String>{CloudAccountLink.googleDriveAppDataScope},
      driveAuthorizationState: DriveAuthorizationState.authorized,
      linkedAt: 1,
      lastSignedInAt: 2,
    );
    final LoadCloudAccountLinkUseCase useCase = LoadCloudAccountLinkUseCase(
      _FakeRepo(const Result<CloudAccountLink?>.ok(link)),
    );

    final Result<CloudAccountLink?> result = await useCase();

    expect(result.valueOrNull, link);
  });

  test('passes through Ok(null) when not linked', () async {
    final LoadCloudAccountLinkUseCase useCase = LoadCloudAccountLinkUseCase(
      _FakeRepo(const Result<CloudAccountLink?>.ok(null)),
    );

    final Result<CloudAccountLink?> result = await useCase();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });

  test('propagates a storage failure', () async {
    final LoadCloudAccountLinkUseCase useCase = LoadCloudAccountLinkUseCase(
      _FakeRepo(
        const Result<CloudAccountLink?>.err(
          StorageFailure(operation: StorageOp.read, cause: 'boom'),
        ),
      ),
    );

    final Result<CloudAccountLink?> result = await useCase();

    expect(result.isErr, isTrue);
  });
}
