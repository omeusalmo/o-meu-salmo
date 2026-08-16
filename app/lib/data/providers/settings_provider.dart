import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/constants/app_constants.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeModeKey);
    if (saved == null) return;
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    state = mode;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeModeKey, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ─── Notificação do Salmo do dia ─────────────────────────────────────────────

class NotificationSettingsNotifier
    extends Notifier<({bool enabled, int hour, int minute})> {
  @override
  ({bool enabled, int hour, int minute}) build() {
    _load();
    return (
      enabled: false,
      hour: AppConstants.defaultNotifHour,
      minute: AppConstants.defaultNotifMinute,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(AppConstants.prefNotificationEnabled) ?? false;
    final hour    = prefs.getInt(AppConstants.prefNotificationHour)    ?? AppConstants.defaultNotifHour;
    final minute  = prefs.getInt(AppConstants.prefNotificationMinute)  ?? AppConstants.defaultNotifMinute;
    state = (enabled: enabled, hour: hour, minute: minute);
  }

  Future<void> setEnabled(bool value, {int? hour, int? minute}) async {
    final h = hour   ?? state.hour;
    final m = minute ?? state.minute;
    state = (enabled: value, hour: h, minute: m);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefNotificationEnabled, value);
    await prefs.setInt(AppConstants.prefNotificationHour, h);
    await prefs.setInt(AppConstants.prefNotificationMinute, m);
  }

  Future<void> setTime(int hour, int minute) async {
    state = (enabled: state.enabled, hour: hour, minute: minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefNotificationHour, hour);
    await prefs.setInt(AppConstants.prefNotificationMinute, minute);
  }
}

final notificationSettingsProvider = NotifierProvider<
    NotificationSettingsNotifier,
    ({bool enabled, int hour, int minute})>(NotificationSettingsNotifier.new);

// ─── Dados de uso (opt-in de Analytics/Crashlytics, LGPD) ────────────────────

/// Consentimento de coleta de dados de uso. Padrão desligado; o usuário liga
/// explicitamente na tela de consentimento do onboarding (ou depois em
/// Ajustes). A escolha é aplicada ao Firebase e persistida.
class UsageDataNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(AppConstants.prefUsageDataEnabled) ?? false;
    state = enabled;
    await AnalyticsService.instance.setCollectionEnabled(enabled);
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefUsageDataEnabled, value);
    await AnalyticsService.instance.setCollectionEnabled(value);
  }
}

final usageDataProvider =
    NotifierProvider<UsageDataNotifier, bool>(UsageDataNotifier.new);
