import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/salmo.dart';
import '../models/colecao.dart';
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

// Retorna o Salmo do dia único por usuário — sem repetição por ciclo completo.
// Seed gerado uma vez no primeiro acesso; embaralhamento Fisher-Yates determinístico.
final salmoDoDialProvider = FutureProvider<Salmo?>((ref) async {
  final salmos = await ref.read(salmosRepositoryProvider).getSalmos();
  if (salmos.isEmpty) return null;

  final prefs = await SharedPreferences.getInstance();

  int seed = prefs.getInt(AppConstants.prefUserSeed) ?? 0;
  if (seed == 0) {
    seed = Random().nextInt(0x7FFFFFFF);
    await prefs.setInt(AppConstants.prefUserSeed, seed);
  }

  final todayEpochDay = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  int installDay = prefs.getInt(AppConstants.prefInstallDay) ?? -1;
  if (installDay == -1) {
    installDay = todayEpochDay;
    await prefs.setInt(AppConstants.prefInstallDay, installDay);
  }

  final shuffled = _seededShuffle(salmos, seed);
  final position = (todayEpochDay - installDay) % shuffled.length;
  return shuffled[position];
});

List<Salmo> _seededShuffle(List<Salmo> list, int seed) {
  final rng = Random(seed);
  final copy = List<Salmo>.from(list);
  for (int i = copy.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = copy[i];
    copy[i] = copy[j];
    copy[j] = tmp;
  }
  return copy;
}

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
