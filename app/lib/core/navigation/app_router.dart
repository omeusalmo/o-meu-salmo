import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../analytics/analytics_service.dart';

import '../extensions/build_context_extensions.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/colecoes/colecoes_screen.dart';
import '../../features/colecoes/detalhe_colecao_screen.dart';
import '../../features/salmos/todos_salmos_screen.dart';
import '../../features/salmos/leitura_salmo_screen.dart';
import '../../features/favoritos/favoritos_screen.dart';
import '../../features/compositor/compositor_screen.dart';
import '../../features/ajustes/ajustes_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/respirar/respirar_screen.dart';
import '../../shared/widgets/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  // screen_view automático nas 11 telas. Respeita o opt-out: se a coleta
  // estiver desligada o SDK descarta o evento, não há gate a fazer aqui.
  observers: AnalyticsService.instance.observers,
  // Rota desconhecida (ex.: deep link inválido) cai numa tela com saída,
  // nunca na tela de erro crua do go_router.
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: context.colorBg,
    body: SafeArea(
      child: ErrorStateView(
        titulo: 'Página não encontrada',
        mensagem: 'O link que você abriu não existe ou saiu do ar.',
        icon: Icons.explore_off_outlined,
        acaoLabel: 'Voltar ao início',
        onAcao: () => context.go('/home'),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/colecoes',
            name: 'colecoes',
            builder: (_, __) => const ColecoesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'colecao_detalhe',
                pageBuilder: (_, state) => _fadeSlide(
                  state,
                  DetalheColecaoScreen(
                    colecaoId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/salmos',
            name: 'salmos',
            builder: (_, __) => const TodosSalmosScreen(),
            routes: [
              GoRoute(
                path: ':numero',
                name: 'leitura_salmo',
                pageBuilder: (_, state) => _fadeSlide(
                  state,
                  LeituraSalmoScreen(
                    numero: int.tryParse(state.pathParameters['numero']!) ?? 1,
                  ),
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/favoritos',
            name: 'favoritos',
            builder: (_, __) => const FavoritosScreen(),
          ),
        ]),
      ],
    ),

    // Rotas modais — deslizam de baixo para cima
    GoRoute(
      path: '/compositor',
      name: 'compositor',
      pageBuilder: (_, state) {
        final n = int.tryParse(state.uri.queryParameters['numero'] ?? '') ?? 0;
        return _slideUp(state, CompositorScreen(numero: n));
      },
    ),
    GoRoute(
      path: '/ajustes',
      name: 'ajustes',
      pageBuilder: (_, state) => _slideUp(state, const AjustesScreen()),
    ),
    GoRoute(
      path: '/respirar',
      name: 'respirar',
      pageBuilder: (_, state) => _slideUp(state, const RespirarScreen()),
    ),
  ],
);

// Transição suave para push dentro de aba: fade + leve subida
CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      // Sem name o FirebaseAnalyticsObserver ignora a tela: era por isso que
      // leitura de salmo e detalhe de coleção nunca apareciam no screen_view.
      name: state.name ?? state.path,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.035),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );

// Transição modal: desliza de baixo para cima
CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      // Sem name o FirebaseAnalyticsObserver ignora a tela: era por isso que
      // leitura de salmo e detalhe de coleção nunca apareciam no screen_view.
      name: state.name ?? state.path,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
