import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/memox_app.dart';

abstract final class AppBootstrap {
  static void run() {
    runZonedGuarded(() {
      _setupErrorHandlers();
      _setupSystemChrome();
      runApp(const ProviderScope(child: MemoXApp()));
    }, (error, stack) {});
  }

  static void _setupErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) =>
        true;
  }

  static void _setupSystemChrome() => unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );
}
