import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/analytics/analytics_service.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/notification_service.dart';
import 'core/firebase_options.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: app desenha atrás da status bar e nav bar do sistema.
  // SafeArea nos Scaffolds cuidam dos insets — sem sobreposição de conteúdo.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Guard: falha do plugin de notificação em algum device/OEM não pode
  // impedir o runApp — sem isto, uma exceção aqui = tela branca no launch.
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('[Notif] init falhou (seguindo sem notificação): $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AnalyticsService.instance.init();
    // Aplica a escolha de consentimento do usuário (onboarding/Ajustes) já no
    // launch. Padrão desligado até consentimento explícito (LGPD).
    final prefs = await SharedPreferences.getInstance();
    await AnalyticsService.instance.setCollectionEnabled(
      prefs.getBool(AppConstants.prefUsageDataEnabled) ?? false,
    );
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {}

  runApp(const ProviderScope(child: SalmosApp()));
}

class SalmosApp extends ConsumerWidget {
  const SalmosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Sincroniza ícones da status bar com o tema ativo.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp.router(
      title: 'O meu Salmo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Acessibilidade: honra o aumento de fonte do sistema, mas limita a
        // ampliação a 1.3x (o maior passo padrão do Android). Sem o teto,
        // fontes gigantes (ex.: modo "enorme" da Samsung) cortam e sobrepõem
        // texto em telas com espaçamento fixo (onboarding, grid emocional).
        final clamped =
            MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clamped),
          child: child!,
        );
      },
    );
  }
}
