import 'dart:async';

import 'package:logging/logging.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/core/logging/persistent_log_writer.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Root logging setup.
///
/// `package:logging` is the emit API (`Logger('study.session')`); this wires
/// `Logger.root` once with a level threshold from [AppConfig] and fans each
/// record out to Talker (the in-app viewer) and an optional
/// [PersistentLogWriter] (rotated file). Format and PII rules follow
/// `docs/quality/observability-contract.md`. Call once from `main.dart`.
abstract final class LogConfig {
  LogConfig._();

  static void configure({
    required AppConfig config,
    required Talker talker,
    PersistentLogWriter? fileWriter,
  }) {
    Logger.root.level = config.isProduction ? Level.INFO : Level.FINE;
    Logger.root.onRecord.listen((record) {
      _forwardToTalker(talker, record);
      final writer = fileWriter;
      if (writer != null) {
        unawaited(writer.write(_formatLine(record)));
      }
    });
  }

  static void _forwardToTalker(Talker talker, LogRecord record) {
    final message = '[${record.loggerName}] ${record.message}';
    final error = record.error;
    if (error != null) {
      talker.handle(error, record.stackTrace, message);
      return;
    }
    talker.log(message, logLevel: _talkerLevel(record.level));
  }

  static LogLevel _talkerLevel(Level level) {
    if (level >= Level.SEVERE) {
      return LogLevel.error;
    }
    if (level >= Level.WARNING) {
      return LogLevel.warning;
    }
    if (level >= Level.INFO) {
      return LogLevel.info;
    }
    if (level >= Level.FINE) {
      return LogLevel.debug;
    }
    return LogLevel.verbose;
  }

  /// `[YYYY-MM-DD HH:MM:SS.mmm][LEVEL][logger.name] message`.
  static String _formatLine(LogRecord record) {
    final t = record.time;
    final stamp =
        '${_pad(t.year, 4)}-${_pad(t.month, 2)}-${_pad(t.day, 2)} '
        '${_pad(t.hour, 2)}:${_pad(t.minute, 2)}:${_pad(t.second, 2)}'
        '.${_pad(t.millisecond, 3)}';
    return '[$stamp][${record.level.name}][${record.loggerName}] '
        '${record.message}';
  }

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');
}
