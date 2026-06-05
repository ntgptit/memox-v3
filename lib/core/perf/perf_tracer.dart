import 'dart:developer' as developer;

/// Lightweight tracing for perf-sensitive operations.
///
/// Wraps `dart:developer` Timeline so use cases / screens flagged in
/// `docs/quality/performance-contract.md` emit start/end trace events visible
/// in DevTools, with zero overhead in release builds (Timeline is a no-op
/// there). Argument values must follow the PII rule — counts/ids only.
abstract final class PerfTracer {
  PerfTracer._();

  /// Times a synchronous [action] under a Timeline slice named [name].
  static T sync<T>(
    String name,
    T Function() action, {
    Map<String, Object?>? args,
  }) {
    developer.Timeline.startSync(name, arguments: args);
    try {
      return action();
    } finally {
      developer.Timeline.finishSync();
    }
  }

  /// Times an asynchronous [action] under an async Timeline task named [name].
  static Future<T> async<T>(
    String name,
    Future<T> Function() action, {
    Map<String, Object?>? args,
  }) async {
    final task = developer.TimelineTask()..start(name, arguments: args);
    try {
      return await action();
    } finally {
      task.finish();
    }
  }

  /// Emits a single instant marker (e.g., "first frame", "cache hit").
  static void instant(String name, {Map<String, Object?>? args}) =>
      developer.Timeline.instantSync(name, arguments: args);
}
