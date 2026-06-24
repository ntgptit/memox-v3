import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_slider.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../../../support/golden_harness.dart';

class _FailingRepo implements LearningSettingsRepository {
  @override
  Future<Result<LearningSettings>> load() async => (
    failure: const Failure.storage(operation: StorageOp.read, cause: 'x'),
    data: null,
  );
  @override
  Future<Result<void>> save(LearningSettings settings) async =>
      (failure: null, data: null);
}

class _FakeController extends LearningSettingsController {
  _FakeController(this._view);
  final LearningSettingsView _view;
  @override
  Future<LearningSettingsView> build() async => _view;
}

LearningSettingsView _goalOn() =>
    const LearningSettingsView(settings: LearningSettings(dailyNewLimit: 20));

LearningSettingsView _goalOff() => LearningSettingsView(
  settings: LearningSettings(
    dailyNewLimit: 20,
    goalDisabledSince: DateTime(2026, 1, 1),
  ),
);

LearningSettingsView _saving() => const LearningSettingsView(
  settings: LearningSettings(dailyNewLimit: 20),
  saving: true,
);

Future<void> _pump(
  WidgetTester tester, {
  required LearningSettingsView view,
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
        learningSettingsControllerProvider.overrideWith(
          () => _FakeController(view),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LearningSettingsScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('LearningSettingsScreen states', () {
    testWidgets('goal-on shows the count, slider and presets', (tester) async {
      await _pump(tester, view: _goalOn());
      expect(find.text('Daily goal'), findsOneWidget);
      expect(find.text('Cards to study each day'), findsOneWidget);
      expect(find.text('cards / day'), findsOneWidget);
      expect(find.byType(MxSlider), findsOneWidget);
      // The big count (20) and the selected preset chip both read "20".
      expect(find.text('20'), findsNWidgets(2));
      expect(find.text('30'), findsOneWidget); // a non-selected preset chip
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Daily reminder'), findsOneWidget);
      expect(find.text('No reminder set'), findsOneWidget);
    });

    testWidgets('goal-off collapses the goal controls', (tester) async {
      await _pump(tester, view: _goalOff());
      expect(find.text('Turned off — study freely'), findsOneWidget);
      expect(find.byType(MxSlider), findsNothing);
      expect(find.text('cards / day'), findsNothing);
    });

    testWidgets('saving shows the busy overlay', (tester) async {
      await _pump(tester, view: _saving());
      expect(find.text('Saving…'), findsOneWidget);
    });

    testWidgets('a load failure shows the error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadLearningSettingsUseCaseProvider.overrideWith(
              (ref) async =>
                  LoadLearningSettingsUseCase(repository: _FailingRepo()),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LearningSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
      expect(find.text("Couldn't load settings"), findsOneWidget);
    });
  });

  group('LearningSettingsScreen goldens', () {
    final Map<String, LearningSettingsView> cases =
        <String, LearningSettingsView>{
          'goal-on': _goalOn(),
          'goal-off': _goalOff(),
          'saving': _saving(),
        };
    for (final MapEntry<String, LearningSettingsView> entry in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            view: entry.value,
            brightness: brightness,
            golden: true,
          );
          await expectLater(
            find.byType(LearningSettingsScreen),
            matchesGoldenFile(
              'goldens/learning_settings_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
