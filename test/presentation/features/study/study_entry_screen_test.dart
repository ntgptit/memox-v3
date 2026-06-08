import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/routes/study_routes.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

Widget _appShell(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

Widget _routerShell(GoRouter router) => ProviderScope(
  child: MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

GoRouter _studyRouter(String initialLocation) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: studyRoutes(rootNavigatorKey),
  );
}

String _studyLocation({
  required String entryType,
  required String entryRefId,
  String? studyType,
  String? mode,
}) {
  final Map<String, String> queryParameters = <String, String>{};
  if (studyType != null) {
    queryParameters[RoutePaths.studyTypeQueryParam] = studyType;
  }
  if (mode != null) {
    queryParameters[RoutePaths.modeQueryParam] = mode;
  }
  return Uri(
    path: RoutePaths.studyEntry(entryType, entryRefId),
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

void main() {
  testWidgets(
    'DT1 onOpen: today route renders StudyEntryScreen instead of RoutePlaceholder',
    (tester) async {
      final GoRouter router = _studyRouter(RoutePaths.studyToday);

      await tester.pumpWidget(_routerShell(router));
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.byType(StudyEntryScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.text(l10n.studyEntryPreparingTitle), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(l10n.studyEntryUnsupportedTitle), findsOneWidget);
      expect(find.text(l10n.commonBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT2 onOpen: scoped deck route renders StudyEntryScreen instead of RoutePlaceholder',
    (tester) async {
      final GoRouter router = _studyRouter(
        _studyLocation(entryType: 'deck', entryRefId: 'deck-1'),
      );

      await tester.pumpWidget(_routerShell(router));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.byType(StudyEntryScreen), findsOneWidget);
      expect(find.byType(RoutePlaceholder), findsNothing);
      expect(find.text(l10n.studyEntryUnsupportedTitle), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onOpen: invalid entryType renders error state',
    (tester) async {
      final GoRouter router = _studyRouter(
        _studyLocation(entryType: 'bogus', entryRefId: 'deck-1'),
      );

      await tester.pumpWidget(_routerShell(router));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.text(l10n.studyEntryInvalidTitle), findsOneWidget);
      expect(find.text(l10n.studyEntryInvalidMessage), findsOneWidget);
      expect(find.text(l10n.commonBack), findsOneWidget);
    },
  );

  testWidgets(
    'DT4 onOpen: blank entryRefId renders error state',
    (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StudyEntryScreen.scoped(entryType: 'deck', entryRefId: ''),
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.text(l10n.studyEntryInvalidTitle), findsOneWidget);
      expect(find.text(l10n.studyEntryInvalidMessage), findsOneWidget);
    },
  );

  testWidgets(
    'DT5 onOpen: invalid study_type query renders error state',
    (tester) async {
      final GoRouter router = _studyRouter(
        _studyLocation(
          entryType: 'deck',
          entryRefId: 'deck-1',
          studyType: 'bogus',
        ),
      );

      await tester.pumpWidget(_routerShell(router));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.text(l10n.studyEntryInvalidTitle), findsOneWidget);
      expect(find.text(l10n.studyEntryInvalidMessage), findsOneWidget);
    },
  );

  testWidgets(
    'DT6 onDisplay: the first frame shows the preparing state before unsupported gap',
    (tester) async {
      final GoRouter router = _studyRouter(RoutePaths.studyToday);

      await tester.pumpWidget(_routerShell(router));
      await tester.pump();

      final AppLocalizations l10n = AppLocalizations.of(
        tester.element(find.byType(StudyEntryScreen)),
      );

      expect(find.text(l10n.studyEntryPreparingTitle), findsOneWidget);
      expect(find.byType(MxLoadingState), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(l10n.studyEntryUnsupportedTitle), findsOneWidget);
    },
  );
}
