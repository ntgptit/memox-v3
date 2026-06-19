import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: RoutePaths.root,
  routes: [
    GoRoute(
      path: RoutePaths.root,
      name: RouteNames.root,
      builder: (context, state) => const SizedBox.expand(),
    ),
  ],
);
