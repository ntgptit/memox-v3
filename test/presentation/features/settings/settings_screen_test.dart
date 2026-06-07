import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';

Widget _appShell(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> _pumpSettings(
  WidgetTester tester, {
  SettingsHubState state = SettingsHubState.populated,
}) async {
  await tester.pumpWidget(_appShell(SettingsScreen(state: state)));
  await tester.pump();
}

void main() {
  testWidgets('renders the populated settings hub', (tester) async {
    await _pumpSettings(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(find.text(l10n.settingsAccountLinkedOverviewTitle), findsOneWidget);
    expect(find.text(l10n.settingsLearningOverviewTitle), findsOneWidget);
    expect(find.text(l10n.settingsAudioSpeechTitle), findsOneWidget);
    expect(find.text(l10n.settingsManageTagsTitle), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceTitle), findsOneWidget);
    expect(find.text(l10n.settingsLanguageTitle), findsOneWidget);
    expect(find.text(l10n.settingsAboutMemoXTitle), findsOneWidget);
    expect(find.text(l10n.settingsSoonChip), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.text(l10n.settingsOverviewFooter),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(l10n.settingsOverviewFooter), findsOneWidget);
  });

  testWidgets('renders loading subtitles as skeletons', (tester) async {
    await _pumpSettings(tester, state: SettingsHubState.loading);

    expect(find.byType(MxSkeleton), findsNWidgets(5));
    expect(find.text('Light, dark, system'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('renders the signed-out account row', (tester) async {
    await _pumpSettings(tester, state: SettingsHubState.signedOut);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(find.text(l10n.settingsAccountSignInSyncTitle), findsOneWidget);
    expect(find.text(l10n.settingsAccountSignInSyncSubtitle), findsOneWidget);
    expect(find.text(l10n.settingsAccountLinkedOverviewTitle), findsNothing);
  });

  testWidgets('renders the signing-in account row', (tester) async {
    await _pumpSettings(tester, state: SettingsHubState.signingIn);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(find.text(l10n.settingsAccountSigningIn), findsOneWidget);
    expect(find.byType(MxSkeleton), findsWidgets);
  });

  testWidgets('renders the sync-error account row', (tester) async {
    await _pumpSettings(tester, state: SettingsHubState.syncError);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    );

    expect(
      find.text(
        l10n.settingsAccountOverviewSyncErrorSubtitle('alex@memox.app'),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsOverviewSyncRetry), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('navigates to the learning settings route when tapped', (
    tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/settings',
      routes: <RouteBase>[
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/learning',
          name: RouteNames.settingsLearning,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Learning route'))),
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
      tester.element(find.byType(SettingsScreen)),
    );

    await tester.tap(find.text(l10n.settingsLearningOverviewTitle));
    await tester.pumpAndSettle();

    expect(find.text('Learning route'), findsOneWidget);
  });
}
