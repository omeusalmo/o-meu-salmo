import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:salmos_app/core/notifications/notification_service.dart';

/// O Salmo do dia é o mecanismo de retenção do app, e ele estava disparando no
/// horário errado.
///
/// `tz.initializeTimeZones()` sozinho deixa `tz.local` em UTC: o próprio
/// `initializeDatabase` faz `_local = _UTC` (timezone 0.9.4, src/env.dart:53).
/// Como o agendamento monta o horário com `tz.TZDateTime(tz.local, ...)`, quem
/// escolhia 08:00 recebia 08:00 UTC, que em Brasília é 05:00.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// O plugin nativo de notificação não sobe sob flutter test e o `init`
  /// estoura ao registrar o canal. O que interessa aqui acontece antes disso,
  /// na primeira linha do método: a resolução do fuso.
  Future<void> iniciarIgnorandoPluginNativo() async {
    try {
      await NotificationService.instance.init();
    } catch (_) {}
  }

  test('init resolve o fuso do aparelho, não deixa em UTC', () async {
    await iniciarIgnorandoPluginNativo();

    expect(tz.local.name, isNot('UTC'),
        reason: 'tz.local ficou em UTC. Todo agendamento sai deslocado pela '
            'diferença de fuso do aparelho.');
  });

  test('o horário agendado bate com o horário do aparelho', () async {
    await iniciarIgnorandoPluginNativo();

    // 08:00 no fuso resolvido tem de ser o mesmo instante que 08:00 no relógio
    // do aparelho. Se tz.local estiver errado, os dois divergem.
    final noAparelho = DateTime(2026, 3, 15, 8);
    final agendado = tz.TZDateTime(tz.local, 2026, 3, 15, 8);

    expect(
      agendado.toUtc().difference(noAparelho.toUtc()),
      Duration.zero,
      reason: 'Diferença de ${agendado.toUtc().difference(noAparelho.toUtc()).inHours}h '
          'entre o que o usuário escolheu e o que seria agendado.',
    );
  });
}
