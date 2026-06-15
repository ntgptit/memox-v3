import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';

void main() {
  CloudAccountLink linkWith({
    DriveAuthorizationState driveState = DriveAuthorizationState.authorized,
    Set<String> scopes = const <String>{
      CloudAccountLink.googleDriveAppDataScope,
    },
  }) => CloudAccountLink(
    provider: CloudProvider.google,
    subjectId: 'sub-1',
    email: 'a@b.com',
    grantedScopes: scopes,
    driveAuthorizationState: driveState,
    linkedAt: 10,
    lastSignedInAt: 20,
  );

  group('resolveAccountLinkStatus', () {
    test('unsupported platform dominates everything', () {
      expect(
        resolveAccountLinkStatus(
          link: linkWith(),
          isConfigured: true,
          isSupported: false,
        ),
        AccountLinkStatus.unsupported,
      );
    });

    test('unconfigured when supported but no OAuth config', () {
      expect(
        resolveAccountLinkStatus(
          link: null,
          isConfigured: false,
          isSupported: true,
        ),
        AccountLinkStatus.unconfigured,
      );
    });

    test('signedOut when configured and no link', () {
      expect(
        resolveAccountLinkStatus(
          link: null,
          isConfigured: true,
          isSupported: true,
        ),
        AccountLinkStatus.signedOut,
      );
    });

    test('signedIn when link is Drive-authorized', () {
      expect(
        resolveAccountLinkStatus(
          link: linkWith(),
          isConfigured: true,
          isSupported: true,
        ),
        AccountLinkStatus.signedIn,
      );
    });

    test('needsDriveAuthorization when link lacks Drive scope', () {
      expect(
        resolveAccountLinkStatus(
          link: linkWith(scopes: const <String>{}),
          isConfigured: true,
          isSupported: true,
        ),
        AccountLinkStatus.needsDriveAuthorization,
      );
    });
  });
}
