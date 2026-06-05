import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_constants.dart';

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
    if (updated.contains(numero)) {
      updated.remove(numero);
    } else {
      updated.add(numero);
    }
    // Update otimista — UI responde antes da escrita no disco
    state = AsyncValue.data(updated);
    AnalyticsService.instance.logPsalmFavorited(
      numero,
      added: !current.contains(numero),
    );
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
