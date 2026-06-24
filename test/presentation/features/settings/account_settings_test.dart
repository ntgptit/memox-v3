import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/usecases/account_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

class _FakeController extends AccountController {
  _FakeController(this._status);
  final AccountLinkStatus _status;
  @override
  Future<AccountLinkStatus> build() async => _status;
}

class _FailingRepo implements AccountRepository {
  @override
  Future<Result<AccountLinkStatus>> loadStatus() async => (
    failure: const Failure.storage(operation: StorageOp.read, cause: 'x'),
    data: null,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountControllerProvider.overrideWith(
          () => _FakeController(AccountLinkStatus.signedOut),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountSettingsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('AccountSettingsScreen states', () {
    testWidgets('signed-out shows the sign-in hero with a disabled CTA', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Sign in to sync'), findsOneWidget);
      expect(
        find.textContaining('Back up your decks to Google Drive'),
        findsOneWidget,
      );
      final MxPrimaryButton button = tester.widget<MxPrimaryButton>(
        find.byType(MxPrimaryButton),
      );
      expect(button.onPressed, isNull); // disabled in V1
    });

    testWidgets('a load failure shows the error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadAccountStatusUseCaseProvider.overrideWith(
              (ref) async =>
                  LoadAccountStatusUseCase(repository: _FailingRepo()),
            ),
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
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text("Couldn't load account"), findsOneWidget);
    });
  });

  group('AccountSettingsScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('signed-out — ${brightness.name}', (tester) async {
        await _pump(tester, brightness: brightness, golden: true);
        await expectLater(
          find.byType(AccountSettingsScreen),
          matchesGoldenFile(
            'goldens/account_signed-out__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
