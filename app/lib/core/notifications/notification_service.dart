import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Um dia da janela de notificações, com tudo já resolvido.
class ItemAgenda {
  const ItemAgenda({
    required this.diaOffset,
    required this.numero,
    required this.titulo,
    required this.versiculo,
  });

  /// 0 = hoje, 1 = amanhã, e assim por diante.
  final int diaOffset;
  final int numero;
  final String titulo;

  /// Primeiro versículo do salmo, o mesmo que a Home mostra em destaque.
  final String versiculo;
}

class NotificationService {
  /// Público só para o teste conseguir criar um dublê por herança.
  NotificationService();
  /// Trocável em teste (a permissão de notificação depende de plataforma
  /// nativa, que não existe sob flutter test). Em produção nunca é
  /// reatribuído.
  static NotificationService instance = NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Ligado pelo main.dart. O serviço não conhece o go_router: só avisa a
  /// rota que o payload pediu.
  void Function(String rota)? onSelecionarRota;

  /// Rota guardada quando o app foi aberto pela notificação estando morto.
  /// A splash consome no fim da inicialização (ver consumirRotaPendente).
  String? _rotaPendente;

  /// Devolve a rota pendente uma única vez.
  String? consumirRotaPendente() {
    final r = _rotaPendente;
    _rotaPendente = null;
    return r;
  }

  /// Id da notificação única e repetente da 1.0.2. Não some no update: se
  /// não for cancelado explicitamente, quem atualizou continua recebendo o
  /// mesmo salmo todo dia para sempre.
  static const int _idLegado = 1;

  /// Faixa de ids da janela deslizante: 1000, 1001, ... um por dia agendado.
  static const int _idBase = 1000;

  /// Quantos dias agendar de uma vez.
  ///
  /// A janela é reagendada a cada abertura do app. Só reagendar na abertura
  /// falharia justamente para quem parou de abrir, que é quem a notificação
  /// existe para trazer de volta; e só agendar de uma vez acabaria em algum
  /// momento. Quatorze cobre duas semanas de ausência, fica muito abaixo do
  /// teto de alarmes do Android, e se a pessoa sumiu por mais que isso,
  /// parar de insistir é o comportamento certo.
  static const int horizonteDias = 14;
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
      onDidReceiveNotificationResponse: (resposta) {
        final rota = resposta.payload;
        if (rota == null || rota.isEmpty) return;
        final abrir = onSelecionarRota;
        // App vivo: navega na hora. App ainda subindo: guarda para a splash.
        if (abrir != null) {
          abrir(rota);
        } else {
          _rotaPendente = rota;
        }
      },
    );

    // App aberto a partir da notificação com o processo morto: o toque não
    // passa pelo callback acima, vem daqui.
    final abertura = await _plugin.getNotificationAppLaunchDetails();
    if (abertura?.didNotificationLaunchApp ?? false) {
      final rota = abertura?.notificationResponse?.payload;
      if (rota != null && rota.isNotEmpty) _rotaPendente = rota;
    }

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

  /// Agenda a janela de notificações do Salmo do dia.
  ///
  /// Não decide nada: recebe a agenda pronta (ver `agendador.dart`), para a
  /// escolha do salmo viver num lugar só, compartilhado com a Home. Cada item
  /// é agendado uma vez, sem `matchDateTimeComponents`, então cada dia mostra
  /// o seu próprio salmo em vez de repetir o mesmo para sempre.
  Future<void> agendarJanela({
    required int hour,
    required int minute,
    required List<ItemAgenda> agenda,
  }) async {
    await cancelarJanela();

    final agora = tz.TZDateTime.now(tz.local);

    for (var i = 0; i < agenda.length && i < horizonteDias; i++) {
      final item = agenda[i];
      var quando = tz.TZDateTime(
        tz.local, agora.year, agora.month, agora.day, hour, minute,
      ).add(Duration(days: item.diaOffset));

      if (!quando.isAfter(agora)) continue;

      await _plugin.zonedSchedule(
        _idBase + i,
        'Salmo ${item.numero} · ${item.titulo}',
        item.versiculo,
        quando,
        NotificationDetails(
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
            styleInformation: BigTextStyleInformation(
              item.versiculo,
              summaryText: 'Seu Salmo de hoje',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '/salmos/${item.numero}',
      );
    }
  }

  Future<void> cancelarJanela() async {
    // O id da 1.0.2 vai junto: sem isto a notificação congelada sobrevive ao
    // update e continua disparando ao lado da janela nova.
    await _plugin.cancel(_idLegado);
    for (var i = 0; i < horizonteDias; i++) {
      await _plugin.cancel(_idBase + i);
    }
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

}
