import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/salmo.dart';
import '../salmo_do_dia.dart';
import '../models/colecao.dart';
import 'onboarding_provider.dart';
import '../repositories/salmos_repository.dart';
import '../../core/constants/app_constants.dart';

// Repositório como singleton gerenciado pelo Riverpod
final salmosRepositoryProvider = Provider<SalmosRepository>(
  (_) => SalmosRepository(),
);

final salmosProvider = FutureProvider<List<Salmo>>((ref) {
  return ref.read(salmosRepositoryProvider).getSalmos();
});

final colecoesProvider = FutureProvider<List<Colecao>>((ref) {
  return ref.read(salmosRepositoryProvider).getColecoes();
});

// .family permite buscar um salmo específico por número sem carregar tudo de novo
final salmoDetalheProvider = FutureProvider.family<Salmo?, int>((ref, numero) {
  return ref.read(salmosRepositoryProvider).getSalmoPorNumero(numero);
});

final colecaoDetalheProvider =
    FutureProvider.family<Colecao?, String>((ref, id) {
  return ref.read(salmosRepositoryProvider).getColecaoPorId(id);
});

/// Dia civil de hoje, como estado. Um FutureProvider que lesse DateTime.now()
/// guardaria o dia da abertura enquanto o processo vivesse: aberto às 22h e
/// retomado às 7h, a Home mostraria o salmo de ontem e a Jornada não contaria
/// a leitura de hoje. Atualiza ao voltar ao primeiro plano e quando alguém
/// chama [DiaCivilNotifier.sincronizar].
class DiaCivilNotifier extends Notifier<int> {
  @override
  int build() {
    final ouvinte = AppLifecycleListener(onResume: sincronizar);
    ref.onDispose(ouvinte.dispose);
    return diaCivil(DateTime.now());
  }

  /// Devolve o dia de agora; só notifica se virou.
  int sincronizar() {
    final agora = diaCivil(DateTime.now());
    if (agora != state) state = agora;
    return agora;
  }
}

final diaCivilProvider =
    NotifierProvider<DiaCivilNotifier, int>(DiaCivilNotifier.new);

// Retorna o Salmo do dia único por usuário — sem repetição por ciclo completo.
// Seed gerado uma vez no primeiro acesso; embaralhamento Fisher-Yates determinístico.
final salmoDoDialProvider = FutureProvider<Salmo?>((ref) async {
  // Só para recalcular quando a emoção mudar; o valor vem das prefs, porque o
  // provider começa em paz até o load assíncrono terminar.
  ref.watch(emocaoInicialProvider);
  final dia = ref.watch(diaCivilProvider);
  final repo = ref.read(salmosRepositoryProvider);
  final todos = await repo.getSalmos();
  if (todos.isEmpty) return null;

  final prefs = await SharedPreferences.getInstance();
  final filtrados = salmosDaColecao(
    todos,
    await repo.getColecoes(),
    emocaoSalva(prefs).colecaoId,
  );

  final id = await identidadeDoUsuario(prefs);

  return salmoDoDiaComEmocao(
    todos: todos,
    filtrados: filtrados,
    semente: id.semente,
    installDay: id.installDay,
    dia: dia,
  ).salmo;
});

// Salmos cujas reflexões foram desbloqueadas (apareceram como Salmo do Dia).
class UnlockedPsalmsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(AppConstants.prefUnlockedPsalms) ?? [];
    return stored.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> unlock(int numero) async {
    final current = await future;
    if (current.contains(numero)) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = {...current, numero};
    await prefs.setStringList(
      AppConstants.prefUnlockedPsalms,
      updated.map((n) => n.toString()).toList(),
    );
    state = AsyncData(updated);
  }
}

final unlockedPsalmsProvider =
    AsyncNotifierProvider<UnlockedPsalmsNotifier, Set<int>>(
  UnlockedPsalmsNotifier.new,
);
