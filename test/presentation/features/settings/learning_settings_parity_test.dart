import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_controller.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';

import '../../../support/parity_contract.dart';

class _FakeController extends LearningSettingsController {
  _FakeController(this._view);
  final LearningSettingsView _view;
  @override
  Future<LearningSettingsView> build() async => _view;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

Future<void> _pump(WidgetTester tester, LearningSettingsView view) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        learningSettingsControllerProvider.overrideWith(
          () => _FakeController(view),
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
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  // All five required nodes are visible in the goal-on state (goal card with its
  // toggle/slider/presets, plus the reminder card).
  testWidgets('22-learning-settings: required nodes', (tester) async {
    await _pump(
      tester,
      const LearningSettingsView(settings: LearningSettings(dailyNewLimit: 20)),
    );
    expectParityContract('22-learning-settings', <String, Finder>{
      'goal card': _node('22-learning-settings/goal-card'),
      'goal toggle': _node('22-learning-settings/goal-toggle'),
      'goal slider': _node('22-learning-settings/goal-slider'),
      'goal presets': _node('22-learning-settings/goal-presets'),
      'reminder card': _node('22-learning-settings/reminder-card'),
    });
  });

  // Bridge 3 pilot: the keyed nodes the kit tags as a concrete component must
  // realize that component (goal-card / reminder-card → MxCard). Driven entirely
  // by the generated tool/parity/contracts/bindings.json — a raw Container in
  // place of MxCard would fail here even though the presence contract passes.
  testWidgets('22-learning-settings: binding contract (kit component)', (
    tester,
  ) async {
    await _pump(
      tester,
      const LearningSettingsView(settings: LearningSettings(dailyNewLimit: 20)),
    );
    expectGeneratedBindingContract(
      '22-learning-settings',
      aliases: const <String, String>{'MxBottomNavigationBar': 'MxBottomNav'},
    );
  });
}
