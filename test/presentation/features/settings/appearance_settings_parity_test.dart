import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/screens/appearance_settings_screen.dart';

import '../../../support/parity_contract.dart';

class _FakeController extends AppearanceController {
  _FakeController(this._mode);
  final AppThemeMode _mode;
  @override
  Future<AppThemeMode> build() async => _mode;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

void main() {
  testWidgets('24-appearance: theme-list node', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appearanceControllerProvider.overrideWith(
            () => _FakeController(AppThemeMode.system),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppearanceSettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expectParityContract('24-appearance', <String, Finder>{
      'theme list': _node('24-appearance/theme-list'),
    });
  });
}
