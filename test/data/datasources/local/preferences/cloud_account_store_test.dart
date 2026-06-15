// ignore_for_file: depend_on_referenced_packages -- reason: test-only SharedPreferencesAsync platform helpers live in the transitive platform_interface package.

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/preferences/cloud_account_store.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String _key = 'account.cloudAccountLink';

CloudAccountLink _sampleLink() => const CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'sub-123',
  email: 'giap@gmail.com',
  displayName: 'Giap',
  grantedScopes: <String>{CloudAccountLink.googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1700000000000,
  lastSignedInAt: 1700000100000,
);

void main() {
  late SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = previousPlatform;
  });

  SharedPreferencesCloudAccountStore newStore() =>
      SharedPreferencesCloudAccountStore(SharedPreferencesAsync());

  test('AC1: no record returns null (signed out)', () async {
    expect(await newStore().load(), isNull);
  });

  test('round-trips a saved link', () async {
    final SharedPreferencesCloudAccountStore store = newStore();
    final CloudAccountLink link = _sampleLink();

    await store.save(link);

    expect(await store.load(), link);
  });

  test('clear removes the stored link', () async {
    final SharedPreferencesCloudAccountStore store = newStore();
    await store.save(_sampleLink());

    await store.clear();

    expect(await store.load(), isNull);
  });

  test('AC2: schema version mismatch returns null', () async {
    await SharedPreferencesAsync().setString(
      _key,
      '{"schemaVersion":999,"provider":"google","subjectId":"x",'
      '"email":"e","grantedScopes":[],'
      '"driveAuthorizationState":"authorized",'
      '"linkedAt":1,"lastSignedInAt":2}',
    );

    expect(await newStore().load(), isNull);
  });

  test('AC3: corrupt JSON returns null without throwing', () async {
    await SharedPreferencesAsync().setString(_key, '{not valid json');

    expect(await newStore().load(), isNull);
  });

  test('AC3: non-object JSON returns null', () async {
    await SharedPreferencesAsync().setString(_key, '42');

    expect(await newStore().load(), isNull);
  });

  test('missing required field returns null', () async {
    await SharedPreferencesAsync().setString(
      _key,
      '{"schemaVersion":1,"provider":"google",'
      '"driveAuthorizationState":"authorized",'
      '"linkedAt":1,"lastSignedInAt":2}',
    );

    expect(await newStore().load(), isNull);
  });
}
