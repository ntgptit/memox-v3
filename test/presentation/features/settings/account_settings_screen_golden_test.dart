import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/account_settings_viewmodel.dart';
// ignore: depend_on_referenced_packages -- reason: `Override` lives in package:riverpod (transitive), not re-exported by flutter_riverpod.
import 'package:riverpod/misc.dart';

CloudAccountLink _link({
  DriveAuthorizationState driveState = DriveAuthorizationState.authorized,
  Set<String> scopes = const <String>{CloudAccountLink.googleDriveAppDataScope},
}) => CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'sub-1',
  email: 'giap@gmail.com',
  displayName: 'Giap',
  grantedScopes: scopes,
  driveAuthorizationState: driveState,
  linkedAt: 1,
  lastSignedInAt: 2,
);

Future<void> _pump(
  WidgetTester tester,
  AccountSettingsView view,
  Brightness brightness,
) async {
  tester.view.physicalSize = const Size(390, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        accountSettingsViewProvider.overrideWith((Ref ref) async => view),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final Map<String, AccountSettingsView> states = <String, AccountSettingsView>{
    'signed-out': const AccountSettingsView(
      status: AccountLinkStatus.signedOut,
    ),
    'unconfigured': const AccountSettingsView(
      status: AccountLinkStatus.unconfigured,
    ),
    'unsupported': const AccountSettingsView(
      status: AccountLinkStatus.unsupported,
    ),
    'signed-in': AccountSettingsView(
      status: AccountLinkStatus.signedIn,
      link: _link(),
    ),
    'needs-drive-auth': AccountSettingsView(
      status: AccountLinkStatus.needsDriveAuthorization,
      link: _link(
        driveState: DriveAuthorizationState.authorizationRequired,
        scopes: const <String>{},
      ),
    ),
  };

  for (final MapEntry<String, AccountSettingsView> entry in states.entries) {
    for (final Brightness brightness in Brightness.values) {
      final String theme = brightness == Brightness.dark ? 'dark' : 'light';
      testWidgets('golden: ${entry.key} ($theme)', (WidgetTester tester) async {
        await _pump(tester, entry.value, brightness);
        await expectLater(
          find.byType(AccountSettingsScreen),
          matchesGoldenFile(
            'goldens/account-settings--${entry.key}--$theme.png',
          ),
        );
      });
    }
  }
}
