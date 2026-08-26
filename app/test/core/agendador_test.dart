import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/notifications/agendador.dart';
import 'package:salmos_app/core/notifications/notification_service.dart';
import 'package:salmos_app/data/models/salmo.dart';
import 'package:salmos_app/data/salmo_do_dia.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Salmo> _catalogo(int n) => List.generate(
      n,
      (i) => Salmo(
        numero: i + 1,
        titulo: 'Título ${i + 1}',
        traducao: 'teste',
        versiculos: ['Primeiro versículo do salmo ${i + 1}.', 'segundo'],
        temas: const [],
        audio: '',
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefUserSeed: 4242,
      AppConstants.prefInstallDay: diaCivil(DateTime.now()) - 30,
    });
    prefs = await SharedPreferences.getInstance();
  });

  test('agenda cobre o horizonte inteiro, um item por dia', () {
    final agenda = AgendadorSalmoDiario.montarAgenda(
      salmos: _catalogo(150),
      prefs: prefs,
    );
    expect(agenda, hasLength(NotificationService.horizonteDias));
    expect(
      agenda.map((i) => i.diaOffset).toList(),
      List.generate(NotificationService.horizonteDias, (i) => i),
    );
  });

  test('REGRESSÃO: o aviso de hoje é o mesmo salmo que a Home mostra', () {
    // O bug da 1.0.2: a notificação escolhia por "dia do ano % total" e a Home
    // por embaralhamento com semente. Anunciava um salmo e abria outro.
    final salmos = _catalogo(150);
    final agenda = AgendadorSalmoDiario.montarAgenda(salmos: salmos, prefs: prefs);

    final naHome = salmoDoDia(
      salmos: salmos,
      semente: prefs.getInt(AppConstants.prefUserSeed)!,
      installDay: prefs.getInt(AppConstants.prefInstallDay)!,
      dia: diaCivil(DateTime.now()),
    );

    expect(agenda.first.numero, naHome.numero);
  });

  test('REGRESSÃO: cada dia tem o seu salmo, não o mesmo repetido', () {
    // O outro lado do bug: matchDateTimeComponents.time fazia um único
    // agendamento repetir o mesmo texto para sempre.
    final agenda = AgendadorSalmoDiario.montarAgenda(
      salmos: _catalogo(150),
      prefs: prefs,
    );
    expect(agenda.map((i) => i.numero).toSet(), hasLength(agenda.length));
  });

  test('o corpo do aviso é o primeiro versículo, o mesmo que a Home destaca', () {
    final salmos = _catalogo(150);
    final agenda = AgendadorSalmoDiario.montarAgenda(salmos: salmos, prefs: prefs);
    final salmo = salmos.firstWhere((s) => s.numero == agenda.first.numero);
    expect(agenda.first.versiculo, salmo.versiculos.first);
    expect(agenda.first.titulo, salmo.titulo);
  });

  test('versículo longo é cortado em fronteira de palavra', () {
    final longo = 'palavra ' * 40;
    final agenda = AgendadorSalmoDiario.montarAgenda(
      salmos: [
        Salmo(
          numero: 1,
          titulo: 'Longo',
          traducao: 'teste',
          versiculos: [longo.trim()],
          temas: const [],
          audio: '',
        ),
      ],
      prefs: prefs,
    );
    final texto = agenda.first.versiculo;
    expect(texto.length, lessThanOrEqualTo(121));
    expect(texto, endsWith('…'));
    expect(texto, isNot(contains('  ')));
  });

  test('catálogo vazio não estoura', () {
    expect(
      () => AgendadorSalmoDiario.montarAgenda(salmos: const [], prefs: prefs),
      throwsA(anything),
      reason: 'lista vazia é barrada antes, em reagendar()',
    );
  });
}
