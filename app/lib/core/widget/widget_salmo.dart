import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_service.dart';
import '../notifications/notification_service.dart';

/// Widget de tela inicial (Android): "Salmo do dia".
///
/// O nativo (SalmoWidget.kt) não sabe escolher salmo. Ele lê a agenda que o
/// app grava aqui, a mesma de Home e notificação (montarAgenda), e mostra a
/// entrada da data local do aparelho.
///
/// Escolha: AppWidgetProvider puro + este canal, sem `home_widget`. O
/// shared_preferences já grava num SharedPreferences nativo que o Kotlin lê
/// direto; o pacote pouparia só as ~15 linhas do canal.
class WidgetSalmo {
  const WidgetSalmo._();

  static const _canal = MethodChannel('omeusalmo/widget');

  /// O nativo lê como `flutter.widget_agenda` em FlutterSharedPreferences.
  /// Não renomear sem mudar SalmoWidget.kt.
  static const prefAgenda = 'widget_agenda';

  static String chaveDia(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Agenda indexada pela data civil (yyyy-MM-dd) a partir de [hoje].
  static Map<String, Map<String, Object>> payload(
    List<ItemAgenda> agenda,
    DateTime hoje,
  ) =>
      {
        for (final i in agenda)
          chaveDia(DateTime(hoje.year, hoje.month, hoje.day + i.diaOffset)): {
            'numero': i.numero,
            'titulo': i.titulo,
            'versiculo': i.versiculo,
          },
      };

  /// Grava a agenda e pede ao Android que redesenhe o widget.
  static Future<void> publicar(
    List<ItemAgenda> agenda,
    SharedPreferences prefs,
  ) async {
    await prefs.setString(prefAgenda, jsonEncode(payload(agenda, DateTime.now())));
    // Sem await: quem reagenda não espera o launcher. Sem lado nativo (teste,
    // iOS) a resposta nunca chega em fakeAsync e travaria o chamador.
    _canal.invokeMethod('atualizar').catchError((_) => null);
  }

  /// Rota do toque no widget que abriu o app morto. Uma vez só.
  static Future<String?> consumirRotaInicial() async {
    try {
      final rota = await _canal.invokeMethod<String>('rotaInicial');
      if (rota != null) _registrar(rota);
      return rota;
    } catch (_) {
      return null;
    }
  }

  /// Toque no widget com o app vivo.
  static void ouvir(void Function(String rota) abrir) =>
      _canal.setMethodCallHandler((call) async {
        if (call.method != 'abrir') return;
        final rota = call.arguments as String;
        _registrar(rota);
        abrir(rota);
      });

  static void _registrar(String rota) => AnalyticsService.instance
      .logWidgetOpened(int.tryParse(rota.split('/').last));
}
