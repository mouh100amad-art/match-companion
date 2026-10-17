import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/match.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final dynamic info = await FlutterTimezone.getLocalTimezone();
      final String name = info is String ? info : info.identifier as String;
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // يبقى UTC كاحتياط
    }

    const android = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: android);
    
    await _plugin.initialize(settings: settings);
    _ready = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission() ?? false;
    try {
      await android.requestExactAlarmsPermission();
    } catch (_) {}
    return granted;
  }

  int idFor(MatchEvent match) => match.id.hashCode & 0x7fffffff;

  Future<void> scheduleMatchReminder({
    required MatchEvent match,
    required int minutesBefore,
  }) async {
    await init();
    final when = match.localTime.subtract(Duration(minutes: minutesBefore));
    if (!when.isAfter(DateTime.now())) return;

    final tzWhen = tz.TZDateTime.from(when, tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'match_reminders',
        'تذكير المباريات',
        channelDescription: 'إشعارات قبل انطلاق المباريات',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
      ),
    );

    await _plugin.zonedSchedule(
      id: idFor(match),
      title: '⏰ مباراة قريبة',
      body: '${match.homeTeam} × ${match.awayTeam} تنطلق بعد $minutesBefore دقيقة',
      scheduledDate: tzWhen,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(MatchEvent match) async {
    await _plugin.cancel(id: idFor(match));
  }
}
