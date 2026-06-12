import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

// ─── Notificação diária ──────────────────────────────────────────────────────

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
