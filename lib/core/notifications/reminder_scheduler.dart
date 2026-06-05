/// Time-of-day for a daily study reminder (framework-agnostic).
class ReminderTime {
  const ReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24, 'hour out of range'),
      assert(minute >= 0 && minute < 60, 'minute out of range');

  final int hour;
  final int minute;
}

/// Port for scheduling the daily study reminder.
///
/// Defined in core so the learning-settings use cases
/// (`ScheduleReminderUseCase` / `CancelReminderUseCase`) depend on this
/// abstraction. The concrete implementation lives in
/// `LocalReminderScheduler` (flutter_local_notifications + timezone);
/// [NoopReminderScheduler] is the safe default for guest/unsupported builds.
///
/// [title] and [body] are passed in already localized — core stays l10n-free.
abstract interface class ReminderScheduler {
  /// Requests OS notification permission. Returns whether it is granted.
  Future<bool> requestPermission();

  /// Whether notification permission is currently granted.
  Future<bool> hasPermission();

  /// Schedules (or reschedules) the daily reminder at [time] with localized
  /// [title] / [body].
  Future<void> scheduleDaily(
    ReminderTime time, {
    required String title,
    required String body,
  });

  /// Cancels the scheduled reminder, if any.
  Future<void> cancel();
}

/// No-op scheduler: reports no permission and ignores scheduling.
///
/// Safe default before a notifications plugin is adopted.
final class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> scheduleDaily(
    ReminderTime time, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel() async {}
}
