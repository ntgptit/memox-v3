import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';

Widget _appShell(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> _pumpLearning(
  WidgetTester tester, {
  LearningSettingsState state = LearningSettingsState.goalOn,
}) async {
  await tester.pumpWidget(_appShell(LearningSettingsScreen(state: state)));
  await tester.pump();
}

void main() {
  testWidgets('renders the learning settings sections', (tester) async {
    await _pumpLearning(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LearningSettingsScreen)),
    );

    expect(
      find.text(
        StringUtils.uppercased(l10n.settingsLearningDailyGoalSectionTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        StringUtils.uppercased(l10n.settingsLearningReminderSectionTitle),
      ),
      findsOneWidget,
    );
    expect(
      find.text(StringUtils.uppercased(l10n.settingsLearningTagsSectionTitle)),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text(
        StringUtils.uppercased(l10n.settingsLearningFutureStudyDefaultsTitle),
      ),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text(
        StringUtils.uppercased(l10n.settingsLearningFutureStudyDefaultsTitle),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders the goal-off hint and disabled goal row', (
    tester,
  ) async {
    await _pumpLearning(tester, state: LearningSettingsState.goalOff);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LearningSettingsScreen)),
    );

    expect(find.text(l10n.settingsLearningGoalOffHint), findsOneWidget);
    expect(
      find.text(l10n.settingsLearningGoalToggleSubtitleOff),
      findsOneWidget,
    );
  });

  testWidgets('renders the reminder-permission banner', (tester) async {
    await _pumpLearning(tester, state: LearningSettingsState.permDenied);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LearningSettingsScreen)),
    );

    expect(
      find.text(l10n.settingsLearningNotificationsBlockedTitle),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsLearningNotificationsBlockedBody),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsLearningOpenSystemSettings), findsOneWidget);
  });

  testWidgets('renders the saved chip in the app bar', (tester) async {
    await _pumpLearning(tester, state: LearningSettingsState.saving);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LearningSettingsScreen)),
    );

    expect(find.text(l10n.settingsLearningSavedChip), findsOneWidget);
  });

  testWidgets('navigates to tag management when tapped', (tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/settings/learning',
      routes: <RouteBase>[
        GoRoute(
          path: '/settings/learning',
          name: RouteNames.settingsLearning,
          builder: (context, state) => const LearningSettingsScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'tags',
              name: RouteNames.settingsLearningTags,
              builder: (context, state) => const SettingsTagManagementScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LearningSettingsScreen)),
    );

    await tester.tap(find.text(l10n.settingsManageTagsTitle));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsTagManagementScreen), findsOneWidget);
  });
}
