import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'app_providers.g.dart';

/// Resolved app configuration.
///
/// Defaults to the development flavor; `main.dart` overrides this with the
/// flavor chosen at boot so the rest of the graph reads a single source.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => const AppConfig.development();

/// Shared Talker instance for logging/diagnostics.
///
/// Derives from [appConfigProvider] by default. `main.dart` overrides this
/// with the instance created at bootstrap so uncaught errors raised before the
/// `ProviderScope` exists land in the same log history.
@Riverpod(keepAlive: true)
Talker talker(Ref ref) => createAppTalker(ref.watch(appConfigProvider));
