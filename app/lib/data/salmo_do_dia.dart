/// Lógica do Salmo do Dia, sem I/O e sem prefs, para a Home e o agendador de
/// notificações darem sempre a mesma resposta.
///
/// Antes cada um tinha a sua: a Home embaralhava com semente por usuário e a
/// notificação usava `dia do ano % total`. O resultado é que o aviso anunciava
/// um salmo e o app abria outro.
library;

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import 'models/colecao.dart';
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

/// Salmos da coleção [colecaoId]; todos se o id for vazio (paz), a coleção não
/// existir ou nenhum número dela estiver no catálogo.
///
/// Home e agendador passam pela mesma função, então a lista filtrada, e com ela
/// o embaralhamento, é idêntica nos dois.
List<Salmo> salmosDaColecao(
  List<Salmo> salmos,
  List<Colecao> colecoes,
  String colecaoId,
) {
  for (final c in colecoes) {
    if (c.id != colecaoId) continue;
    final filtrados = salmos.where((s) => c.salmos.contains(s.numero)).toList();
    return filtrados.isEmpty ? salmos : filtrados;
  }
  return salmos;
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

/// Salmo do dia com emoção: dias alternam entre a coleção da emoção e os 150.
///
/// `offset = dia - installDay`. Offset par (inclusive o dia da instalação, que
/// é quando a pessoa acabou de escolher a emoção) é dia de COLEÇÃO; ímpar é dia
/// GERAL. Cada lista avança um passo por dia dela (`offset >> 1`, que arredonda
/// para baixo também em offset negativo; `~/` truncaria para zero e repetiria
/// o salmo em -1 e 0), então nenhuma pula salmo.
///
/// Sem coleção ([filtrados] com o mesmo tamanho de [todos]: paz, id inexistente
/// ou fallback) é o [salmoDoDia] clássico sobre [todos], sempre `daColecao: false`.
({Salmo salmo, bool daColecao}) salmoDoDiaComEmocao({
  required List<Salmo> todos,
  required List<Salmo> filtrados,
  required int semente,
  required int installDay,
  required int dia,
}) {
  final offset = dia - installDay;
  if (filtrados.length == todos.length) {
    return (
      salmo: salmoDoDia(
          salmos: todos, semente: semente, installDay: installDay, dia: dia),
      daColecao: false,
    );
  }
  final daColecao = offset.isEven;
  return (
    salmo: salmoDoDia(
      salmos: daColecao ? filtrados : todos,
      semente: semente,
      installDay: 0,
      dia: offset >> 1,
    ),
    daColecao: daColecao,
  );
}

/// Identidade do usuário para o Salmo do Dia: semente do embaralhamento e dia
/// da instalação.
///
/// Lê e, se não existir, **cria e grava**. Antes cada lado fazia o seu: a Home
/// gravava, o agendador de notificações gerava uma semente efêmera e a
/// descartava. Como o onboarding leva para a coleção da emoção escolhida, a
/// Home podia não montar por dias, e a notificação agendava com uma semente
/// diferente a cada abertura: o aviso anunciava um salmo e o app abria outro,
/// que é justamente o bug que esta versão conserta.
Future<({int semente, int installDay})> identidadeDoUsuario(
  SharedPreferences prefs,
) async {
  var semente = prefs.getInt(AppConstants.prefUserSeed) ?? 0;
  if (semente == 0) {
    semente = Random().nextInt(0x7FFFFFFF);
    await prefs.setInt(AppConstants.prefUserSeed, semente);
  }

  var installDay = prefs.getInt(AppConstants.prefInstallDay) ?? -1;
  if (installDay == -1) {
    installDay = diaCivil(DateTime.now());
    await prefs.setInt(AppConstants.prefInstallDay, installDay);
  }

  return (semente: semente, installDay: installDay);
}
