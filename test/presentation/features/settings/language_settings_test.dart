import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/language_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/repositories/language_settings_repository.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/usecases/language_settings_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/language_controller.dart';
import 'package:memox/presentation/features/settings/screens/language_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_radio.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

class _FakeController extends LanguageController {
  _FakeController(this._language);
  final AppLanguage _language;
  @override
  Future<AppLanguage> build() async => _language;
}

class _FailingRepo implements LanguageSettingsRepository {
  @override
  Future<Result<AppLanguage>> load() async => (
    failure: const Failure.storage(operation: StorageOp.read, cause: 'x'),
    data: null,
  );
  @override
  Future<Result<void>> save(AppLanguage language) async =>
      (failure: null, data: null);
}

Future<void> _pump(
  WidgetTester tester, {
  required AppLanguage language,
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
        languageControllerProvider.overrideWith(
          () => _FakeController(language),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LanguageSettingsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('LanguageSettingsScreen states', () {
    testWidgets('renders the three language options', (tester) async {
      await _pump(tester, language: AppLanguage.english);
      expect(find.text('App language'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.text('English'), findsWidgets); // title + desc
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('Vietnamese'), findsOneWidget);
      expect(find.byType(MxRadio), findsNWidgets(3));
    });

    testWidgets('a load failure shows the error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadLanguageSettingsUseCaseProvider.overrideWith(
              (ref) async =>
                  LoadLanguageSettingsUseCase(repository: _FailingRepo()),
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
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text("Couldn't load language"), findsOneWidget);
    });
  });

  group('LanguageSettingsScreen goldens', () {
    for (final AppLanguage language in AppLanguage.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${language.storageValue} — ${brightness.name}', (
          tester,
        ) async {
          await _pump(
            tester,
            language: language,
            brightness: brightness,
            golden: true,
          );
          await expectLater(
            find.byType(LanguageSettingsScreen),
            matchesGoldenFile(
              'goldens/language_${language.storageValue}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
