class AppConstants {
  AppConstants._();

  static const String appName = 'Salmos';
  static const String salmosJsonPath = 'assets/salmos.json';

  // Chaves SharedPreferences
  static const String prefFavoritosKey = 'favoritos_numeros';
  static const String prefThemeModeKey = 'theme_mode';
  static const String prefFontScaleKey = 'font_scale';
  static const String prefNotificationEnabled = 'notif_enabled';
  static const String prefNotificationHour   = 'notif_hour';
  static const String prefNotificationMinute = 'notif_minute';

  static const int defaultNotifHour   = 8;
  static const int defaultNotifMinute = 0;

  // Limites de UI
  static const double maxContentWidth = 680.0;
  static const double defaultPadding = 20.0;
}
