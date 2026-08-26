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

  test('agenda cobre o horizonte inteiro, um item por dia', () async {
    final agenda = await AgendadorSalmoDiario.montarAgenda(
      salmos: _catalogo(150),
      prefs: prefs,
    );
    expect(agenda, hasLength(NotificationService.horizonteDias));
    expect(
      agenda.map((i) => i.diaOffset).toList(),
      List.generate(NotificationService.horizonteDias, (i) => i),
    );
  });

  test('REGRESSÃO: o aviso de hoje é o mesmo salmo que a Home mostra', () async {
    // O bug da 1.0.2: a notificação escolhia por "dia do ano % total" e a Home
    // por embaralhamento com semente. Anunciava um salmo e abria outro.
    final salmos = _catalogo(150);
    final agenda = await AgendadorSalmoDiario.montarAgenda(salmos: salmos, prefs: prefs);

    final naHome = salmoDoDia(
      salmos: salmos,
      semente: prefs.getInt(AppConstants.prefUserSeed)!,
      installDay: prefs.getInt(AppConstants.prefInstallDay)!,
      dia: diaCivil(DateTime.now()),
    );

    expect(agenda.first.numero, naHome.numero);
  });

  test('REGRESSÃO: cada dia tem o seu salmo, não o mesmo repetido', () async {
    // O outro lado do bug: matchDateTimeComponents.time fazia um único
    // agendamento repetir o mesmo texto para sempre.
    final agenda = await AgendadorSalmoDiario.montarAgenda(
      salmos: _catalogo(150),
      prefs: prefs,
    );
    expect(agenda.map((i) => i.numero).toSet(), hasLength(agenda.length));
  });

  test('o corpo do aviso é o primeiro versículo, o mesmo que a Home destaca', () async {
    final salmos = _catalogo(150);
    final agenda = await AgendadorSalmoDiario.montarAgenda(salmos: salmos, prefs: prefs);
    final salmo = salmos.firstWhere((s) => s.numero == agenda.first.numero);
    expect(agenda.first.versiculo, salmo.versiculos.first);
    expect(agenda.first.titulo, salmo.titulo);
  });

  test('versículo longo é cortado em fronteira de palavra', () async {
    final longo = 'palavra ' * 40;
    final agenda = await AgendadorSalmoDiario.montarAgenda(
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

  test('REGRESSÃO: no dia 1, com prefs vazias, a semente é PERSISTIDA', () async {
    // O caso real de produção que os outros testes não cobriam: eles plantavam
    // uma semente no setUp. Sem persistir, cada abertura gerava uma semente
    // nova e a notificação divergia da Home até a Home montar — e o onboarding
    // leva para a coleção da emoção, então ela pode não montar por dias.
    SharedPreferences.setMockInitialValues({});
    final vazio = await SharedPreferences.getInstance();
    expect(vazio.getInt(AppConstants.prefUserSeed), isNull);

    await AgendadorSalmoDiario.montarAgenda(salmos: _catalogo(150), prefs: vazio);

    expect(vazio.getInt(AppConstants.prefUserSeed), isNotNull,
        reason: 'o agendador precisa gravar a semente, não só usá-la');
    expect(vazio.getInt(AppConstants.prefInstallDay), isNotNull,
        reason: 'sem installDay gravado o offset é sempre 0 e o salmo repete');
  });

  test('REGRESSÃO: agendador e Home concordam mesmo partindo do zero', () async {
    SharedPreferences.setMockInitialValues({});
    final zero = await SharedPreferences.getInstance();
    final salmos = _catalogo(150);

    // Ordem real: a splash agenda antes de a Home montar.
    final agenda = await AgendadorSalmoDiario.montarAgenda(salmos: salmos, prefs: zero);
    final id = await identidadeDoUsuario(zero);
    final naHome = salmoDoDia(
      salmos: salmos,
      semente: id.semente,
      installDay: id.installDay,
      dia: diaCivil(DateTime.now()),
    );

    expect(agenda.first.numero, naHome.numero);
  });
}
