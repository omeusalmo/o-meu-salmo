import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  /// Público só para o teste conseguir criar um dublê por herança.
  NotificationService();
  /// Trocável em teste (a permissão de notificação depende de plataforma
  /// nativa, que não existe sob flutter test). Em produção nunca é
  /// reatribuído.
  static NotificationService instance = NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyPsalmId = 1;
  // ⚠️ _channelId é chave técnica do canal no Android, NÃO renomear: trocar
  // cria um canal duplicado e quem já configurou perde o ajuste.
  static const String _channelId   = 'salmo_diario';
  // Nome visível nas Configurações do Android. Renomear exige
  // channelAction.update no AndroidNotificationDetails (ver scheduleDailySalmo),
  // senão quem já ativou continua vendo o nome antigo para sempre.
  static const String _channelName = 'Salmo do dia';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(_zonaDoAparelho());

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

  // Agenda o Salmo do dia repetindo todo dia no horário especificado.
  // O número do Salmo é calculado pelo dia do ano para variar sem servidor.
  // [totalSalmos] vem da lista real (salmosProvider) — nunca hardcoded aqui,
  // senão uma mudança no catálogo pode sugerir um Salmo que não existe.
  Future<void> scheduleDailySalmo(
    int hour,
    int minute, {
    required int totalSalmos,
  }) async {
    await cancelDailySalmo();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final numero = (_dayOfYear(scheduled) - 1) % totalSalmos + 1;

    await _plugin.zonedSchedule(
      _dailyPsalmId,
      'Seu Salmo de hoje chegou.',
      'Salmo $numero — um momento para você.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          // update, e não o padrão createIfNotExists: o canal já existe no
          // aparelho de quem ativou a notificação antes da renomeação, e sem
          // isto continuaria mostrando o nome antigo nas Configurações.
          channelAction: AndroidNotificationChannelAction.update,
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

  /// Descobre o fuso do aparelho sem depender de pacote nativo.
  ///
  /// `tz.initializeTimeZones()` deixa `tz.local` em UTC (src/env.dart faz
  /// `_local = _UTC`). Sem resolver isso, quem escolhe 08:00 recebe a
  /// notificação às 05:00 de Brasília.
  ///
  /// A busca casa o deslocamento de agora E o de daqui a seis meses. Os dois
  /// juntos separam fuso com horário de verão de fuso sem: só o deslocamento
  /// atual acharia dezenas de zonas equivalentes e poderia escolher uma que
  /// muda de hora em época diferente.
  ///
  /// Reserva é São Paulo, e não UTC: o app só é distribuído no Brasil, então
  /// errar para o fuso do público é melhor que errar três horas para todos.
  static tz.Location _zonaDoAparelho() {
    final agora = DateTime.now();
    final emSeisMeses = agora.add(const Duration(days: 182));
    final deslocamentoAgora = agora.timeZoneOffset;
    final deslocamentoDepois = emSeisMeses.timeZoneOffset;

    for (final local in tz.timeZoneDatabase.locations.values) {
      final a = Duration(
          milliseconds: local.timeZone(agora.millisecondsSinceEpoch).offset);
      final b = Duration(
          milliseconds:
              local.timeZone(emSeisMeses.millisecondsSinceEpoch).offset);
      if (a == deslocamentoAgora && b == deslocamentoDepois) return local;
    }
    return tz.getLocation('America/Sao_Paulo');
  }

  int _dayOfYear(DateTime d) {
    return d.difference(DateTime(d.year, 1, 1)).inDays + 1;
  }
}
