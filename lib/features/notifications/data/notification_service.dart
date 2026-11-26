import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1;
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily reminder';
  static const int _baseId = 100; // reminder ids: 100..129
  static const int _daysAhead = 30;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );
  }

  /// Asks for the Android 13+ notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    bool skipToday = false,
  }) async {
    await cancelDailyReminder(); // also clears the old repeating alarm (id 1)

    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _daysAhead; i++) {
      final when = tz.TZDateTime(
          tz.local, now.year, now.month, now.day + i, hour, minute);
      if (when.isBefore(now)) continue; // time already passed today
      if (i == 0 && skipToday) continue; // user already logged today

      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: 'Expense Tracker',
        body: 'Did you spend anything today? Add it before you forget.',
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily reminder to log your expenses',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: _dailyReminderId); // old repeating alarm
    for (var i = 0; i < _daysAhead; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
  }
}
