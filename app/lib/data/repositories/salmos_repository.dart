import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/salmo.dart';
import '../models/colecao.dart';
import '../../core/constants/app_constants.dart';

/// Fonte única de dados para Salmos e Coleções.
///
/// Fase 1 (atual): lê assets/salmos.json em memória.
/// Fase 2 (futura): pode ser substituído por um repositório SQLite/Isar
/// sem alterar a interface pública — os providers consomem apenas esta classe.
class SalmosRepository {
  List<Salmo>? _cachedSalmos;
  List<Colecao>? _cachedColecoes;

  Future<List<Salmo>> getSalmos() async {
    if (_cachedSalmos != null) return _cachedSalmos!;
    await _loadJson();
    return _cachedSalmos!;
  }

  Future<List<Colecao>> getColecoes() async {
    if (_cachedColecoes != null) return _cachedColecoes!;
    await _loadJson();
    return _cachedColecoes!;
  }

  Future<Salmo?> getSalmoPorNumero(int numero) async {
    final list = await getSalmos();
    try {
      return list.firstWhere((s) => s.numero == numero);
    } catch (_) {
      return null;
    }
  }

  Future<List<Salmo>> getSalmosPorTema(String tema) async {
    final list = await getSalmos();
    return list.where((s) => s.temas.contains(tema)).toList();
  }

  Future<Colecao?> getColecaoPorId(String id) async {
    final list = await getColecoes();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void invalidateCache() {
    _cachedSalmos = null;
    _cachedColecoes = null;
  }

  Future<void> _loadJson() async {
    final raw = await rootBundle.loadString(AppConstants.salmosJsonPath);
    final data = json.decode(raw) as Map<String, dynamic>;

    _cachedSalmos = (data['salmos'] as List)
        .map((s) => Salmo.fromJson(s as Map<String, dynamic>))
        .toList();

    _cachedColecoes = (data['colecoes'] as List? ?? [])
        .map((c) => Colecao.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
