import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:salmos_app/core/navigation/app_router.dart';

/// O FirebaseAnalyticsObserver lê `RouteSettings.name`, que o go_router
/// resolve como `state.name ?? state.path`. Uma rota sem `name` chega ao
/// Analytics como ':numero' ou, se a página for CustomTransitionPage sem
/// `name`, como null — e aí o evento simplesmente não sai.
///
/// Era exatamente isso: `unifiedScreenName` vinha `(not set)` para 108 dos
/// 110 usuários medidos. Este teste existe para a falha não voltar calada.
void main() {
  List<GoRoute> achatar(List<RouteBase> rotas) => [
        for (final r in rotas) ...[
          if (r is GoRoute) r,
          ...achatar(r.routes),
        ],
      ];

  test('toda rota tem name, senão o screen_view sai vazio', () {
    final rotas = achatar(appRouter.configuration.routes);

    expect(rotas, isNotEmpty, reason: 'nenhuma rota encontrada');

    final semNome = rotas.where((r) => r.name == null).map((r) => r.path);
    expect(semNome, isEmpty,
        reason: 'rotas sem name não aparecem no screen_view: $semNome');

    final nomes = rotas.map((r) => r.name!).toList();
    expect(nomes.toSet().length, nomes.length,
        reason: 'nomes repetidos misturam telas diferentes: $nomes');
  });

  test('nomes são legíveis, não padrões de rota', () {
    for (final r in achatar(appRouter.configuration.routes)) {
      expect(r.name, isNot(startsWith(':')),
          reason: '${r.path} usaria o padrão da URL como nome de tela');
      expect(r.name, isNot(contains('/')), reason: '${r.path} tem nome com barra');
    }
  });
}
