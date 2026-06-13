import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/history/screens/card_history_screen.dart';

/// Flashcard editor and import routes, composed by `app_router.dart`.
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
        builder: (_, GoRouterState state) => FlashcardEditorScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam] ?? '',
          flashcardId: state.pathParameters[RoutePaths.flashcardIdParam] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.flashcardHistoryTemplate,
        name: RouteNames.flashcardHistory,
        builder: (_, GoRouterState state) => CardHistoryScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam] ?? '',
          flashcardId: state.pathParameters[RoutePaths.flashcardIdParam] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.deckImportTemplate,
        name: RouteNames.deckImport,
        builder: (_, GoRouterState state) => DeckImportScreen(
          deckId: state.pathParameters[RoutePaths.deckIdParam] ?? '',
        ),
      ),
    ];
