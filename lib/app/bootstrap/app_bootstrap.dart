import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:memox/app/memox_app.dart';
import 'package:memox/core/logging/log_config.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

abstract final class AppBootstrap {
  /// One logger for the app-shell boundary — uncaught Flutter / platform / zone
  /// errors land here as `SEVERE` (`docs/quality/observability-contract.md`).
  static final Logger _log = Logger('app.shell');

  static void run() {
    runZonedGuarded(
      () {
        // Must run before any platform-channel call (SystemChrome below) AND in
        // the same zone as runApp — otherwise the binding's `instance` getter
        // throws "Binding has not yet been initialized".
        WidgetsFlutterBinding.ensureInitialized();
        MxLog.init();
        _setupErrorHandlers();
        _setupSystemChrome();
        _log.info('app_boot release=$kReleaseMode');
        runApp(
          ProviderScope(
            observers: <ProviderObserver>[
              TalkerRiverpodObserver(talker: MxLog.talker),
            ],
            child: const MemoXApp(),
          ),
        );
      },
      // Last-resort boundary: any uncaught async error in the guarded zone is
      // logged, never swallowed (the contract forbids an empty handler).
      (Object error, StackTrace stack) =>
          _log.severe('uncaught_zone_error', error, stack),
    );
  }

  static void _setupErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Keep the framework's red-screen / console presentation, then record it
      // so it also reaches the log history.
      FlutterError.presentError(details);
      _log.severe(
        'flutter_error ${details.context?.toDescription() ?? 'unknown'}',
        details.exception,
        details.stack,
      );
    };

    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _log.severe('platform_error', error, stack);
      return true;
    };
  }

  static void _setupSystemChrome() {
    // Draw under the system bars so the app background fills behind the
    // (transparent) status bar — no color seam at the top edge. Icon
    // brightness is set per-theme via `AppBarTheme.systemOverlayStyle`.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
  }
}
