import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/analytics/analytics_service.dart';
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

  await NotificationService.instance.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AnalyticsService.instance.init();
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
    );
  }
}
