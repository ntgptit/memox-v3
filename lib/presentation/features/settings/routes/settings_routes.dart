import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/app/router/route_placeholder.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';

/// Settings route registry, composed by `app_router.dart`.
List<RouteBase> settingsRoutes(GlobalKey<NavigatorState> rootNavigatorKey) =>
    <RouteBase>[
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.settingsAccount,
        name: RouteNames.settingsAccount,
        builder: (_, _) =>
            const RoutePlaceholder(routeName: RouteNames.settingsAccount),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.settingsLearning,
        name: RouteNames.settingsLearning,
        builder: (_, _) => const LearningSettingsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: RoutePaths.settingsLearningTagsSegment,
            name: RouteNames.settingsLearningTags,
            builder: (_, _) => const SettingsTagManagementScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.settingsAudioSpeech,
        name: RouteNames.settingsAudioSpeech,
        builder: (_, _) => const AudioSpeechSettingsScreen(),
      ),
    ];

GoRoute settingsHubRoute() => GoRoute(
  path: RoutePaths.settings,
  name: RouteNames.settings,
  builder: (_, _) => const SettingsScreen(),
);
