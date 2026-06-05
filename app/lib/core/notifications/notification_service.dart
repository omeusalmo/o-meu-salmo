import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyPsalmId = 1;
  static const String _channelId = 'salmo_diario';
  static const String _channelName = 'Salmo diário';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    return granted;
  }

  // Agenda notificação diária repetindo todo dia no horário especificado.
  // O número do Salmo é calculado pelo dia do ano para variar sem servidor.
  Future<void> scheduleDailySalmo(int hour, int minute) async {
    await cancelDailySalmo();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dayOfYear = _dayOfYear(scheduled);
    final numero = (dayOfYear - 1) % 150 + 1;

    await _plugin.zonedSchedule(
      _dailyPsalmId,
      'Seu Salmo de hoje chegou.',
      'Salmo $numero — um momento para você.',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailySalmo() async {
    await _plugin.cancel(_dailyPsalmId);
  }

  int _dayOfYear(DateTime d) {
    return d.difference(DateTime(d.year, 1, 1)).inDays + 1;
  }
}
