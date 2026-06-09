import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memox/core/notifications/reminder_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// [ReminderScheduler] backed by `flutter_local_notifications` + `timezone`.
///
/// Schedules a single repeating daily notification (matched on time-of-day in
/// the device's local zone). Localized [scheduleDaily] title/body and the
/// channel label are provided by the caller so core stays l10n-free.
///
/// Note: accurate wall-clock firing relies on `tz.local`. Pass the device IANA
/// zone to [init] (resolved app-side, e.g. via `flutter_timezone`); without it
/// the scheduler falls back to the default `tz.local`.
final class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({
    required String channelId,
    required String channelName,
    FlutterLocalNotificationsPlugin? plugin,
    this.notificationId = _defaultNotificationId,
  }) : _channelId = channelId,
       _channelName = channelName,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _defaultNotificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin;
  final String _channelId;
  final String _channelName;
  final int notificationId;

  /// Initializes timezone data and the plugin. Call once before scheduling.
  Future<void> init({String? timeZoneName}) async {
    tz_data.initializeTimeZones();
    if (timeZoneName != null) {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<bool> hasPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final options = await ios.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<void> scheduleDaily(
    ReminderTime time, {
    required String title,
    required String body,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      _nextInstanceOf(time),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() => _plugin.cancel(notificationId);

  tz.TZDateTime _nextInstanceOf(ReminderTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
