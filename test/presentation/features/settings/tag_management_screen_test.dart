import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';

Widget _appShell(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> _pumpTagManagement(
  WidgetTester tester, {
  TagManagementState state = TagManagementState.loaded,
}) async {
  await tester.pumpWidget(_appShell(SettingsTagManagementScreen(state: state)));
  await tester.pump();
}

void main() {
  testWidgets('renders the loaded tag list', (tester) async {
    await _pumpTagManagement(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-loaded')),
      findsOneWidget,
    );
    expect(find.text(l10n.tagHashLabel('verb')), findsOneWidget);
    expect(find.text(l10n.settingsTagsCardCount(80)), findsOneWidget);
    expect(find.text(l10n.settingsTagsMostUsedBadge), findsOneWidget);
  });

  testWidgets('renders the loading state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.loading);

    expect(
      find.byKey(const ValueKey<String>('tag-management-loading')),
      findsOneWidget,
    );
    expect(find.byType(MxSkeleton), findsWidgets);
  });

  testWidgets('renders the empty state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.empty);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-empty')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsEmptyMessage), findsOneWidget);
    expect(find.text(l10n.settingsTagsEmptyAction), findsOneWidget);
  });

  testWidgets('renders the search-empty state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.searchEmpty);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-search-empty')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsSearchEmptyMessage), findsOneWidget);
  });

  testWidgets('renders the context sheet state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.sheet);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-sheet')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsContextSheetTitle), findsOneWidget);
    expect(find.text(l10n.settingsTagsActionRename), findsOneWidget);
    expect(find.text(l10n.settingsTagsActionMerge), findsOneWidget);
    expect(find.text(l10n.settingsTagsActionDelete), findsOneWidget);
  });

  testWidgets('renders the rename state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.rename);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-rename')),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsTagsRenameHelper(l10n.tagHashLabel('verb'))),
      findsOneWidget,
    );
  });

  testWidgets('renders the rename-to-merge state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.renameMerge);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-rename-merge')),
      findsOneWidget,
    );
    expect(
      find.text(
        l10n.settingsTagsRenameConflictMessage(l10n.tagHashLabel('noun')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders the merge sheet state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.merge);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-merge')),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsTagsMergeSheetTitle(l10n.tagHashLabel('verb'))),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsMergeSheetHint), findsOneWidget);
    expect(
      find.text(l10n.settingsTagsMergeSuggestedSectionTitle),
      findsOneWidget,
    );
    expect(
      find.text(l10n.settingsTagsMergeAllTagsSectionTitle),
      findsOneWidget,
    );
  });

  testWidgets('renders the delete dialog state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.del);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-delete')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsDeleteTitle), findsOneWidget);
    expect(find.text(l10n.settingsTagsDeleteConfirm), findsOneWidget);
  });

  testWidgets('renders the busy row state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.busy);

    expect(
      find.byKey(const ValueKey<String>('tag-management-loaded')),
      findsOneWidget,
    );
    expect(find.byType(MxLinearProgress), findsOneWidget);
  });

  testWidgets('renders the error toast state', (tester) async {
    await _pumpTagManagement(tester, state: TagManagementState.opError);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsTagManagementScreen)),
    );

    expect(
      find.byKey(const ValueKey<String>('tag-management-op-error')),
      findsOneWidget,
    );
    expect(find.text(l10n.settingsTagsOpErrorTitle), findsOneWidget);
    expect(find.text(l10n.settingsTagsOpErrorBody), findsOneWidget);
    expect(find.text(l10n.settingsTagsRetry), findsOneWidget);
  });

  testWidgets('opens the route from GoRouter', (tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/settings/learning/tags',
      routes: <RouteBase>[
        GoRoute(
          path: '/settings/learning/tags',
          name: RouteNames.settingsLearningTags,
          builder: (context, state) => const SettingsTagManagementScreen(),
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
    await tester.pumpAndSettle();

    expect(find.byType(SettingsTagManagementScreen), findsOneWidget);
  });
}
