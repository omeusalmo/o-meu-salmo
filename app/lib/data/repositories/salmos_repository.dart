import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  Map<int, Salmo>? _salmosPorNumero;

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
    await getSalmos(); // garante _salmosPorNumero carregado
    return _salmosPorNumero![numero];
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
    _salmosPorNumero = null;
  }

  Future<void> _loadJson() async {
    final raw = await rootBundle.loadString(AppConstants.salmosJsonPath);
    final data = json.decode(raw) as Map<String, dynamic>;

    // Parse resiliente por item: um registro malformado (edição futura de
    // conteúdo) é ignorado sem derrubar o app inteiro. Melhor 149 salmos que 0.
    _cachedSalmos = [];
    for (final s in (data['salmos'] as List? ?? [])) {
      try {
        _cachedSalmos!.add(Salmo.fromJson(s as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[Salmos] registro ignorado: $e');
      }
    }
    _salmosPorNumero = {for (final s in _cachedSalmos!) s.numero: s};

    _cachedColecoes = [];
    for (final c in (data['colecoes'] as List? ?? [])) {
      try {
        _cachedColecoes!.add(Colecao.fromJson(c as Map<String, dynamic>));
      } catch (e) {
        debugPrint('[Colecoes] registro ignorado: $e');
      }
    }
  }
}
