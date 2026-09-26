import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:salmos_app/core/apoio/compra_service.dart';

import '../../shared/fake_loja_play.dart';

/// Testes do protocolo do Play Billing — o nível em que os bugs de compra
/// vivem, abaixo de onde `FakeCompraApoio` substitui.
///
/// Cada citação de linha aqui é do plugin em
/// `~/.pub-cache/hosted/pub.dev/in_app_purchase_android-0.5.3/lib/src/`.
void main() {
  late FakeLojaPlay loja;
  late ConsumoFalso consumo;
  late CompraApoioPlay servico;
  late List<String> apoiosSemSheet;

  setUp(() {
    loja = FakeLojaPlay()..catalogo = [produtoFalso('apoio_10', 10)];
    consumo = ConsumoFalso();
    apoiosSemSheet = [];
    servico = CompraApoioPlay(
      loja: loja,
      consumir: consumo.call,
      aoApoiarSemSheet: (id) async => apoiosSemSheet.add(id),
    );
  });

  tearDown(() async {
    servico.dispose();
    await loja.fechar();
  });

  /// Deixa o ouvinte ligado e devolve o produto pré-selecionado.
  Future<ProdutoApoio> ligado() async {
    final lista = await servico.produtos();
    await pumpEventQueue();
    return lista.single;
  }

  Future<ResultadoCompra> semPendurar(Future<ResultadoCompra> f) => f.timeout(
        const Duration(seconds: 1),
        onTimeout: () =>
            throw StateError('comprar() nunca resolveu — o sheet trava aqui'),
      );

  // ── Bug 1 ──────────────────────────────────────────────────────────────────
  group('evento sintético de productID vazio', () {
    // O plugin emite `PurchaseDetails(purchaseID: '', productID: '')` quando
    // `resultWrapper.purchasesList` vem vazia — platform:295-317. É o caminho de
    // USER_CANCELED, ITEM_ALREADY_OWNED, SERVICE_UNAVAILABLE e
    // BILLING_UNAVAILABLE, ou seja, o desfecho mais frequente do fluxo.

    test('cancelar resolve comprar() em vez de pendurar para sempre', () async {
      final produto = await ligado();
      final futuro = servico.comprar(produto);
      await pumpEventQueue();

      loja.emitir([
        compraSintetica(
          PurchaseStatus.canceled,
          codigoBilling: BillingResponse.userCanceled,
        ),
      ]);

      final r = await semPendurar(futuro);
      expect(r.resultado, ResultadoApoio.cancelado);
    });

    test('não chama completePurchase no evento sintético', () async {
      // platform:192-197 tem assert + cast para GooglePlayPurchaseDetails; o
      // sintético é um PurchaseDetails cru. E platform:306-313 dá
      // serverVerificationData vazio: não há token para reconhecer.
      final produto = await ligado();
      final futuro = servico.comprar(produto);
      await pumpEventQueue();

      loja.emitir([
        compraSintetica(
          PurchaseStatus.canceled,
          codigoBilling: BillingResponse.userCanceled,
        ),
      ]);
      await semPendurar(futuro);

      expect(loja.reconhecidas, isEmpty);
      expect(consumo.tokens, isEmpty);
    });

    test('ITEM_ALREADY_OWNED usa copy neutra e dispara a restauração', () async {
      // platform:275-281 guarda o responseCode real em `error.message`. Já
      // cobrado: afirmar "nada foi cobrado" seria mentira.
      final produto = await ligado();
      final futuro = servico.comprar(produto);
      await pumpEventQueue();
      final antes = loja.restauracoes;

      loja.emitir([
        compraSintetica(
          PurchaseStatus.error,
          codigoBilling: BillingResponse.itemAlreadyOwned,
        ),
      ]);

      final r = await semPendurar(futuro);
      expect(r.resultado, ResultadoApoio.erroIndeterminado);
      expect(r.codigo, 'itemAlreadyOwned');
      expect(loja.restauracoes, antes + 1,
          reason: 'sem restaurar, a compra fica owned e trava a próxima');
    });

    test('BILLING_UNAVAILABLE pode afirmar que nada foi cobrado', () async {
      final produto = await ligado();
      final futuro = servico.comprar(produto);
      await pumpEventQueue();

      loja.emitir([
        compraSintetica(
          PurchaseStatus.error,
          codigoBilling: BillingResponse.billingUnavailable,
        ),
      ]);

      final r = await semPendurar(futuro);
      expect(r.resultado, ResultadoApoio.erroNadaCobrado);
    });

    test('responseCode ok sem compra na lista não vira "Obrigado"', () async {
      // platform:298-302: responseCode ok com lista vazia dá status purchased
      // num evento que não tem token nem produto. Não há o que entregar.
      final produto = await ligado();
      final futuro = servico.comprar(produto);
      await pumpEventQueue();

      loja.emitir([compraSintetica(PurchaseStatus.purchased)]);

      final r = await semPendurar(futuro);
      expect(r.resultado, ResultadoApoio.erroIndeterminado);
      expect(apoiosSemSheet, isEmpty);
    });
  });

  // ── Bug 2 ──────────────────────────────────────────────────────────────────
  test('buyConsumable false não afirma que nada foi cobrado', () async {
    // platform:179 devolve `responseCode == ok`, e platform:183-188 delega sem
    // acrescentar nada. O `false` cobre ITEM_ALREADY_OWNED — em que a pessoa já
    // foi cobrada — sem jeito de distinguir.
    loja.lancamentoOk = false;
    final produto = await ligado();

    final r = await semPendurar(servico.comprar(produto));

    expect(r.resultado, ResultadoApoio.erroIndeterminado);
    expect(r.codigo, 'nao_lancou');
  });

  test('produto sem ProductDetails continua sendo nada cobrado', () async {
    // Aqui o fluxo nem chega ao plugin: a afirmação é verdadeira.
    final r = await servico.comprar(
      const ProdutoApoio(id: 'apoio_10', precoFormatado: 'x', precoBruto: 10),
    );
    expect(r.resultado, ResultadoApoio.erroNadaCobrado);
    expect(r.codigo, 'sem_produto');
  });

  // ── Bug 3 ──────────────────────────────────────────────────────────────────
  test('compra restaurada é consumida, não só reconhecida', () async {
    // platform:235 marca status `restored`. platform:249-251 só consome
    // automaticamente o que é `purchased` E está em `_productIdsToConsume`
    // (platform:67), populado só por buyConsumable deste processo
    // (platform:185). Restaurada nunca é consumida pelo plugin, e
    // completePurchase é acknowledge (platform:191-206), não consumo.
    await ligado();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_10',
        status: PurchaseStatus.restored,
        reconhecida: true,
      ),
    ]);
    await pumpEventQueue();

    expect(consumo.tokens, ['token-1'],
        reason: 'sem consumir, fica owned e ITEM_ALREADY_OWNED é permanente');
  });

  test('não reconhece de novo o que já está acknowledged', () async {
    // google_play_purchase_details.dart:23 põe
    // `pendingCompletePurchase = !isAcknowledged`; platform:199-201 já devolve
    // ok cedo nesse caso. Chamar é ruído.
    await ligado();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_10',
        status: PurchaseStatus.restored,
        reconhecida: true,
      ),
    ]);
    await pumpEventQueue();

    expect(loja.reconhecidas, isEmpty);
  });

  // ── Bug 4 ──────────────────────────────────────────────────────────────────
  test('dispose não desliga o ouvinte: compra tardia é reconhecida e consumida',
      () async {
    await ligado();
    servico.dispose(); // o sheet fechou

    loja.emitir([
      compraReal(produtoId: 'apoio_10', status: PurchaseStatus.purchased),
    ]);
    await pumpEventQueue();

    expect(loja.reconhecidas, ['token-1'],
        reason: 'sem acknowledge o Play estorna em 3 dias');
    expect(consumo.tokens, ['token-1']);
  });

  test('compra sem sheet aberto marca o apoio', () async {
    await ligado();
    servico.dispose();

    loja.emitir([
      compraReal(produtoId: 'apoio_10', status: PurchaseStatus.purchased),
    ]);
    await pumpEventQueue();

    expect(apoiosSemSheet, ['apoio_10']);
  });

  // ── Bug 5 ──────────────────────────────────────────────────────────────────
  test('compra real com status sobrescrito para canceled não vira cancelamento',
      () async {
    // platform:288-291 sobrescreve `status = canceled` em PurchaseWrapper REAIS
    // quando o responseCode do lote é userCanceled. O purchaseState do wrapper
    // continua `purchased`: a pessoa pagou.
    final produto = await ligado();
    final futuro = servico.comprar(produto);
    await pumpEventQueue();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_10',
        status: PurchaseStatus.canceled,
        estado: PurchaseStateWrapper.purchased,
      ),
    ]);

    final r = await semPendurar(futuro);
    expect(r.resultado, isNot(ResultadoApoio.cancelado),
        reason: '"Nada foi cobrado" sobre uma compra paga e owned');
    expect(r.resultado, ResultadoApoio.concluido);
    expect(consumo.tokens, ['token-1']);
  });

  test('canceled sobre wrapper pendente continua sendo cancelamento', () async {
    final produto = await ligado();
    final futuro = servico.comprar(produto);
    await pumpEventQueue();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_10',
        status: PurchaseStatus.canceled,
        estado: PurchaseStateWrapper.pending,
      ),
    ]);

    final r = await semPendurar(futuro);
    expect(r.resultado, ResultadoApoio.cancelado);
    expect(consumo.tokens, isEmpty);
  });

  // ── Pendente ───────────────────────────────────────────────────────────────
  test('compra pendente não é completada nem consumida', () async {
    // in_app_purchase.dart:166-167: completar uma compra pendente estoura.
    final produto = await ligado();
    final futuro = servico.comprar(produto);
    await pumpEventQueue();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_10',
        status: PurchaseStatus.pending,
        estado: PurchaseStateWrapper.pending,
      ),
    ]);

    final r = await semPendurar(futuro);
    expect(r.resultado, ResultadoApoio.erroIndeterminado);
    expect(r.codigo, 'pendente');
    expect(loja.reconhecidas, isEmpty);
    expect(consumo.tokens, isEmpty);
  });

  test('purchased de outro produto não resolve a compra em curso', () async {
    final produto = await ligado();
    final futuro = servico.comprar(produto);
    await pumpEventQueue();

    loja.emitir([
      compraReal(
        produtoId: 'apoio_25',
        status: PurchaseStatus.purchased,
        token: 'token-outro',
      ),
    ]);
    await pumpEventQueue();

    // Reconhecida e consumida de todo jeito, mas o sheet segue esperando.
    expect(consumo.tokens, ['token-outro']);

    loja.emitir([
      compraReal(produtoId: 'apoio_10', status: PurchaseStatus.purchased),
    ]);
    final r = await semPendurar(futuro);
    expect(r.resultado, ResultadoApoio.concluido);
  });
}
