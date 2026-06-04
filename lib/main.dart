import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memox/app/app.dart';
import 'package:memox/app/bootstrap/app_bootstrap.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/logging/app_talker.dart';

Future<void> main() async {
  const config = AppConfig.development();
  final talker = createAppTalker(config);

  await AppBootstrap.bootstrap(
    reportError: (error, stackTrace) =>
        reportAppErrorToTalker(talker, error, stackTrace),
    builder: () => ProviderScope(
      observers: createAppProviderObservers(talker: talker, config: config),
      overrides: [
        appConfigProvider.overrideWithValue(config),
        talkerProvider.overrideWithValue(talker),
      ],
      child: const MemoxApp(),
    ),
  );
}
