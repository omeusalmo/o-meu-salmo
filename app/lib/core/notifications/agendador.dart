import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/salmo.dart';
import '../../data/models/colecao.dart';
import '../../data/providers/onboarding_provider.dart';
import '../../data/salmo_do_dia.dart';
import '../constants/copy_emocao.dart';
import '../constants/app_constants.dart';
import '../widget/widget_salmo.dart';
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
  /// Sempre alimenta o widget. Da notificação, não agenda nada se estiver
  /// desligada, e cancela o que houver:
  /// assim desligar nas Configurações do Android não deixa alarme órfão.
  static Future<void> reagendar(
    List<Salmo> salmos, {
    required List<Colecao> colecoes,
  }) async {
    if (salmos.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final agenda = await montarAgenda(
      salmos: salmos,
      prefs: prefs,
      colecoes: colecoes,
    );
    // Widget recebe a agenda antes do gate: ele independe da notificação.
    await WidgetSalmo.publicar(agenda, prefs);

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
      agenda: agenda,
    );
  }

  /// A agenda dos próximos [NotificationService.horizonteDias] dias.
  ///
  /// Separado de [reagendar] para o teste conferir o conteúdo sem tocar no
  /// plugin nativo.
  static Future<List<ItemAgenda>> montarAgenda({
    required List<Salmo> salmos,
    required SharedPreferences prefs,
    List<Colecao> colecoes = const [],
  }) async {
    // Lê e persiste, igual à Home. Gerar uma semente efêmera aqui fazia a
    // notificação divergir do app até a Home montar pela primeira vez.
    final id = await identidadeDoUsuario(prefs);
    final hoje = diaCivil(DateTime.now());
    // Mesma emoção e mesmo filtro da Home (salmoDoDialProvider).
    final emocao = emocaoSalva(prefs);
    final filtrados = salmosDaColecao(salmos, colecoes, emocao.colecaoId);
    final frase = CopyEmocao.fraseAviso[emocao];

    return List.generate(NotificationService.horizonteDias, (i) {
      final r = salmoDoDiaComEmocao(
        todos: salmos,
        filtrados: filtrados,
        semente: id.semente,
        installDay: id.installDay,
        dia: hoje + i,
      );
      final salmo = r.salmo;
      return ItemAgenda(
        diaOffset: i,
        numero: salmo.numero,
        titulo: salmo.titulo,
        versiculo: _resumo(salmo.versiculos.first),
        // Só em dia de coleção; dia geral usa o aviso clássico.
        frase: r.daColecao ? frase : null,
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
