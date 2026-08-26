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
// ── Ativação ─────────────────────────────────────────────────────────────
  // Mede o funil do primeiro minuto, que hoje é cego: sabemos quantos
  // instalam e quantos ficam, mas não onde desistem no meio.

  /// Passo do onboarding alcançado, de 1 a 5.
  Future<void> logOnboardingStep(int passo) =>
      _log('onboarding_step', {'step': passo});

  /// Usuário pulou o onboarding, e em que passo.
  Future<void> logOnboardingSkipped(int passo) =>
      _log('onboarding_skipped', {'step': passo});

  /// Onboarding concluído. Junta as três escolhas num evento só para dar
  /// para cruzar retenção com o que a pessoa escolheu logo na entrada.
  Future<void> logOnboardingDone({
    required String emocao,
    required bool dadosDeUso,
    required bool notificacao,
  }) =>
      _log('onboarding_done', {
        'emotion_id': emocao,
        'usage_data': dadosDeUso,
        'notif_opt_in': notificacao,
      });

  /// Resposta ao pedido de permissão de notificação.
  ///
  /// [origem] separa quem aceitou no onboarding de quem foi ligar depois em
  /// Ajustes: são momentos muito diferentes de intenção.
  Future<void> logNotifPermission({
    required bool concedida,
    required String origem,
  }) =>
      _log('notif_permission', {'granted': concedida, 'source': origem});

  /// Notificação agendada, com o horário escolhido. O horário importa: se a
  /// maioria escolher a noite, o conteúdo do aviso deveria mudar de tom.
  Future<void> logNotifScheduled(int hora) =>
      _log('notif_scheduled', {'hour': hora});

  // ── Retenção ─────────────────────────────────────────────────────────────

  /// Usuário abriu o app tocando na notificação. É a medida direta de se o
  /// canal de retorno funciona.
  Future<void> logNotifOpened(int numero) =>
      _log('notif_opened', {'psalm_number': numero});

  /// Leitura de fato, não só abertura de tela.
  ///
  /// psalm_opened dispara no instante em que a tela monta e mede intenção;
  /// este só dispara depois de tempo em tela, e é o proxy honesto de ativação.
  Future<void> logPsalmReadComplete(int numero, int segundos) =>
      _log('psalm_read_complete', {
        'psalm_number': numero,
        'seconds': segundos,
      });

  // ── Propriedades de usuário ──────────────────────────────────────────────
  // Valem mais que os eventos: permitem cortar retenção por segmento.

  Future<void> _setProp(String nome, String? valor) async {
    if (_analytics == null) return;
    try {
      await _analytics!.setUserProperty(name: nome, value: valor);
    } catch (_) {}
  }

  /// Se a pessoa tem notificação ligada. Cruzar isto com retenção é a
  /// pergunta mais importante que o app ainda não sabe responder.
  Future<void> setNotifEnabled(bool ligada) =>
      _setProp('notif_enabled', ligada ? 'true' : 'false');

  /// Emoção escolhida no onboarding.
  ///
  /// Mesma granularidade agregada de collection_id (ver logCollectionOpened):
  /// um rótulo de curadoria entre oito, nunca texto livre nem estado de saúde
  /// declarado pela pessoa.
  Future<void> setEmocaoInicial(String emocaoId) =>
      _setProp('emocao_inicial', emocaoId);


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
