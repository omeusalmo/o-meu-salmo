import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/data/providers/jornada_provider.dart';
import 'package:salmos_app/data/providers/salmos_providers.dart';
import 'package:salmos_app/data/salmo_do_dia.dart';

import '../a11y/text_scale_harness.dart';

/// Relógio controlado: [dia] faz o papel de DateTime.now().
class _DiaFalso extends DiaCivilNotifier {
  static int dia = 0;
  @override
  int build() => dia;
  @override
  int sincronizar() {
    if (state != dia) state = dia;
    return dia;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bug da revisão 1.0.6: app aberto às 22h e retomado às 7h mostrava o salmo
  // de ontem, e a leitura do salmo de hoje (vinda da notificação) não contava.
  test('virada do dia com o app vivo: Home e Jornada seguem o dia novo',
      () async {
    SharedPreferences.setMockInitialValues({});
    await SalmosFixture.aquecer();
    final hoje = diaCivil(DateTime.now());
    _DiaFalso.dia = hoje;
    final c = ProviderContainer(overrides: [
      salmosRepositoryProvider.overrideWithValue(SalmosFixture.repo),
      diaCivilProvider.overrideWith(_DiaFalso.new),
    ]);
    addTearDown(c.dispose);
    c.listen(salmoDoDialProvider, (_, __) {});

    final ontem = (await c.read(salmoDoDialProvider.future))!.numero;

    _DiaFalso.dia = hoje + 1; // meia-noite passou, processo vivo
    final amanha = c.read(diaCivilProvider.notifier).sincronizar();
    final novo = (await c.read(salmoDoDialProvider.future))!.numero;
    expect(amanha, hoje + 1);
    expect(novo, isNot(ontem), reason: 'Home presa no salmo de ontem');

    final jornada = c.read(jornadaProvider.notifier);
    await jornada.registrarLeitura(ontem);
    expect((await c.read(jornadaProvider.future)).dias, 0,
        reason: 'salmo de ontem não conta hoje');
    await jornada.registrarLeitura(novo);
    final j = await c.read(jornadaProvider.future);
    expect((j.ultimoDia, j.dias), (hoje + 1, 1));
  });
}
