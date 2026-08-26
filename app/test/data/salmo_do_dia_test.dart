import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/data/models/salmo.dart';
import 'package:salmos_app/data/salmo_do_dia.dart';

List<Salmo> _catalogo(int n) => List.generate(
      n,
      (i) => Salmo(
        numero: i + 1,
        titulo: 'Salmo ${i + 1}',
        traducao: 'teste',
        versiculos: const ['versículo'],
        temas: const [],
        audio: '',
      ),
    );

void main() {
  group('diaCivil', () {
    test('usa o calendário local, não UTC', () {
      // 23h30 de Brasília ainda é o mesmo dia civil que 09h da manhã.
      // Com a conta antiga (epoch ~/ 86400000) as duas caíam em dias
      // diferentes, e o app mostrava a data de hoje com o salmo de amanhã.
      final manha = DateTime(2026, 8, 26, 9, 0);
      final noite = DateTime(2026, 8, 26, 23, 30);
      expect(diaCivil(manha), diaCivil(noite));
    });

    test('vira exatamente na meia-noite local', () {
      expect(
        diaCivil(DateTime(2026, 8, 27, 0, 0)) -
            diaCivil(DateTime(2026, 8, 26, 23, 59)),
        1,
      );
    });
  });

  group('salmoDoDia', () {
    test('é estável: o mesmo dia devolve sempre o mesmo salmo', () {
      final salmos = _catalogo(150);
      final a = salmoDoDia(salmos: salmos, semente: 42, installDay: 100, dia: 137);
      final b = salmoDoDia(salmos: salmos, semente: 42, installDay: 100, dia: 137);
      expect(a.numero, b.numero);
    });

    test('não repete dentro de um ciclo completo', () {
      final salmos = _catalogo(150);
      final vistos = <int>{};
      for (var d = 0; d < 150; d++) {
        vistos.add(
          salmoDoDia(salmos: salmos, semente: 7, installDay: 0, dia: d).numero,
        );
      }
      expect(vistos.length, 150);
    });

    test('sementes diferentes dão ordens diferentes', () {
      final salmos = _catalogo(150);
      final a = List.generate(
        10,
        (d) => salmoDoDia(salmos: salmos, semente: 1, installDay: 0, dia: d).numero,
      );
      final b = List.generate(
        10,
        (d) => salmoDoDia(salmos: salmos, semente: 2, installDay: 0, dia: d).numero,
      );
      expect(a, isNot(equals(b)));
    });

    test('relógio andando para trás não quebra', () {
      // Módulo com divisor positivo nunca devolve negativo em Dart, mas o
      // comportamento é contraintuitivo o bastante para merecer um teste.
      final salmos = _catalogo(150);
      expect(
        () => salmoDoDia(salmos: salmos, semente: 3, installDay: 500, dia: 480),
        returnsNormally,
      );
    });
  });
}
