import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';

import '../../../support/parity_contract.dart';

class _FakeController extends AccountController {
  _FakeController(this._status);
  final AccountLinkStatus _status;
  @override
  Future<AccountLinkStatus> build() async => _status;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  Future<void> pump(WidgetTester tester, AccountLinkStatus status) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountControllerProvider.overrideWith(() => _FakeController(status)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AccountSettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('21-account-sync: signed-out nodes', (tester) async {
    await pump(tester, AccountLinkStatus.signedOut);
    expectParityContract('21-account-sync', <String, Finder>{
      'sign-in card': _node('21-account-sync/signin-card'),
      'sign-in button': _node('21-account-sync/signin-button'),
    });
  });

  testWidgets(
    '21-account-sync binding contract (keyed nodes realize kit components)',
    (tester) async {
      await pump(tester, AccountLinkStatus.signedOut);
      // signed-out state: signin-card → MxCard, signin-button → MxPrimaryButton.
      expectGeneratedBindingContract('21-account-sync');
    },
  );
}
