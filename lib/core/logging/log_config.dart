import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Central logging configuration for MemoX
/// (`docs/quality/observability-contract.md`).
///
/// MemoX is local-first with no remote telemetry — every record stays
/// on-device. `package:logging` is the API every feature uses
/// (`final _log = Logger('feature.name')`); this wires the single root logger to
/// one shared [Talker] sink so developers get a readable, colourised console
/// line in debug **and** an in-memory history a log-viewer screen can render.
///
/// Talker owns the timestamp + level prefix on the console; the contract's
/// `[logger.name] message {key=value}` payload is preserved verbatim. The level
/// threshold follows the build mode: `FINE` in debug, `INFO` in release.
abstract final class MxLog {
  MxLog._();

  static Talker? _talker;

  /// The shared Talker sink — also handed to `TalkerRiverpodObserver` and any
  /// developer log-viewer. Null until [init] runs (plain unit tests that never
  /// boot the app simply never read it).
  static Talker? get talker => _talker;

  /// Wires the root logger → Talker. Idempotent: a second call is a no-op, so
  /// `main`, tests, and hot restart can all call it safely.
  static void init() {
    if (_talker != null) return;

    final Talker talker = TalkerFlutter.init(
      // Keep the in-memory history in every build (it powers the in-app
      // viewer); only mirror to the console in non-release builds.
      settings: TalkerSettings(useConsoleLogs: !kReleaseMode),
    );
    _talker = talker;

    Logger.root.level = kReleaseMode ? Level.INFO : Level.FINE;
    Logger.root.onRecord.listen((LogRecord record) {
      talker.log(
        _format(record),
        logLevel: _toTalkerLevel(record.level),
        exception: record.error,
        stackTrace: record.stackTrace,
      );
    });
  }

  /// `[logger.name] message` — Talker prepends the timestamp + level, so this
  /// carries the contract's logger-name + message payload.
  static String _format(LogRecord record) =>
      '[${record.loggerName}] ${record.message}';

  /// Maps the `package:logging` level onto Talker's [LogLevel] buckets.
  static LogLevel _toTalkerLevel(Level level) {
    if (level >= Level.SEVERE) return LogLevel.error;
    if (level >= Level.WARNING) return LogLevel.warning;
    if (level >= Level.INFO) return LogLevel.info;
    if (level >= Level.FINE) return LogLevel.debug;
    return LogLevel.verbose;
  }
}
