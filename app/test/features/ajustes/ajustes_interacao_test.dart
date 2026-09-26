import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/constants/copy_apoio.dart';
import 'package:salmos_app/core/notifications/notification_service.dart';
import 'package:salmos_app/core/services/link_service.dart';
import 'package:salmos_app/features/ajustes/ajustes_screen.dart';
import 'package:salmos_app/shared/widgets/apoio_sheet.dart';

import '../../a11y/text_scale_harness.dart';
import '../../shared/fake_compra.dart';

/// Testes de COMPORTAMENTO da tela de Ajustes.
///
/// Existem porque a suíte anterior não distinguia a tela funcionando da tela
/// morta: ficava verde com o consentimento, o copiar e o enviar sugestão
/// desligados, e verde de novo com o card de notificação sem ação. Ver um
/// InkWell na árvore não prova nada — InkWell sem `onTap` também aparece.
///
/// Cada teste aqui toca de verdade e confere o EFEITO do toque.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  late _LinkFalso link;
  late _NotificacaoFalsa notificacao;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefUsageDataEnabled: false,
      AppConstants.prefNotificationEnabled: false,
      AppConstants.prefNotificationHour: 7,
      AppConstants.prefNotificationMinute: 0,
    });
    link = _LinkFalso();
    notificacao = _NotificacaoFalsa();
    LinkService.instance = link;
    NotificationService.instance = notificacao;
  });

  tearDown(() {
    LinkService.instance = LinkService();
    NotificationService.instance = NotificationService();
  });

  testWidgets('consentimento LGPD: tocar grava a escolha em disco',
      (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'lgpd', escala: 1.0, tamanho: _telaInteira);

    final antes = await SharedPreferences.getInstance();
    expect(antes.getBool(AppConstants.prefUsageDataEnabled), isFalse,
        reason: 'pré-condição: começa desligado');

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(
      (await SharedPreferences.getInstance())
          .getBool(AppConstants.prefUsageDataEnabled),
      isTrue,
      reason: 'O switch de consentimento não gravou. É opt-in de LGPD: se o '
          'toque não persiste, o app perde a escolha do usuário.',
    );
  });

  testWidgets('apoiar o app: tocar abre o sheet direto no valor',
      (tester) async {
    // Substituiu o teste da chave Pix: o Pix saiu do app no mesmo release em que
    // o Play Billing entrou. Duas formas de doar, uma por fora da loja, é o que a
    // política de pagamentos do Google não aceita.
    await renderizar(
      tester,
      const AjustesScreen(criarCompra: FakeCompraApoio.new),
      nome: 'apoio',
      escala: 1.0,
      tamanho: _telaInteira,
    );

    await tester.tap(find.text(CopyApoio.ajustesApoiar));
    await tester.pumpAndSettle();

    expect(find.byType(ApoioSheet), findsOneWidget);
    // Sem a pergunta de sentimento: quem tocou em "Apoiar o app" já respondeu.
    expect(find.text(CopyApoio.perguntaTitulo), findsNothing);
    // E o preço vem da loja, nunca de constante no app.
    expect(find.text('Apoiar com R\$ 10,00'), findsOneWidget);
  });

  testWidgets('avaliar na Play Store: tocar abre a ficha da loja',
      (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'avaliar', escala: 1.0, tamanho: _telaInteira);

    await tester.tap(find.text(CopyApoio.ajustesAvaliar));
    await tester.pumpAndSettle();

    expect(link.abertas, hasLength(1),
        reason: 'O único caminho manual até a avaliação não abriu nada.');
    expect(link.abertas.single.scheme, 'market',
        reason: 'market:// abre o app da Play Store direto; a https é o plano B '
            'de aparelho sem Play Services.');
  });

  testWidgets('Ajustes não oferece mais a chave Pix', (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'sem pix', escala: 1.0, tamanho: _telaInteira);

    expect(find.textContaining('PIX'), findsNothing);
    expect(find.text('Copiar'), findsNothing);
    // E o card de convencimento saiu junto: a linha já diz a mesma coisa.
    expect(find.text('Você usa. Gosta.'), findsNothing);
  });

  testWidgets('enviar sugestão: tocar abre o e-mail', (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'sugestao', escala: 1.0, tamanho: _telaInteira);

    await tester.tap(find.text('Enviar sugestão'));
    await tester.pumpAndSettle();

    expect(link.abertas, hasLength(1),
        reason: 'O toque em "Enviar sugestão" não tentou abrir nada.');
    expect(link.abertas.single.scheme, 'mailto');
    expect(link.abertas.single.path, 'omeusalmo@gmail.com');
  });

  testWidgets('política de privacidade: tocar abre o link externo',
      (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'privacidade', escala: 1.0, tamanho: _telaInteira);

    await tester.tap(find.text('Política de privacidade'));
    await tester.pumpAndSettle();

    expect(link.abertas, hasLength(1),
        reason: 'O item de maior exigência legal da tela não abriu nada.');
    expect(link.abertas.single.host, 'omeusalmo.com.br');
  });

  testWidgets('notificação: tocar no corpo do card liga e abre o horário',
      (tester) async {
    await renderizar(tester, const AjustesScreen(),
        nome: 'notificacao', escala: 1.0, tamanho: _telaInteira);

    // Toca no texto do card, longe do switch — é o comportamento que o achado
    // de campo pedia (a usuária tocou no rótulo e nada acontecia).
    await tester.tap(find.text('Um Salmo por dia, às 07:00'));
    await tester.pumpAndSettle();

    expect(notificacao.agendamentos, isNotEmpty,
        reason: 'Tocar no corpo do card não ligou a notificação.');
    expect(
      find.text('Horário do Salmo do dia'),
      findsOneWidget,
      reason: 'Ligou mas não abriu o seletor de horário. O card precisa fazer '
          'as duas coisas num toque só.',
    );
  });
}

const Size _telaInteira = Size(360, 2400);

class _LinkFalso extends LinkService {
  final List<Uri> abertas = [];

  @override
  Future<bool> abrir(Uri uri, {bool externo = false}) async {
    abertas.add(uri);
    return true;
  }
}

/// A permissão de notificação depende de plataforma nativa, que não existe sob
/// flutter test: o serviço real devolveria `false` e o card nunca ligaria.
class _NotificacaoFalsa extends NotificationService {
  final List<({int hora, int minuto})> agendamentos = [];
  bool cancelada = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> agendarJanela({
    required int hour,
    required int minute,
    required List<ItemAgenda> agenda,
  }) async {
    agendamentos.add((hora: hour, minuto: minute));
  }

  @override
  Future<void> cancelarJanela() async {
    cancelada = true;
  }
}
