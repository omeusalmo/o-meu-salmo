import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/salmo.dart';
import '../models/colecao.dart';
import '../repositories/salmos_repository.dart';

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

// Retorna o Salmo do dia com base no dia do ano — determinístico (mesmo salmo
// durante todo o dia, muda à meia-noite). Cicla pelos salmos disponíveis.
final salmoDoDialProvider = FutureProvider<Salmo?>((ref) async {
  final salmos = await ref.read(salmosRepositoryProvider).getSalmos();
  if (salmos.isEmpty) return null;
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return salmos[dayOfYear % salmos.length];
});
