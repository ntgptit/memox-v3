import 'dart:io';

/// Appends log lines to a rotated daily file and prunes old days.
///
/// File: `{logDir}/memox-{yyyy-MM-dd}.log`, retaining [retentionDays] days
/// (`docs/quality/observability-contract.md`). The log directory and a clock
/// are injected so core stays pure and testable — the app layer resolves the
/// app-support dir (via `path_provider`) and passes it in. Never write PII;
/// callers must follow the PII rule before handing a line here.
class PersistentLogWriter {
  PersistentLogWriter({
    required Directory logDir,
    required DateTime Function() clock,
    this.retentionDays = 7,
  }) : _logDir = logDir,
       _clock = clock;

  static const String _filePrefix = 'memox-';
  static const String _fileSuffix = '.log';

  final Directory _logDir;
  final DateTime Function() _clock;
  final int retentionDays;

  IOSink? _sink;
  String? _openDate;

  /// Appends a single [line] to today's log file, rotating at midnight.
  Future<void> write(String line) async {
    final date = _dateStamp(_clock());
    if (date != _openDate) {
      await _rotateTo(date);
    }
    _sink?.writeln(line);
  }

  /// Flushes and closes the current file handle.
  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _openDate = null;
  }

  Future<void> _rotateTo(String date) async {
    await _sink?.flush();
    await _sink?.close();

    if (!_logDir.existsSync()) {
      _logDir.createSync(recursive: true);
    }
    final file = File('${_logDir.path}/$_filePrefix$date$_fileSuffix');
    _sink = file.openWrite(mode: FileMode.writeOnlyAppend);
    _openDate = date;

    await _pruneOldFiles();
  }

  Future<void> _pruneOldFiles() async {
    if (!_logDir.existsSync()) {
      return;
    }
    final cutoff = _clock().subtract(Duration(days: retentionDays));
    for (final entity in _logDir.listSync()) {
      if (entity is! File) {
        continue;
      }
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith(_filePrefix) || !name.endsWith(_fileSuffix)) {
        continue;
      }
      final stamp = name.substring(
        _filePrefix.length,
        name.length - _fileSuffix.length,
      );
      final fileDate = DateTime.tryParse(stamp);
      if (fileDate != null && fileDate.isBefore(cutoff)) {
        entity.deleteSync();
      }
    }
  }

  static String _dateStamp(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
