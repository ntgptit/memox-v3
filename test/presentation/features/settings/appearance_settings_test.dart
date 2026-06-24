import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/appearance_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/repositories/appearance_settings_repository.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/domain/usecases/appearance_settings_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/appearance_controller.dart';
import 'package:memox/presentation/features/settings/screens/appearance_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_radio.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

class _FakeController extends AppearanceController {
  _FakeController(this._mode);
  final AppThemeMode _mode;
  @override
  Future<AppThemeMode> build() async => _mode;
}

class _FailingRepo implements AppearanceSettingsRepository {
  @override
  Future<Result<AppThemeMode>> load() async => (
    failure: const Failure.storage(operation: StorageOp.read, cause: 'x'),
    data: null,
  );
  @override
  Future<Result<void>> save(AppThemeMode mode) async =>
      (failure: null, data: null);
}

Future<void> _pump(
  WidgetTester tester, {
  required AppThemeMode mode,
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
        appearanceControllerProvider.overrideWith(() => _FakeController(mode)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AppearanceSettingsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('AppearanceSettingsScreen states', () {
    testWidgets('renders the three theme options', (tester) async {
      await _pump(tester, mode: AppThemeMode.system);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Match device setting'), findsOneWidget);
      expect(find.byType(MxRadio), findsNWidgets(3));
    });

    testWidgets('a load failure shows the error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadAppearanceSettingsUseCaseProvider.overrideWith(
              (ref) async =>
                  LoadAppearanceSettingsUseCase(repository: _FailingRepo()),
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
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text("Couldn't load appearance"), findsOneWidget);
    });
  });

  group('AppearanceSettingsScreen goldens', () {
    for (final AppThemeMode mode in AppThemeMode.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${mode.storageValue} — ${brightness.name}', (
          tester,
        ) async {
          await _pump(tester, mode: mode, brightness: brightness, golden: true);
          await expectLater(
            find.byType(AppearanceSettingsScreen),
            matchesGoldenFile(
              'goldens/appearance_${mode.storageValue}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
