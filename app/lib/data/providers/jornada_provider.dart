import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_constants.dart';
import '../jornada.dart';
import 'salmos_providers.dart';

class JornadaNotifier extends AsyncNotifier<Jornada> {
  @override
  Future<Jornada> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      ultimoDia: prefs.getInt(AppConstants.prefJornadaUltimoDia),
      dias: prefs.getInt(AppConstants.prefJornadaDias) ?? 0,
    );
  }

  /// Chamado pela leitura. Conta só se [numero] é o Salmo do dia de hoje, o
  /// mesmo que a Home e a notificação usam (`salmoDoDialProvider`).
  Future<void> registrarLeitura(int numero) async {
    // Toque na notificação com o app vivo chega antes do onResume: acerta o
    // dia antes de comparar, senão compara com o salmo de ontem.
    final dia = ref.read(diaCivilProvider.notifier).sincronizar();
    final hoje = await ref.read(salmoDoDialProvider.future);
    if (hoje?.numero != numero) return;
    final atual = await future;
    final novo = registrarDia(atual, dia);
    if (novo == atual) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefJornadaUltimoDia, novo.ultimoDia!);
    await prefs.setInt(AppConstants.prefJornadaDias, novo.dias);
    state = AsyncData(novo);
    AnalyticsService.instance.logJornadaDia(novo.dias);
  }
}

final jornadaProvider =
    AsyncNotifierProvider<JornadaNotifier, Jornada>(JornadaNotifier.new);
