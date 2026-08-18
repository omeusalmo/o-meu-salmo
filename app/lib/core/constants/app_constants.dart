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
  static const String prefReviewRequested    = 'review_requested';

  /// Versão exibida em Ajustes.
  ///
  /// Fonte única: tem de bater com `version:` do pubspec.yaml. Não dá para ler
  /// do bundle (esta versão do Flutter não gera version.json nos assets) e ler
  /// via PackageInfo exigiria uma dependência nova só para isto — então o
  /// acordo é travado por teste: test/core/app_version_test.dart falha se o
  /// pubspec for bumpado e esta constante ficar para trás.
  static const String appVersion = '1.0.2';

  static const int defaultNotifHour   = 8;
  static const int defaultNotifMinute = 0;

  // Limites de UI
  static const double maxContentWidth = 680.0;
  static const double defaultPadding = 20.0;
}
