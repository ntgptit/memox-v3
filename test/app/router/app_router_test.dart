import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  group('createAppRouter', () {
    testWidgets('boot lands on the Library via the root redirect', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);

      await _pumpRouter(tester, router);

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.library,
      );
      expect(find.byType(RoutePlaceholder), findsOneWidget);
      expect(find.text(RouteNames.library), findsOneWidget);
    });

    testWidgets('navigating to the bare root redirects to the Library', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);

      await _pumpRouter(tester, router);
      router.go(RoutePaths.root);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        RoutePaths.library,
      );
    });

    testWidgets('each top-level destination renders its placeholder', (
      tester,
    ) async {
      final GoRouter router = createAppRouter();
      addTearDown(router.dispose);
      await _pumpRouter(tester, router);

      for (final MapEntry<String, String> destination in <String, String>{
        RoutePaths.home: RouteNames.home,
        RoutePaths.library: RouteNames.library,
        RoutePaths.progress: RouteNames.progress,
        RoutePaths.settings: RouteNames.settings,
      }.entries) {
        router.go(destination.key);
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          destination.key,
        );
        expect(find.byType(RoutePlaceholder), findsOneWidget);
        expect(find.text(destination.value), findsOneWidget);
      }
    });
  });
}
