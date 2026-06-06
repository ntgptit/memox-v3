import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import '../../core/logging/app_logger.dart';
import '../config/app_config.dart';
import '../feedback/app_messenger.dart';
import '../feedback/mx_app_feedback_observer.dart';

const int _maxTalkerHistoryItems = 500;
const String _unhandledErrorMessage = 'Unhandled MemoX app error';

Talker createAppTalker([MxAppConfig? config]) =>
    TalkerFlutter.init(settings: _talkerSettings(config));

void configureAppTalker(Talker talker, MxAppConfig config) {
  talker.configure(settings: _talkerSettings(config));
}

List<ProviderObserver> createAppProviderObservers({
  required Talker talker,
  required MxAppConfig config,
}) {
  // Always-on: logs every provider failure (even with diagnostics off) and
  // surfaces retained-data refetch failures as a snackbar app-wide.
  final List<ProviderObserver> observers = <ProviderObserver>[
    MxAppFeedbackObserver(
      logger: TalkerAppLogger(talker),
      messengerKey: appMessengerKey,
    ),
  ];

  if (config.enableRiverpodDiagnostics) {
    observers.add(
      TalkerRiverpodObserver(
        talker: talker,
        settings: const TalkerRiverpodLoggerSettings(
          printProviderAdded: true,
          printProviderUpdated: true,
          printProviderDisposed: false,
          printProviderFailed: true,
          printStateFullData: false,
          printFailFullData: true,
          printMutationStart: true,
          printMutationSuccess: true,
          printMutationFailed: true,
          printMutationReset: false,
        ),
      ),
    );
  }

  return observers;
}

void reportAppErrorToTalker(
  Talker talker,
  Object error,
  StackTrace stackTrace,
) {
  talker.handle(error, stackTrace, _unhandledErrorMessage);
}

final class TalkerAppLogger implements AppLogger {
  const TalkerAppLogger(this._talker);

  final Talker _talker;

  @override
  void error(String message, Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace, message);
  }
}

TalkerSettings _talkerSettings(MxAppConfig? config) => TalkerSettings(
  useHistory: true,
  useConsoleLogs: config?.enableTalkerConsoleLogs ?? true,
  maxHistoryItems: _maxTalkerHistoryItems,
);
