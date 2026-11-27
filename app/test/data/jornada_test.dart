import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/constants/copy_jornada.dart';
import 'package:salmos_app/data/jornada.dart';
import 'package:salmos_app/features/home/jornada_linha.dart';

void main() {
  const j5 = (ultimoDia: 100, dias: 5);

  test('primeira vez: 1', () {
    expect(registrarDia(jornadaVazia, 100), (ultimoDia: 100, dias: 1));
  });
  test('mesmo dia: não muda', () => expect(registrarDia(j5, 100), j5));
  test('dia seguinte: +1', () {
    expect(registrarDia(j5, 101), (ultimoDia: 101, dias: 6));
  });
  test('buraco de 1+ dias: recomeça em 1', () {
    expect(registrarDia(j5, 102), (ultimoDia: 102, dias: 1));
    expect(registrarDia(j5, 200), (ultimoDia: 200, dias: 1));
  });
  test('relógio para trás: não muda', () => expect(registrarDia(j5, 99), j5));

  test('corrente viva só hoje ou ontem', () {
    expect(jornadaViva(j5, 100), isTrue);
    expect(jornadaViva(j5, 101), isTrue);
    expect(jornadaViva(j5, 102), isFalse);
    expect(jornadaViva(jornadaVazia, 100), isFalse);
  });

  test('copy singular e plural', () {
    expect(CopyJornada.contagem(1), ('1º', ' dia com os Salmos'));
    expect(CopyJornada.contagem(3), ('3', ' dias seguidos'));
    expect(CopyJornada.falta(6), ' · o 7º é hoje');
  });

  test('semana: marca só os dias da corrente dentro dos últimos 7', () {
    // j5: último dia 100, 5 dias (96..100). Hoje 101: 95..101.
    expect(semanaJornada(j5, 101),
        [false, true, true, true, true, true, false]);
    // Corrente maior que a semana: tudo cheio.
    expect(semanaJornada((ultimoDia: 100, dias: 30), 100),
        List.filled(7, true));
  });
}
