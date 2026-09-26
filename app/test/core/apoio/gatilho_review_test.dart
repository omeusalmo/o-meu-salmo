import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_service.dart';
import 'package:salmos_app/core/apoio/elegibilidade.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/review/review_service.dart';
import 'package:salmos_app/features/salmos/leitura_salmo_screen.dart';

import '../../a11y/text_scale_harness.dart';
import '../../shared/fake_compra.dart';

/// O conserto do gatilho de avaliação.
///
/// O bug: `leitura_salmo_screen.dart` agendava `maybeRequestReview()` num
/// `Future.delayed(10s)` dentro do `initState`. Dez segundos depois de abrir um
/// Salmo — com a pessoa lendo, e sem olhar de qual coleção — o prompt da loja
/// aparecia por cima do texto. Inclusive em Luto.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  late _ReviewFalso review;

  setUp(() {
    review = _ReviewFalso();
    ReviewService.instance = review;
    ApoioService.instance = ApoioService();
    ligarLojaFalsa();
  });

  tearDown(() {
    ReviewService.instance = ReviewService();
    desligarLojaFalsa();
  });

  // ───────────────────────────────────────────────────────────────────────────
  // A regressão
  // ───────────────────────────────────────────────────────────────────────────

  testWidgets('REGRESSÃO: ler um Salmo não pede avaliação no meio da leitura',
      (tester) async {
    // Estado em que a avaliação É devida — para o teste provar que o app se
    // segura por CAUSA do momento, e não por falta de elegibilidade.
    SharedPreferences.setMockInitialValues({
      AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
      AppConstants.prefLeiturasCompletas: 30,
      AppConstants.prefReviewSessionCount: 10,
    });
    await ApoioService.instance.iniciarSessao();

    // `renderizar` já avança o relógio em 11 segundos — o timer antigo era de 10.
    await renderizar(
      tester,
      const LeituraSalmoScreen(numero: 23),
      nome: 'leitura sem pedido',
      escala: 1.0,
    );

    expect(review.pedidos, 0,
        reason: 'O pedido de avaliação voltou para dentro da leitura. Nada pode '
            'interromper o Salmo — é o motivo de a pessoa ter aberto o app.');
  });

  testWidgets('sair da leitura avisa o serviço de apoio', (tester) async {
    // O piso de 15 segundos é medido no relógio de parede, que o `pump` do
    // teste não adianta — então o que se prova aqui é a ligação, não o piso.
    // O piso em si está coberto em elegibilidade_test.dart.
    final apoio = _ApoioFalso();
    ApoioService.instance = apoio;
    SharedPreferences.setMockInitialValues({});

    await renderizar(tester, const LeituraSalmoScreen(numero: 23),
        nome: 'leitura avisa', escala: 1.0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(apoio.leituras, hasLength(1),
        reason: 'A saída da leitura parou de alimentar o contador. Sem ele, nem '
            'a avaliação nem o apoio chegam a ser devidos algum dia.');
  });

  group('coleção sensível, com o catálogo de produção', () {
    /// Salmo 22 está em "No Luto e na Dor". Salmo 8, em "Alegria e Louvor" e em
    /// nenhuma das três sensíveis.
    Future<bool> ehSensivel(WidgetTester tester, int numero) async {
      final apoio = _ApoioFalso();
      ApoioService.instance = apoio;
      SharedPreferences.setMockInitialValues({});

      await renderizar(tester, LeituraSalmoScreen(numero: numero),
          nome: 'sensivel $numero', escala: 1.0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      return apoio.leituras.single.sensivel;
    }

    testWidgets('Salmo de Luto chega marcado', (tester) async {
      expect(await ehSensivel(tester, 22), isTrue);
    });

    testWidgets('Salmo de Louvor não', (tester) async {
      expect(await ehSensivel(tester, 8), isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // O gatilho novo
  // ───────────────────────────────────────────────────────────────────────────

  group('na volta à Home', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
        AppConstants.prefLeiturasCompletas: 5,
        AppConstants.prefReviewSessionCount: 9,
      });
    });

    test('sem leitura nenhuma, não há o que avaliar', () async {
      await ApoioService.instance.iniciarSessao();
      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
      expect(review.pedidos, 0);
    });

    test('depois de uma leitura concluída, pede — uma vez só', () async {
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.review);
      expect(review.pedidos, 1);

      // Segunda volta à Home sem leitura nova: nada.
      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
      expect(review.pedidos, 1);

      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefReviewPedidoMs), isNotNull,
          reason: 'Sem a data gravada, a trava de 120 dias não existe.');
    });

    test('Salmo de coleção sensível não gera pedido', () async {
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: true,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
      expect(review.pedidos, 0);
      // Mas a leitura conta: quem lê Luto continua caminhando para o gatilho.
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefLeiturasCompletas), 6);
    });

    test('a coleção sensível cala a sessão inteira, não só aquela leitura',
        () async {
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: true,
      );
      await ApoioService.instance.aoVoltarParaHome();

      // Agora um Salmo qualquer, na mesma sessão. Quem acabou de ler sobre luto
      // não vira público de pedido porque o Salmo seguinte era de louvor.
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );
      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
      expect(review.pedidos, 0);
    });

    test('o Respirar também cala a sessão', () async {
      await ApoioService.instance.iniciarSessao();
      ApoioService.instance.marcarRespirar();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
    });

    test('abertura pela notificação cala a sessão', () async {
      await ApoioService.instance.iniciarSessao();
      ApoioService.instance.marcarAberturaPorNotificacao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
    });

    test('a primeira sessão da instalação nunca pede nada', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
        AppConstants.prefLeiturasCompletas: 30,
      });
      await ApoioService.instance.iniciarSessao();
      expect(ApoioService.instance.primeiraSessao, isTrue);

      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );
      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
    });

    test('loja indisponível não queima a trava de 120 dias', () async {
      // Sem Play Services ou com a cota do Google estourada, o prompt não
      // aparece. Gravar a data ali custaria quatro meses de silêncio por um
      // pedido que ninguém viu.
      review.disponivelRetorna = false;
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefReviewPedidoMs), isNull);
    });

    test('a narração concluída sozinha também vale como evento', () async {
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: false,
        audioConcluido: true,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.review);
      // Mas não conta como leitura: ouvir com o telefone no bolso não é leitura.
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefLeiturasCompletas), 5);
    });
  });

  test('o sheet de apoio gasta uma das três exposições da vida', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
      AppConstants.prefLeiturasCompletas: 20,
      AppConstants.prefReviewPedidoMs: _diasAtras(20),
      AppConstants.prefReviewSessionCount: 9,
    });
    await ApoioService.instance.iniciarSessao();
    await ApoioService.instance.registrarLeitura(
      leituraConcluida: true,
      audioConcluido: false,
      sensivel: false,
    );

    expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.apoio);

    final p = await SharedPreferences.getInstance();
    expect(p.getInt(AppConstants.prefApoioExposicoes), 1);
    expect(p.getInt(AppConstants.prefApoioMostradoMs), isNotNull);
    expect(review.pedidos, 0,
        reason: 'Avaliação e apoio nunca na mesma volta à Home.');
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Loja sem produto: as entradas somem em vez de levar ao erro
  // ───────────────────────────────────────────────────────────────────────────

  group('loja que não responde', () {
    /// Estado em que TUDO de apoio é devido. O único motivo para não aparecer é
    /// a loja.
    void semearEstadoDeApoio() {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
        AppConstants.prefLeiturasCompletas: 20,
        AppConstants.prefReviewPedidoMs: _diasAtras(20),
        AppConstants.prefReviewSessionCount: 9,
      });
    }

    test('o sheet não dispara, e não gasta uma exposição da vida', () async {
      ligarLojaVazia();
      semearEstadoDeApoio();
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );

      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.nenhum);

      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefApoioExposicoes), isNull,
          reason: 'Pedido que não apareceu não pode gastar uma das 3 da vida.');
      expect(p.getInt(AppConstants.prefApoioMostradoMs), isNull,
          reason: 'Nem a trava de 90 dias.');
    });

    test('o card da Home não aparece', () async {
      ligarLojaVazia();
      semearEstadoDeApoio();
      expect(await ApoioService.instance.mostrarCard(), isFalse);
    });

    test('com produto, o card aparece e o sheet dispara', () async {
      ligarLojaFalsa();
      semearEstadoDeApoio();
      expect(await ApoioService.instance.mostrarCard(), isTrue);

      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );
      expect(await ApoioService.instance.aoVoltarParaHome(), Gatilho.apoio);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // "Não perguntar de novo" só na terceira exibição
  // ───────────────────────────────────────────────────────────────────────────

  group('ultimaExibicao', () {
    Future<Gatilho> voltarParaHome() async {
      await ApoioService.instance.iniciarSessao();
      await ApoioService.instance.registrarLeitura(
        leituraConcluida: true,
        audioConcluido: false,
        sensivel: false,
      );
      return ApoioService.instance.aoVoltarParaHome();
    }

    /// [exposicoesAnteriores] quantas o sheet já gastou antes desta.
    void semear(int exposicoesAnteriores) {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(400),
        AppConstants.prefLeiturasCompletas: 20,
        AppConstants.prefReviewPedidoMs: _diasAtras(20),
        AppConstants.prefReviewSessionCount: 9,
        AppConstants.prefApoioExposicoes: exposicoesAnteriores,
        if (exposicoesAnteriores > 0)
          AppConstants.prefApoioMostradoMs: _diasAtras(100),
      });
    }

    test('falso na primeira e na segunda exibição', () async {
      for (final anteriores in [0, 1]) {
        ApoioService.instance = ApoioService();
        semear(anteriores);
        expect(await voltarParaHome(), Gatilho.apoio);
        expect(ApoioService.instance.ultimaExibicao, isFalse,
            reason: 'Exibição ${anteriores + 1} de 3 não é a última.');
      }
    });

    test('verdadeiro na terceira, que é a última pelo teto', () async {
      semear(2);
      expect(await voltarParaHome(), Gatilho.apoio);
      expect(ApoioService.instance.ultimaExibicao, isTrue);
    });
  });
}

int _diasAtras(int dias) =>
    DateTime.now().subtract(Duration(days: dias)).millisecondsSinceEpoch;

/// O `in_app_review` real não sobe sob `flutter test`: sem plugin nativo,
/// `isAvailable()` devolveria `false` e nenhum teste conseguiria distinguir
/// "não pediu porque não devia" de "não pediu porque a loja não existe".
/// Captura o que a tela de leitura manda, sem tocar no disco.
class _ApoioFalso extends ApoioService {
  final List<({bool leituraConcluida, bool audioConcluido, bool sensivel})>
      leituras = [];

  @override
  Future<void> registrarLeitura({
    required bool leituraConcluida,
    required bool audioConcluido,
    required bool sensivel,
  }) async {
    leituras.add((
      leituraConcluida: leituraConcluida,
      audioConcluido: audioConcluido,
      sensivel: sensivel,
    ));
  }
}

class _ReviewFalso extends ReviewService {
  int pedidos = 0;
  bool disponivelRetorna = true;

  @override
  Future<bool> disponivel() async => disponivelRetorna;

  @override
  Future<void> pedirAvaliacao() async => pedidos++;
}
