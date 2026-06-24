import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/types/account_link_status.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/account_controller.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';

import '../../../support/parity_contract.dart';

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

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  testWidgets('20-settings: hub nodes', (tester) async {
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
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expectParityContract('20-settings', <String, Finder>{
      'account card': _node('20-settings/account-card'),
      'settings group': _node('20-settings/settings-group'),
    });
  });
}
