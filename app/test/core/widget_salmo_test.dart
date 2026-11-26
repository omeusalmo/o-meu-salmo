import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/notifications/agendador.dart';
import 'package:salmos_app/core/notifications/notification_service.dart';
import 'package:salmos_app/core/widget/widget_salmo.dart';
import 'package:salmos_app/data/models/colecao.dart';
import 'package:salmos_app/data/models/salmo.dart';
import 'package:salmos_app/data/salmo_do_dia.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Salmo> _catalogo(int n) => List.generate(
      n,
      (i) => Salmo(
        numero: i + 1,
        titulo: 'Título ${i + 1}',
        traducao: 'teste',
        versiculos: ['Primeiro versículo do salmo ${i + 1}.'],
        temas: const [],
        audio: '',
      ),
    );

List<ItemAgenda> _agenda(int dias) => List.generate(
      dias,
      (i) => ItemAgenda(diaOffset: i, numero: i + 1, titulo: 't$i', versiculo: 'v$i'),
    );

class _NotificacaoFalsa extends NotificationService {
  @override
  Future<void> cancelarJanela() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('chave do dia é yyyy-MM-dd com zero à esquerda', () {
    expect(WidgetSalmo.chaveDia(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
  });

  test('hoje é o offset 0; 14 dias cobertos; o 15º não existe (fallback nativo)',
      () {
    final p = WidgetSalmo.payload(_agenda(14), DateTime(2026, 1, 25, 8));
    expect(p, hasLength(14));
    expect(p['2026-01-25']!['numero'], 1);
    // Virada de mês.
    expect(p['2026-02-07']!['numero'], 14);
    expect(p.containsKey('2026-02-08'), isFalse);
  });

  test('virada de horário de verão não pula nem repete dia', () {
    // DateTime(y, m, d + i) é aritmética civil, imune a dia de 23h/25h.
    final p = WidgetSalmo.payload(_agenda(14), DateTime(2026, 10, 30));
    expect(p.keys.toSet(), hasLength(14));
    expect(p.containsKey('2026-11-12'), isTrue);
  });

  test('REGRESSÃO: notificação desligada ainda alimenta o widget, '
      'com o mesmo salmo da Home sob emoção', () async {
    const colecoes = [
      Colecao(id: 'luto', titulo: 'L', subtitulo: '', salmos: [3, 7, 9, 11]),
    ];
    final hoje = diaCivil(DateTime.now());
    SharedPreferences.setMockInitialValues({
      AppConstants.prefUserSeed: 4242,
      AppConstants.prefInstallDay: hoje - 6,
      AppConstants.prefEmocaoInicial: 'luto',
      AppConstants.prefNotificationEnabled: false,
    });
    NotificationService.instance = _NotificacaoFalsa();
    addTearDown(() => NotificationService.instance = NotificationService());

    final salmos = _catalogo(150);
    await AgendadorSalmoDiario.reagendar(salmos, colecoes: colecoes);

    final prefs = await SharedPreferences.getInstance();
    final gravado = jsonDecode(prefs.getString(WidgetSalmo.prefAgenda)!)
        as Map<String, dynamic>;
    final naHome = salmoDoDiaComEmocao(
      todos: salmos,
      filtrados: salmosDaColecao(salmos, colecoes, 'luto'),
      semente: 4242,
      installDay: hoje - 6,
      dia: hoje,
    );
    final hojeWidget = gravado[WidgetSalmo.chaveDia(DateTime.now())];
    expect(hojeWidget['numero'], naHome.salmo.numero);
    expect([3, 7, 9, 11], contains(hojeWidget['numero']),
        reason: 'offset par = dia da coleção da emoção');
    expect(hojeWidget['titulo'], naHome.salmo.titulo);
  });
}
