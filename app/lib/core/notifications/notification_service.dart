import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyPsalmId = 1;
  static const String _channelId   = 'salmo_diario';
  static const String _channelName = 'Salmo diário';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit     = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true, badge: true, sound: true,
          ) ??
          false;
    }
    return false;
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

    final numero = (_dayOfYear(scheduled) - 1) % 150 + 1;

    await _plugin.zonedSchedule(
      _dailyPsalmId,
      'Seu Salmo de hoje chegou.',
      'Salmo $numero — um momento para você.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
