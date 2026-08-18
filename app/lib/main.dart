import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // O app é offline: as fontes vêm de assets/fonts, declaradas no pubspec.
  // Com a busca em runtime ligada, um peso que faltasse no bundle seria
  // baixado escondido em desenvolvimento e apareceria como fonte do sistema
  // na mão de quem instala sem rede.
  //
  // O que garante que a falta seja notada NÃO é esta linha: é o
  // test/a11y/fontes_offline_test.dart, que reprova o build antes de subir.
  // Aqui, em produção, a falta degrada para a fonte do sistema e é registrada
  // como não fatal (ver o handler de erro mais abaixo).
  GoogleFonts.config.allowRuntimeFetching = false;

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
      // Falha de fonte não é queda do app: o texto continua legível na fonte
      // do sistema. E o google_fonts limpa o cache a cada erro, então ele
      // tenta de novo a cada rebuild — como fatal, uma única fonte faltando
      // geraria centenas de registros por sessão e afundaria a taxa de
      // "usuários sem falhas" da Play sem nada ter quebrado de fato.
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: !_ehFalhaDeFonte(error),
      );
      return true;
    };
  } catch (_) {}

  runApp(const ProviderScope(child: SalmosApp()));
}

/// Erro do google_fonts ao não achar uma família nos assets.
///
/// Casa pela mensagem porque o pacote lança `Exception` genérica, sem tipo
/// próprio (google_fonts 8.1.0, google_fonts_base.dart:176).
bool _ehFalhaDeFonte(Object error) {
  final texto = error.toString();
  return texto.contains('allowRuntimeFetching') ||
      texto.contains('was not found in the application assets');
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
        // Acessibilidade: honra o aumento de fonte do sistema até 2.0x, que é
        // o que as diretrizes do Android esperam e o que o público do app
        // (60–75 anos, presbiopia) costuma pedir — a Samsung chega a "Enorme".
        //
        // O teto existe só para não deixar a escala crescer sem limite em
        // acessibilidade extrema. Telas que não aguentam 2.0x se protegem
        // sozinhas com MediaQuery.withClampedTextScaling (hoje: as duas
        // primeiras do onboarding). Clamp é destrutivo: se cortássemos aqui,
        // nenhuma tela abaixo conseguiria recuperar a escala que o usuário
        // pediu — por isso o teto é alto aqui e baixo só onde precisa.
        //
        // Coberto por test/a11y/text_scale_test.dart.
        final clamped =
            MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2.0);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clamped),
          child: child!,
        );
      },
    );
  }
}
