import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/data/models/colecao.dart';
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

  group('salmosDaColecao', () {
    const colecoes = [
      Colecao(id: 'luto', titulo: 'L', subtitulo: '', salmos: [3, 7, 9]),
      Colecao(id: 'vazia', titulo: 'V', subtitulo: '', salmos: [999]),
    ];

    test('filtra pelos números da coleção', () {
      final r = salmosDaColecao(_catalogo(150), colecoes, 'luto');
      expect(r.map((s) => s.numero), [3, 7, 9]);
    });

    test('salmoDoDia sobre a lista filtrada sempre cai na coleção', () {
      final r = salmosDaColecao(_catalogo(150), colecoes, 'luto');
      for (var d = 0; d < 30; d++) {
        final s = salmoDoDia(salmos: r, semente: 7, installDay: 0, dia: d);
        expect([3, 7, 9], contains(s.numero));
      }
    });

    test('fallback para todos: id vazio, inexistente ou coleção sem match', () {
      final todos = _catalogo(150);
      expect(salmosDaColecao(todos, colecoes, ''), hasLength(150));
      expect(salmosDaColecao(todos, colecoes, 'nada'), hasLength(150));
      expect(salmosDaColecao(todos, colecoes, 'vazia'), hasLength(150));
      expect(salmosDaColecao(todos, const [], 'luto'), hasLength(150));
    });
  });

  group('salmoDoDiaComEmocao', () {
    final todos = _catalogo(150);
    final colecao = [3, 7, 9, 11, 13, 15, 17, 19];
    final filtrados = todos.where((s) => colecao.contains(s.numero)).toList();

    ({Salmo salmo, bool daColecao}) r(int dia, {int install = 100}) =>
        salmoDoDiaComEmocao(
          todos: todos,
          filtrados: filtrados,
          semente: 9,
          installDay: install,
          dia: dia,
        );

    test('alterna: instalação (offset 0) é coleção, ímpar é geral', () {
      for (var o = 0; o < 20; o++) {
        expect(r(100 + o).daColecao, o.isEven, reason: 'offset $o');
      }
      for (var o = 0; o < 20; o += 2) {
        expect(colecao, contains(r(100 + o).salmo.numero));
      }
    });

    test('cada sub-sequência avança um passo por dia dela, sem pular', () {
      final ordC = embaralhaComSemente(filtrados, 9);
      final ordG = embaralhaComSemente(todos, 9);
      for (var k = 0; k < 20; k++) {
        expect(r(100 + 2 * k).salmo.numero,
            ordC[k % ordC.length].numero, reason: 'coleção k=$k');
        expect(r(101 + 2 * k).salmo.numero,
            ordG[k % ordG.length].numero, reason: 'geral k=$k');
      }
    });

    test('relógio para trás: paridade e passo consistentes (piso)', () {
      expect(r(99).daColecao, isFalse);
      expect(r(98).daColecao, isTrue);
      expect(r(99).salmo.numero, isNot(r(101).salmo.numero));
      expect(r(98).salmo.numero, isNot(r(100).salmo.numero));
      expect(r(99).salmo.numero, isNot(r(100 + 1).salmo.numero));
    });

    test('sem coleção (filtrados == todos) é o salmoDoDia clássico', () {
      for (var d = 100; d < 130; d++) {
        final x = salmoDoDiaComEmocao(
          todos: todos,
          filtrados: todos,
          semente: 9,
          installDay: 100,
          dia: d,
        );
        expect(x.daColecao, isFalse);
        expect(
          x.salmo.numero,
          salmoDoDia(salmos: todos, semente: 9, installDay: 100, dia: d).numero,
        );
      }
    });
  });
}
