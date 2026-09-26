class AppConstants {
  AppConstants._();

  static const String salmosJsonPath = 'assets/salmos.json';

  // Chaves SharedPreferences
  static const String prefFavoritosKey = 'favoritos_numeros';
  static const String prefThemeModeKey = 'theme_mode';
  static const String prefFontScaleKey = 'font_scale';
  static const String prefNotificationEnabled = 'notif_enabled';
  static const String prefNotificationHour   = 'notif_hour';
  static const String prefNotificationMinute = 'notif_minute';
  static const String prefUserSeed           = 'user_seed';
  static const String prefInstallDay         = 'install_day';
  static const String prefUnlockedPsalms     = 'unlocked_psalms';
  static const String prefOnboardingDone     = 'onboarding_done';
  static const String prefEmocaoInicial      = 'emocao_inicial';
  static const String prefUsageDataEnabled   = 'usage_data_enabled';
  static const String prefFavTimestamps      = 'fav_timestamps';
  static const String prefReviewSessionCount = 'review_session_count';

  /// Legado: o gate antigo do pedido de avaliação, um booleano "já pediu".
  /// Continua sendo LIDO para migração — quem já viu o prompt entra na trava de
  /// 120 dias em vez de receber outro pedido no dia da atualização. Não escrever
  /// mais nele. Ver ApoioPrefs.ler().
  static const String prefReviewRequested    = 'review_requested';

  // Apoio e avaliação (ver core/apoio/elegibilidade.dart)
  static const String prefPrimeiraAberturaMs    = 'apoio_primeira_abertura_ms';
  static const String prefLeiturasCompletas     = 'apoio_leituras_completas';
  static const String prefReviewPedidoMs        = 'apoio_review_pedido_ms';
  static const String prefApoioExposicoes       = 'apoio_exposicoes';
  static const String prefApoioMostradoMs       = 'apoio_mostrado_ms';
  static const String prefApoioCardDispensadoMs = 'apoio_card_dispensado_ms';
  static const String prefApoioFeedbackMs       = 'apoio_feedback_ms';
  static const String prefApoiou                = 'apoio_apoiou';
  static const String prefApoioNaoPerguntar     = 'apoio_nao_perguntar';

  /// Versão exibida em Ajustes.
  ///
  /// Fonte única: tem de bater com `version:` do pubspec.yaml. Não dá para ler
  /// do bundle (esta versão do Flutter não gera version.json nos assets) e ler
  /// via PackageInfo exigiria uma dependência nova só para isto — então o
  /// acordo é travado por teste: test/core/app_version_test.dart falha se o
  /// pubspec for bumpado e esta constante ficar para trás.
  static const String appVersion = '1.0.4';

  /// Site do app. As páginas de salmo existem em /salmos/{numero} e são
  /// App Links verificados: em quem tem o app, o link abre direto no salmo.
  static const String siteBaseUrl = 'https://omeusalmo.com.br';
  static String urlDoSalmo(int numero) => '$siteBaseUrl/salmos/$numero';
  static const String urlPrivacidade = '$siteBaseUrl/privacy_policy.html';

  /// applicationId do módulo Android (android/app/build.gradle.kts).
  /// Travado por teste: test/core/apoio/loja_link_test.dart.
  static const String androidPackageId = 'com.omeusalmo.salmos';

  /// Ficha da loja. `market://` abre o app da Play Store direto; a `https` é o
  /// plano B para aparelho sem Play Services (Huawei, ROM alternativa), onde o
  /// esquema `market` não resolve e o toque morreria em silêncio.
  static const String uriLojaNativa =
      'market://details?id=$androidPackageId';
  static const String urlLojaWeb =
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  /// E-mail de contato — sugestões e o ramo "Nem tanto" do sheet de apoio.
  static const String emailContato = 'omeusalmo@gmail.com';

  static const int defaultNotifHour   = 8;
  static const int defaultNotifMinute = 0;

  // Limites de UI
  static const double maxContentWidth = 680.0;
  static const double defaultPadding = 20.0;
}
