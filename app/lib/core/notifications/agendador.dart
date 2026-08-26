import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/salmo.dart';
import '../../data/salmo_do_dia.dart';
import '../constants/app_constants.dart';
import 'notification_service.dart';

/// Monta a agenda de notificações a partir da mesma função que a Home usa.
///
/// É o único lugar que junta prefs, catálogo e calendário; o
/// [NotificationService] fica sem regra de negócio e testável sem plugin.
class AgendadorSalmoDiario {
  const AgendadorSalmoDiario._();

  /// Reagenda a janela inteira. Chamado a cada abertura do app e sempre que o
  /// usuário liga a notificação ou troca o horário.
  ///
  /// Não faz nada se a notificação estiver desligada, e cancela o que houver:
  /// assim desligar nas Configurações do Android não deixa alarme órfão.
  static Future<void> reagendar(List<Salmo> salmos) async {
    if (salmos.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final ligada = prefs.getBool(AppConstants.prefNotificationEnabled) ?? false;
    if (!ligada) {
      await NotificationService.instance.cancelarJanela();
      return;
    }

    final hora = prefs.getInt(AppConstants.prefNotificationHour) ??
        AppConstants.defaultNotifHour;
    final minuto = prefs.getInt(AppConstants.prefNotificationMinute) ??
        AppConstants.defaultNotifMinute;

    await NotificationService.instance.agendarJanela(
      hour: hora,
      minute: minuto,
      agenda: montarAgenda(salmos: salmos, prefs: prefs),
    );
  }

  /// A agenda dos próximos [NotificationService.horizonteDias] dias.
  ///
  /// Separado de [reagendar] para o teste conferir o conteúdo sem tocar no
  /// plugin nativo.
  static List<ItemAgenda> montarAgenda({
    required List<Salmo> salmos,
    required SharedPreferences prefs,
  }) {
    int semente = prefs.getInt(AppConstants.prefUserSeed) ?? 0;
    if (semente == 0) semente = Random().nextInt(0x7FFFFFFF);

    final hoje = diaCivil(DateTime.now());
    final installDay = prefs.getInt(AppConstants.prefInstallDay) ?? hoje;

    return List.generate(NotificationService.horizonteDias, (i) {
      final salmo = salmoDoDia(
        salmos: salmos,
        semente: semente,
        installDay: installDay,
        dia: hoje + i,
      );
      return ItemAgenda(
        diaOffset: i,
        numero: salmo.numero,
        titulo: salmo.titulo,
        versiculo: _resumo(salmo.versiculos.first),
      );
    });
  }

  /// Primeiro versículo, cortado em fronteira de palavra.
  ///
  /// A mediana é de 82 caracteres e só 6 dos 150 passam de 140, então o corte
  /// quase nunca acontece; quando acontece, o texto inteiro continua visível
  /// na notificação expandida (BigTextStyleInformation).
  static String _resumo(String versiculo, {int maximo = 120}) {
    final t = versiculo.trim();
    if (t.length <= maximo) return t;
    final corte = t.substring(0, maximo);
    final espaco = corte.lastIndexOf(' ');
    return '${corte.substring(0, espaco > 0 ? espaco : maximo).trimRight()}…';
  }
}
