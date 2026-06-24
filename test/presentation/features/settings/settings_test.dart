import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/account_repository.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/domain/usecases/account_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

class _FakeAccount extends AccountController {
  @override
  Future<AccountLinkStatus> build() async => AccountLinkStatus.signedOut;
}

class _FakeLearning extends LearningSettingsController {
  @override
  Future<LearningSettingsView> build() async =>
      const LearningSettingsView(settings: LearningSettings(dailyNewLimit: 20));
}

class _FakeAppearance extends AppearanceController {
  @override
  Future<AppThemeMode> build() async => AppThemeMode.system;
}

class _FakeLanguage extends LanguageController {
  @override
  Future<AppLanguage> build() async => AppLanguage.english;
}

class _FailingAccountRepo implements AccountRepository {
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
        accountControllerProvider.overrideWith(_FakeAccount.new),
        learningSettingsControllerProvider.overrideWith(_FakeLearning.new),
        appearanceControllerProvider.overrideWith(_FakeAppearance.new),
        languageControllerProvider.overrideWith(_FakeLanguage.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    ),
  );
  // Settle all four watched controllers (account + learning/appearance/language)
  // so the live row values render. The loaded hub has no infinite animation.
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen hub', () {
    testWidgets('renders the account card + category rows with live values', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Not signed in'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Audio & speech'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Account & sync'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      // Live trailing values.
      expect(find.text('20/day'), findsOneWidget);
      expect(find.text('System'), findsOneWidget); // theme
      expect(find.text('English'), findsOneWidget); // language
    });

    testWidgets('an account load failure shows the error state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadAccountStatusUseCaseProvider.overrideWith(
              (ref) async =>
                  LoadAccountStatusUseCase(repository: _FailingAccountRepo()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text("Couldn't load settings"), findsOneWidget);
    });
  });

  group('SettingsScreen goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('signed-out — ${brightness.name}', (tester) async {
        await _pump(tester, brightness: brightness, golden: true);
        await expectLater(
          find.byType(SettingsScreen),
          matchesGoldenFile(
            'goldens/settings_signed-out__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
