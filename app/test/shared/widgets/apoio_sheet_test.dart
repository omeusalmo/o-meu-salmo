import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_service.dart';
import 'package:salmos_app/core/apoio/compra_service.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/constants/copy_apoio.dart';
import 'package:salmos_app/core/services/link_service.dart';
import 'package:salmos_app/core/theme/app_theme.dart';
import 'package:salmos_app/shared/widgets/apoio_sheet.dart';

import '../fake_compra.dart';

/// Comportamento do sheet de apoio, estado por estado.
///
/// O que estes testes protegem, além do óbvio:
/// • o preço NUNCA é escrito no app — sai da loja e chega intacto ao botão;
/// • nenhum ramo leva à Play Store (a política da In-App Review proíbe
///   perguntar opinião antes do prompt, e "Tem sim" + avaliar é exatamente isso);
/// • "Nada foi cobrado" só aparece quando é verdade.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late _LinkFalso link;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApoioService.instance = ApoioService();
    link = _LinkFalso();
    LinkService.instance = link;
  });

  tearDown(() => LinkService.instance = LinkService());

  // ───────────────────────────────────────────────────────────────────────────
  // 1 · Pergunta
  // ───────────────────────────────────────────────────────────────────────────

  testWidgets('a pergunta oferece três saídas e nenhuma leva à loja',
      (tester) async {
    await _abrir(tester, comPergunta: true);

    expect(find.text(CopyApoio.perguntaTitulo), findsOneWidget);
    expect(find.text(CopyApoio.perguntaSim), findsOneWidget);
    expect(find.text(CopyApoio.perguntaNao), findsOneWidget);
    expect(find.text(CopyApoio.agoraNao), findsOneWidget);

    // Nem no texto visível: um botão "Avaliar" aqui seria o filtro de nota que
    // a política do Google Play proíbe.
    expect(find.textContaining('Avaliar'), findsNothing);
    expect(find.textContaining('Play Store'), findsNothing);
  });

  testWidgets('"Agora não" fecha o sheet', (tester) async {
    await _abrir(tester, comPergunta: true);
    await tester.tap(find.text(CopyApoio.agoraNao));
    await tester.pumpAndSettle();
    expect(find.byType(ApoioSheet), findsNothing);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 2 · Valores
  // ───────────────────────────────────────────────────────────────────────────

  group('passo do valor', () {
    testWidgets('"Tem sim" leva à lista com R\$ 10 pré-selecionado',
        (tester) async {
      await _abrir(tester, comPergunta: true);
      await tester.tap(find.text(CopyApoio.perguntaSim));
      await tester.pumpAndSettle();

      expect(find.text(CopyApoio.apoioTitulo), findsOneWidget);
      for (final preco in ['R\$ 5,00', 'R\$ 10,00', 'R\$ 25,00']) {
        expect(find.text(preco), findsOneWidget);
      }
      // O rótulo do botão prova a origem do preço: se alguém hardcodear "R$ 10"
      // num widget, este texto deixa de casar com o da loja falsa.
      expect(find.text('Apoiar com R\$ 10,00'), findsOneWidget);
    });

    testWidgets('a lista é lista, nunca colunas iguais', (tester) async {
      // Três colunas iguais truncam "R$ 25" com a fonte do sistema em 2.0x. A
      // regra do DS é explícita: uma linha por valor, alvo na largura inteira.
      await _abrir(tester, comPergunta: false);

      final larguras = <double>{};
      for (final preco in ['R\$ 5,00', 'R\$ 10,00', 'R\$ 25,00']) {
        final alvo = find
            .ancestor(of: find.text(preco), matching: find.byType(InkWell))
            .first;
        final t = tester.getSize(alvo);
        expect(t.height, greaterThanOrEqualTo(48.0),
            reason: 'A linha de $preco tem ${t.height}dp de alvo.');
        larguras.add(t.width);
      }
      // Mesma largura para as três E largura de linha inteira: é lista, não três
      // botões lado a lado.
      expect(larguras, hasLength(1));
      expect(larguras.single, greaterThan(200));
    });

    testWidgets('cada valor se anuncia como escolha exclusiva no TalkBack',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _abrir(tester, comPergunta: false);

      expect(
        tester.getSemantics(find.text('R\$ 10,00')),
        matchesSemantics(
          label: 'R\$ 10,00',
          isButton: true,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('trocar o valor troca o rótulo do botão', (tester) async {
      await _abrir(tester, comPergunta: false);

      await tester.tap(find.text('R\$ 25,00'));
      await tester.pumpAndSettle();

      expect(find.text('Apoiar com R\$ 25,00'), findsOneWidget);
      expect(find.text('Apoiar com R\$ 10,00'), findsNothing);
    });

    testWidgets('a nota de pagamento usa a cor de texto, nunca a muted',
        (tester) async {
      // Muted sobre a superfície dá 4.53:1 — passa raspando, e o público tem
      // 60 a 75 anos.
      await _abrir(tester, comPergunta: false);

      final estilo = tester.widget<Text>(find.text(CopyApoio.apoioNota)).style!;
      expect(estilo.color, AppColors.nightText);
      expect(estilo.color, isNot(AppColors.nightMuted));
      // Texto de decisão: diz o que a pessoa recebe pelo dinheiro.
      expect(estilo.fontSize, greaterThanOrEqualTo(14.0));
    });

    testWidgets('sem produto na loja cai no erro, dizendo que nada foi cobrado',
        (tester) async {
      await _abrir(
        tester,
        comPergunta: false,
        compra: FakeCompraApoio(lista: const []),
      );

      expect(find.text(CopyApoio.erroTitulo), findsOneWidget);
      // E aqui a frase é verdade: o fluxo nem chegou perto da cobrança.
      expect(find.text(CopyApoio.erroCorpoNadaCobrado), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 3 · Desfechos
  // ───────────────────────────────────────────────────────────────────────────

  group('desfechos da compra', () {
    testWidgets('compra concluída agradece e marca que a pessoa apoiou',
        (tester) async {
      final compra = FakeCompraApoio();
      await _abrir(tester, comPergunta: false, compra: compra);

      await tester.tap(find.text('Apoiar com R\$ 10,00'));
      await tester.pumpAndSettle();

      expect(compra.comprados, ['apoio_10']);
      expect(find.text(CopyApoio.obrigadoTitulo), findsOneWidget);
      expect(find.text(CopyApoio.obrigadoCorpo), findsOneWidget);

      final p = await SharedPreferences.getInstance();
      expect(p.getBool(AppConstants.prefApoiou), isTrue,
          reason: 'Quem apoiou não pode voltar a ver card nem sheet.');
    });

    testWidgets('cancelar mostra aviso sobre o sheet, sem abrir painel novo',
        (tester) async {
      await _abrir(
        tester,
        comPergunta: false,
        compra: FakeCompraApoio(
          resultado: const ResultadoCompra(ResultadoApoio.cancelado),
        ),
      );

      await tester.tap(find.text('Apoiar com R\$ 10,00'));
      await tester.pumpAndSettle();

      expect(find.text(CopyApoio.canceladoSnack), findsOneWidget);
      // Cancelar não é erro: a lista de valores continua ali atrás.
      expect(find.text(CopyApoio.erroTitulo), findsNothing);
      expect(find.text('Apoiar com R\$ 10,00'), findsOneWidget);

      // Drena o timer que esconde o aviso.
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('erro sem garantia NÃO afirma que nada foi cobrado',
        (tester) async {
      // Pendência do Billing, compra anterior não consumida e falha genérica
      // podem ter debitado. Dizer "nada foi cobrado" ali é mentir para quem
      // acabou de ver a fatura.
      await _abrir(
        tester,
        comPergunta: false,
        compra: FakeCompraApoio(
          resultado: const ResultadoCompra(
            ResultadoApoio.erroIndeterminado,
            codigo: 'pendente',
          ),
        ),
      );

      await tester.tap(find.text('Apoiar com R\$ 10,00'));
      await tester.pumpAndSettle();

      expect(find.text(CopyApoio.erroTitulo), findsOneWidget);
      expect(find.text(CopyApoio.erroCorpoNeutro), findsOneWidget);
      expect(find.textContaining('Nada foi cobrado'), findsNothing);
    });

    testWidgets('erro antes da cobrança pode afirmar que nada foi cobrado',
        (tester) async {
      await _abrir(
        tester,
        comPergunta: false,
        compra: FakeCompraApoio(
          resultado: const ResultadoCompra(
            ResultadoApoio.erroNadaCobrado,
            codigo: 'nao_lancou',
          ),
        ),
      );

      await tester.tap(find.text('Apoiar com R\$ 10,00'));
      await tester.pumpAndSettle();

      expect(find.text(CopyApoio.erroCorpoNadaCobrado), findsOneWidget);
      expect(find.text(CopyApoio.erroTentarNovamente), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 2b · Ramo "Nem tanto"
  // ───────────────────────────────────────────────────────────────────────────

  group('ramo "Nem tanto"', () {
    testWidgets('vai para o e-mail e cala o pedido por 90 dias',
        (tester) async {
      await _abrir(tester, comPergunta: true);
      await tester.tap(find.text(CopyApoio.perguntaNao));
      await tester.pumpAndSettle();

      expect(find.text(CopyApoio.feedbackTitulo), findsOneWidget);
      expect(find.text(CopyApoio.feedbackCorpo), findsOneWidget);
      // Nenhum caminho daqui leva à loja: quem reclamou não é convidado a dar
      // nota.
      expect(find.textContaining('Play Store'), findsNothing);

      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefApoioFeedbackMs), isNotNull);

      await tester.tap(find.text(CopyApoio.feedbackCta));
      await tester.pumpAndSettle();

      expect(link.abertas, hasLength(1));
      expect(link.abertas.single.scheme, 'mailto');
      expect(link.abertas.single.path, AppConstants.emailContato);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // A regra que atravessa tudo
  // ───────────────────────────────────────────────────────────────────────────

  for (final caminho in [CopyApoio.perguntaSim, CopyApoio.perguntaNao]) {
    testWidgets('o ramo "$caminho" não abre a Play Store', (tester) async {
      await _abrir(tester, comPergunta: true);
      await tester.tap(find.text(caminho));
      await tester.pumpAndSettle();

      expect(
        link.abertas.where(
          (u) => u.scheme == 'market' || u.host.contains('play.google'),
        ),
        isEmpty,
        reason: 'Nenhum ramo do sheet pode levar à loja: a política da In-App '
            'Review proíbe filtrar quem vê o prompt por opinião.',
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Abre o sheet dentro de um app mínimo e espera a loja falsa responder.
Future<void> _abrir(
  WidgetTester tester, {
  required bool comPergunta,
  CompraApoio? compra,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => mostrarApoioSheet(
              context,
              comPergunta: comPergunta,
              compra: compra ?? FakeCompraApoio(),
              origem: 'teste',
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

class _LinkFalso extends LinkService {
  final List<Uri> abertas = [];

  @override
  Future<bool> abrir(Uri uri, {bool externo = false}) async {
    abertas.add(uri);
    return true;
  }
}
