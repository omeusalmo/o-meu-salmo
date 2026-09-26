import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_service.dart';
import 'package:salmos_app/core/constants/copy_apoio.dart';
import 'package:salmos_app/core/theme/app_theme.dart';
import 'package:salmos_app/features/ajustes/ajustes_screen.dart';
import 'package:salmos_app/shared/widgets/apoio_card.dart';
import 'package:salmos_app/shared/widgets/apoio_sheet.dart';

import '../shared/fake_compra.dart';
import 'text_scale_harness.dart';

/// Um botão anunciado é um botão acionável.
///
/// O BUG que este arquivo existe para impedir de voltar:
///
///     Semantics(
///       label: 'Dispensar',
///       button: true,
///       excludeSemantics: true,   // ← aqui
///       child: InkWell(onTap: ...),
///     )
///
/// `excludeSemantics: true` apaga a subárvore do filho — e a ação de toque do
/// InkWell mora nessa subárvore. O nó sobrevive com o rótulo e a flag de botão,
/// sem `SemanticsAction.tap`. O TalkBack anuncia "Dispensar, botão", a pessoa dá
/// o duplo toque e nada acontece. Para quem navega por leitor de tela o controle
/// simplesmente não existe, e nada na tela denuncia isso.
///
/// O padrão certo é `MergeSemantics` + `Semantics(button: true)` SEM exclusão: o
/// rótulo vem do conteúdo e a ação continua de pé.
///
/// `excludeSemantics` continua correto em cima de coisa que NÃO é tocável — é
/// como o eyebrow evita que o TalkBack soletre a caixa alta. O teste abaixo só
/// cobra quem se declara botão.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApoioService.instance = ApoioService();
    ligarLojaFalsa();
  });

  tearDown(desligarLojaFalsa);

  testWidgets('sheet de apoio: pergunta e link de saída definitiva',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(const ApoioSheetDeTeste()));
    await tester.pumpAndSettle();

    expect(find.text(CopyApoio.naoPerguntarMais), findsOneWidget,
        reason: 'pré-condição: o link da terceira exibição está na tela');
    expect(_botoesSemAcao(tester), isEmpty);

    handle.dispose();
  });

  testWidgets('sheet de apoio: passo do valor', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(const ApoioSheetDeTeste(comPergunta: false)));
    await tester.pumpAndSettle();

    expect(find.text('R\$ 10,00'), findsOneWidget,
        reason: 'pré-condição: a lista de valores está na tela');
    expect(_botoesSemAcao(tester), isEmpty);

    handle.dispose();
  });

  testWidgets('card da Home', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(ApoioCardHome(
      onDispensar: () {},
      criarCompra: FakeCompraApoio.new,
    )));
    await tester.pumpAndSettle();

    // O X do card é a ocorrência original do bug.
    expect(
      tester.getSemantics(find.byIcon(Icons.close_rounded)),
      matchesSemantics(
        label: CopyApoio.cardDispensar,
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(_botoesSemAcao(tester), isEmpty);

    handle.dispose();
  });

  testWidgets('tela de Ajustes inteira', (tester) async {
    final handle = tester.ensureSemantics();
    await renderizar(
      tester,
      const AjustesScreen(),
      nome: 'ajustes acionavel',
      escala: 1.0,
      tamanho: const Size(360, 1500),
    );

    expect(_botoesSemAcao(tester), isEmpty);
    handle.dispose();
  });
}

/// Rótulo de todo nó que se diz botão e não tem ação de toque. Vazio = certo.
List<String> _botoesSemAcao(WidgetTester tester) {
  final falhas = <String>[];

  void visitar(SemanticsNode no) {
    final dados = no.getSemanticsData();
    if (dados.flagsCollection.isButton &&
        !dados.hasAction(SemanticsAction.tap)) {
      falhas.add('"${dados.label}" (botão sem ação de toque — '
          'excludeSemantics em cima de um tocável?)');
    }
    no.visitChildren((filho) {
      visitar(filho);
      return true;
    });
  }

  // Sobe até a raiz a partir de um nó qualquer da tela: `pipelineOwner` está
  // deprecado e a árvore de semântica não tem outro ponto de entrada estável.
  var raiz = tester.getSemantics(find.byType(Scaffold).first);
  while (raiz.parent != null) {
    raiz = raiz.parent!;
  }
  visitar(raiz);
  return falhas;
}

Widget _app(Widget corpo) => MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppTheme.sp5),
          child: corpo,
        ),
      ),
    );

/// O sheet montado direto, sem passar pelo modal: o que está sob teste aqui é a
/// semântica dos controles, não a rota.
class ApoioSheetDeTeste extends StatelessWidget {
  final bool comPergunta;
  const ApoioSheetDeTeste({super.key, this.comPergunta = true});

  @override
  Widget build(BuildContext context) => ApoioSheet(
        comPergunta: comPergunta,
        compra: FakeCompraApoio(),
        ultimaExibicao: true,
      );
}
