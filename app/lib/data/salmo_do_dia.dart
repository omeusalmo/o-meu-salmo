/// Lógica do Salmo do Dia, sem I/O e sem prefs, para a Home e o agendador de
/// notificações darem sempre a mesma resposta.
///
/// Antes cada um tinha a sua: a Home embaralhava com semente por usuário e a
/// notificação usava `dia do ano % total`. O resultado é que o aviso anunciava
/// um salmo e o app abria outro.
library;

import 'dart:math';

import 'models/salmo.dart';

/// Dia civil do calendário local.
///
/// Contar `millisecondsSinceEpoch ~/ 86400000` direto vira dia UTC, e o dia
/// virava às 21h de Brasília: entre 21h e meia-noite o cabeçalho mostrava a
/// data de hoje com o salmo de amanhã. Montar a data em UTC a partir dos
/// campos locais dá o dia certo sem sofrer com horário de verão.
int diaCivil(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

/// Fisher-Yates determinístico: a mesma semente devolve sempre a mesma ordem.
List<T> embaralhaComSemente<T>(List<T> lista, int semente) {
  final rng = Random(semente);
  final copia = List<T>.from(lista);
  for (int i = copia.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = copia[i];
    copia[i] = copia[j];
    copia[j] = tmp;
  }
  return copia;
}

/// O salmo de um dia específico.
///
/// [dia] e [installDay] são dias civis (ver [diaCivil]). O módulo de Dart com
/// divisor positivo nunca devolve negativo, então relógio andando para trás
/// não quebra a conta.
Salmo salmoDoDia({
  required List<Salmo> salmos,
  required int semente,
  required int installDay,
  required int dia,
}) {
  final ordenados = embaralhaComSemente(salmos, semente);
  final posicao = (dia - installDay) % ordenados.length;
  return ordenados[posicao];
}
