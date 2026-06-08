import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_constants.dart';

const _kTimestampsKey = 'fav_timestamps';

class FavTimestampsNotifier extends AsyncNotifier<Map<int, int>> {
  @override
  Future<Map<int, int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kTimestampsKey) ?? [];
    return Map.fromEntries(list.map((e) {
      final idx = e.indexOf(':');
      return MapEntry(int.parse(e.substring(0, idx)), int.parse(e.substring(idx + 1)));
    }));
  }

  Future<void> add(int numero) async {
    final current = await future;
    final updated = Map<int, int>.from(current)..[numero] = DateTime.now().millisecondsSinceEpoch;
    state = AsyncValue.data(updated);
    await _save(updated);
  }

  Future<void> remove(int numero) async {
    final current = await future;
    final updated = Map<int, int>.from(current)..remove(numero);
    state = AsyncValue.data(updated);
    await _save(updated);
  }

  Future<void> _save(Map<int, int> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kTimestampsKey,
      data.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }
}

final favTimestampsProvider =
    AsyncNotifierProvider<FavTimestampsNotifier, Map<int, int>>(FavTimestampsNotifier.new);

/// Gerencia os números dos Salmos favoritados pelo usuário.
///
/// Persiste em SharedPreferences como lista de strings ("1", "23", "100").
/// Estado inicial carregado assincronamente no build().
/// toggle() faz update otimista (estado muda imediatamente, prefs salva em bg).
class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.prefFavoritosKey) ?? [];
    return list.map(int.parse).toSet();
  }

  Future<void> toggle(int numero) async {
    final current = await future;
    final updated = Set<int>.from(current);
    final adding = !current.contains(numero);
    if (adding) {
      updated.add(numero);
      ref.read(favTimestampsProvider.notifier).add(numero);
    } else {
      updated.remove(numero);
      ref.read(favTimestampsProvider.notifier).remove(numero);
    }
    // Update otimista — UI responde antes da escrita no disco
    state = AsyncValue.data(updated);
    AnalyticsService.instance.logPsalmFavorited(numero, added: adding);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      AppConstants.prefFavoritosKey,
      updated.map((n) => n.toString()).toList(),
    );
  }

  bool isFavorito(int numero) => state.value?.contains(numero) ?? false;
}

final favoritosProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
