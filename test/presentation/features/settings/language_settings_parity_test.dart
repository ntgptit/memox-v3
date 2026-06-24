import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/features/settings/screens/language_settings_screen.dart';

import '../../../support/parity_contract.dart';

class _FakeController extends LanguageController {
  _FakeController(this._language);
  final AppLanguage _language;
  @override
  Future<AppLanguage> build() async => _language;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  testWidgets('25-language: language-list node', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageControllerProvider.overrideWith(
            () => _FakeController(AppLanguage.system),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LanguageSettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expectParityContract('25-language', <String, Finder>{
      'language list': _node('25-language/language-list'),
    });
  });
}
