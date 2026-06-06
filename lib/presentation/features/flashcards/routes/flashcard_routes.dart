import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';

/// Flashcard editor routes, composed by `app_router.dart`.
List<RouteBase> flashcardRoutes(GlobalKey<NavigatorState> rootNavigatorKey) =>
    <RouteBase>[
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.flashcardCreateTemplate,
        name: RouteNames.flashcardCreate,
        builder: (_, GoRouterState state) => FlashcardEditorScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.flashcardEditTemplate,
        name: RouteNames.flashcardEdit,
        builder: (_, GoRouterState state) => RoutePlaceholder(
          routeName: RouteNames.flashcardEdit,
          params: <String, String>{
            RoutePaths.deckIdParam:
                state.pathParameters[RoutePaths.deckIdParam] ?? '',
            RoutePaths.flashcardIdParam:
                state.pathParameters[RoutePaths.flashcardIdParam] ?? '',
          },
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.deckImportTemplate,
        name: RouteNames.deckImport,
        builder: (_, GoRouterState state) => RoutePlaceholder(
          routeName: RouteNames.deckImport,
          params: <String, String>{
            RoutePaths.deckIdParam:
                state.pathParameters[RoutePaths.deckIdParam] ?? '',
          },
        ),
      ),
    ];
