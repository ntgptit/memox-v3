import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/account_settings_view.dart';
import 'package:memox/domain/models/cloud_account_link.dart';
import 'package:memox/domain/types/cloud_account.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/account_settings_viewmodel.dart';
// ignore: depend_on_referenced_packages -- reason: `Override` lives in package:riverpod (transitive), not re-exported by flutter_riverpod.
import 'package:riverpod/misc.dart';

CloudAccountLink _link() => const CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'sub-1',
  email: 'giap@gmail.com',
  grantedScopes: <String>{CloudAccountLink.googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 2,
);

Future<void> _pump(
  WidgetTester tester, {
  required Override override,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[override],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountSettingsScreen(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Override _viewIs(AccountSettingsView view) =>
    accountSettingsViewProvider.overrideWith((Ref ref) async => view);

void main() {
  testWidgets('signed-out shows heading, sign-in affordance, reassurance', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      override: _viewIs(
        const AccountSettingsView(status: AccountLinkStatus.signedOut),
      ),
    );

    expect(find.text('Sign in to back up your data'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign-in & sync are coming soon.'), findsOneWidget);
    expect(
      find.textContaining('Your data stays on this device only'),
      findsOneWidget,
    );
  });

  testWidgets('unconfigured shows the unavailable notice', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      override: _viewIs(
        const AccountSettingsView(status: AccountLinkStatus.unconfigured),
      ),
    );

    expect(
      find.text("Account sign-in isn't available in this build."),
      findsOneWidget,
    );
  });

  testWidgets('signed-in shows the account email and provider', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      override: _viewIs(
        AccountSettingsView(status: AccountLinkStatus.signedIn, link: _link()),
      ),
    );

    expect(find.text('giap@gmail.com'), findsOneWidget);
    expect(find.text('Signed in · Google'), findsOneWidget);
  });

  testWidgets('error state shows retry', (WidgetTester tester) async {
    await _pump(
      tester,
      override: accountSettingsViewProvider.overrideWith((Ref ref) async {
        // ignore: only_throw_errors -- reason: drives the AsyncError branch.
        throw const StorageFailure(operation: StorageOp.read, cause: 'x');
      }),
    );

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('loading state shows a progress indicator', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      override: accountSettingsViewProvider.overrideWith(
        (Ref ref) => Completer<AccountSettingsView>().future,
      ),
      settle: false,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
