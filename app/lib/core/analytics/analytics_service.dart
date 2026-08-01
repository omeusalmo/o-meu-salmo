import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Singleton que encapsula Firebase Analytics.
///
/// Todos os métodos são no-op silenciosos enquanto Firebase não estiver
/// configurado (firebase_options.dart com valores reais). Quando configurado,
/// os eventos aparecem automaticamente no console sem mudança de código.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('[Analytics] Firebase não disponível: $e');
    }
  }

  /// Liga/desliga a coleta de dados de uso (Analytics + Crashlytics).
  /// Respeita a escolha do usuário no opt-out de Ajustes (LGPD).
  Future<void> setCollectionEnabled(bool enabled) async {
    try {
      await _analytics?.setAnalyticsCollectionEnabled(enabled);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    } catch (_) {}
  }

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  // ── Eventos ──────────────────────────────────────────────────────────────

  /// Usuário abriu a tela de leitura de um Salmo.
  Future<void> logPsalmOpened(int numero) =>
      _log('psalm_opened', {'psalm_number': numero});

  /// Usuário favoritou ou desfavoritou um Salmo.
  Future<void> logPsalmFavorited(int numero, {required bool added}) =>
      _log('psalm_favorited', {
        'psalm_number': numero,
        'action': added ? 'add' : 'remove',
      });

  /// Usuário compartilhou uma imagem de versículo.
  Future<void> logPsalmShared(int numero, int verseIndex, String background) =>
      _log('psalm_shared', {
        'psalm_number': numero,
        'verse_index': verseIndex,
        'background': background,
      });

  /// Usuário abriu uma coleção temática.
  ///
  /// Loga só o `id` agregado — nunca o título ("Ansiedade", "Luto"), que
  /// vincularia estado emocional/religioso ao device (dado sensível, LGPD Art. 11).
  Future<void> logCollectionOpened(String id) =>
      _log('collection_opened', {'collection_id': id});

  /// Usuário realizou uma busca.
  Future<void> logSearch(String query, bool hasResults) =>
      _log('psalm_search', {
        'query_length': query.length,
        'has_results': hasResults,
      });

  /// Usuário tocou no player de áudio.
  Future<void> logAudioPlayed(int numero) =>
      _log('audio_played', {'psalm_number': numero});
}
