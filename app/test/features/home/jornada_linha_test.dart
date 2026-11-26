import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/data/models/salmo.dart';
import 'package:salmos_app/data/providers/jornada_provider.dart';
import 'package:salmos_app/data/providers/salmos_providers.dart';
import 'package:salmos_app/data/salmo_do_dia.dart';
import 'package:salmos_app/features/home/jornada_linha.dart';

const _salmo7 = Salmo(
  numero: 7,
  titulo: 't',
  traducao: 'x',
  versiculos: ['v'],
  temas: [],
  audio: '',
);

Widget _app(ProviderContainer c, {double escala = 1.0}) =>
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(escala)),
          child: const Scaffold(body: JornadaLinha()),
        ),
      ),
    );

ProviderContainer _container() => ProviderContainer(overrides: [
      salmoDoDialProvider.overrideWith((_) async => _salmo7),
    ]);

void main() {
  final hoje = diaCivil(DateTime.now());

  testWidgets('mostra a linha, plural, em 2.0x sem overflow', (t) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefJornadaUltimoDia: hoje - 1,
      AppConstants.prefJornadaDias: 3,
    });
    final c = _container();
    addTearDown(c.dispose);
    await t.pumpWidget(_app(c, escala: 2.0));
    await t.pumpAndSettle();
    expect(find.text('3 dias com os Salmos'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('corrente quebrada ou nunca contada: nada na tela', (t) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefJornadaUltimoDia: hoje - 2,
      AppConstants.prefJornadaDias: 9,
    });
    final c = _container();
    addTearDown(c.dispose);
    await t.pumpWidget(_app(c));
    await t.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('só o Salmo do dia conta; a Home atualiza na hora', (t) async {
    SharedPreferences.setMockInitialValues({});
    final c = _container();
    addTearDown(c.dispose);
    await t.pumpWidget(_app(c));
    await t.pumpAndSettle();
    expect(find.byType(Text), findsNothing);

    await c.read(jornadaProvider.notifier).registrarLeitura(8);
    await t.pumpAndSettle();
    expect(find.byType(Text), findsNothing);

    await c.read(jornadaProvider.notifier).registrarLeitura(7);
    await t.pumpAndSettle();
    expect(find.text('1 dia com os Salmos'), findsOneWidget);
  });
}
