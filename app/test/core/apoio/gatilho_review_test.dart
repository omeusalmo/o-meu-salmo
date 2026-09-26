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
  });

  tearDown(() => ReviewService.instance = ReviewService());

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
