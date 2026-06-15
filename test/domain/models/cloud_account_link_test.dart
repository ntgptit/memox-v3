import 'package:flutter_test/flutter_test.dart';
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

  group('driveAppDataAuthorized', () {
    test('true when authorized AND scope granted', () {
      expect(linkWith().driveAppDataAuthorized, isTrue);
    });

    test('false when scope missing', () {
      expect(
        linkWith(scopes: const <String>{}).driveAppDataAuthorized,
        isFalse,
      );
    });

    test('false when not authorized', () {
      expect(
        linkWith(
          driveState: DriveAuthorizationState.authorizationRequired,
        ).driveAppDataAuthorized,
        isFalse,
      );
    });
  });

  group('fromJson/toJson', () {
    test('round-trips through toJson', () {
      final CloudAccountLink link = linkWith();
      expect(CloudAccountLink.fromJson(link.toJson()), link);
    });

    test('returns null on version mismatch', () {
      final Map<String, Object?> json = linkWith().toJson()
        ..['schemaVersion'] = 2;
      expect(CloudAccountLink.fromJson(json), isNull);
    });

    test('returns null on empty subjectId', () {
      final Map<String, Object?> json = linkWith().toJson()..['subjectId'] = '';
      expect(CloudAccountLink.fromJson(json), isNull);
    });

    test('returns null on unknown enum name', () {
      final Map<String, Object?> json = linkWith().toJson()
        ..['driveAuthorizationState'] = 'bogus';
      expect(CloudAccountLink.fromJson(json), isNull);
    });

    test('tolerates missing optional fields', () {
      final CloudAccountLink? link = CloudAccountLink.fromJson(
        <String, Object?>{
          'schemaVersion': 1,
          'provider': 'google',
          'subjectId': 'sub-1',
          'email': 'a@b.com',
          'grantedScopes': <String>[CloudAccountLink.googleDriveAppDataScope],
          'driveAuthorizationState': 'authorized',
          'linkedAt': 10,
          'lastSignedInAt': 20,
        },
      );
      expect(link, isNotNull);
      expect(link!.displayName, isNull);
      expect(link.photoUrl, isNull);
    });
  });
}
