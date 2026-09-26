import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Compra de apoio via Google Play Billing — produto consumível, sem nada
/// liberado no app.
///
/// ⚠️ FASE 2. O código está escrito e o app se degrada sozinho enquanto os
/// produtos não existirem na Play Console: `produtos()` devolve lista vazia e o
/// sheet mostra o estado de erro com "Nada foi cobrado" (que é verdade — o fluxo
/// nem começou). Nada aqui pode ser testado de ponta a ponta antes de
/// `apoio_5`, `apoio_10` e `apoio_25` estarem publicados e da build estar
/// assinada com a chave de upload.
///
/// Consumível, e não não-consumível, por uma razão de produto: apoiar de novo
/// tem de ser possível. Um produto gerenciado "já comprado" travaria a segunda
/// doação para sempre.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// O que o plugin NÃO faz por nós — as três coisas que este arquivo existe para
/// cobrir. Linhas de
/// `in_app_purchase_android-0.5.3/lib/src/in_app_purchase_android_platform.dart`:
///
///  1. `completePurchase` no Android é `acknowledgePurchase` e mais nada
///     (:191-206), e sai cedo se já estiver reconhecida (:199-201). Não consome.
///  2. O auto-consumo (`_maybeAutoConsumePurchase`, :249-268) exige status
///     `purchased` E o id no `_productIdsToConsume` (:67), que só `buyConsumable`
///     deste processo popula (:185). Uma compra que volta de `restorePurchases()`
///     tem status `restored` (:235) e não está no set: nunca é consumida.
///     Consumir é chamada explícita, via
///     `InAppPurchaseAndroidPlatformAddition.consumePurchase`
///     (in_app_purchase_android_platform_addition.dart:39).
///  3. Quando `purchasesList` vem vazia, o plugin emite um `PurchaseDetails`
///     SINTÉTICO com `productID: ''` e `purchaseID: ''` (:295-317). É o caminho
///     de USER_CANCELED, ITEM_ALREADY_OWNED, SERVICE_UNAVAILABLE e
///     BILLING_UNAVAILABLE — o desfecho mais frequente do fluxo.
/// ─────────────────────────────────────────────────────────────────────────────

/// Ids dos produtos na Play Console. Mudar aqui exige mudar lá.
const List<String> kProdutosApoio = ['apoio_5', 'apoio_10', 'apoio_25'];

/// Pré-selecionado no sheet. Se não vier da loja, cai no do meio da lista.
const String kProdutoApoioPadrao = 'apoio_10';

/// Um produto como a UI o vê.
///
/// A UI nunca toca em `ProductDetails`: assim o widget test monta a lista de
/// valores sem plugin nativo, e o preço não tem por onde ser hardcoded.
@immutable
class ProdutoApoio {
  final String id;

  /// SEMPRE o preço formatado que a loja devolve — `ProductDetails.price`, que
  /// é o `formattedPrice` do Billing. A loja é quem sabe a moeda, o país e o
  /// imposto; qualquer "R$ 10" escrito por nós seria mentira em algum lugar.
  final String precoFormatado;

  /// Para ordenar a lista do menor para o maior sem depender do texto.
  final double precoBruto;

  /// `ProductDetails` opaco. `null` nos testes.
  final Object? nativo;

  const ProdutoApoio({
    required this.id,
    required this.precoFormatado,
    required this.precoBruto,
    this.nativo,
  });
}

/// Em que a tentativa de apoio terminou.
enum ResultadoApoio {
  /// Pago e consumido. Único caso em que o "Obrigado" aparece.
  concluido,

  /// A pessoa fechou a cobrança do Play. Não é erro: vira snackbar.
  cancelado,

  /// Falhou ANTES de chegar à cobrança, e isso é demonstrável: ou o fluxo nem
  /// tocou no plugin, ou o Billing devolveu um responseCode que só existe antes
  /// de haver transação (ver [_codigosSemCobranca]).
  erroNadaCobrado,

  /// Falhou e não há como afirmar que nada foi cobrado. Copy neutra.
  erroIndeterminado,
}

@immutable
class ResultadoCompra {
  final ResultadoApoio resultado;

  /// Código para o analytics (`support_purchase_error`). Nunca vai para a tela.
  final String? codigo;

  const ResultadoCompra(this.resultado, {this.codigo});
}

/// Contrato que a UI conhece. O sheet recebe uma implementação por parâmetro,
/// então o widget test injeta uma falsa e o app injeta a do Play.
abstract class CompraApoio {
  /// Lista vazia = loja indisponível ou produtos ainda não publicados.
  Future<List<ProdutoApoio>> produtos();

  Future<ResultadoCompra> comprar(ProdutoApoio produto);

  void dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
// Consumo
// ─────────────────────────────────────────────────────────────────────────────

/// Consome uma compra; `true` se o Play confirmou.
///
/// É um seam e não uma chamada direta porque
/// `InAppPurchaseAndroidPlatformAddition` só existe com um `BillingClientManager`
/// de verdade (in_app_purchase_android_platform_addition.dart:19-23), que não
/// sobe sob `flutter test`.
typedef ConsumirCompra = Future<bool> Function(PurchaseDetails compra);

Future<bool> _consumirNoPlay(PurchaseDetails compra) async {
  try {
    final extra = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition?>();
    if (extra == null) return false;
    final r = await extra.consumePurchase(compra);
    return r.responseCode == BillingResponse.ok;
  } catch (e) {
    debugPrint('[Apoio] consumePurchase falhou: $e');
    return false;
  }
}

/// Códigos do Billing em que dá para afirmar que nada foi cobrado: todos
/// descrevem uma recusa ANTES de existir transação.
///
/// Fora daqui de propósito: `serviceUnavailable`, `serviceTimeout` e
/// `networkError` (a resposta pode ter se perdido depois do débito), `error`
/// (genérico) e `itemAlreadyOwned` / `itemNotOwned` (falam de uma compra que
/// existe). Nomes em `BillingResponse`
/// (billing_client_wrappers/billing_client_wrapper.dart:367-406).
const Set<String> _codigosSemCobranca = {
  'billingUnavailable',
  'featureNotSupported',
  'itemUnavailable',
  'developerError',
  'serviceDisconnected',
};

// ─────────────────────────────────────────────────────────────────────────────
// Ouvinte do processo
// ─────────────────────────────────────────────────────────────────────────────

/// Uma assinatura do `purchaseStream` por processo, ligada no launch e nunca
/// cancelada.
///
/// Antes disto a assinatura vivia dentro de cada `CompraApoioPlay`, que o
/// `finally` de `mostrarApoioSheet` descartava. Compra que o Play confirmasse
/// depois do sheet fechado chegava sem ninguém ouvindo: nunca reconhecida, nunca
/// consumida, estornada em três dias. E `LojaApoio._consultar` criava e
/// descartava uma instância só para perguntar o catálogo, cancelando a assinatura
/// enquanto a drenagem de abertura ainda estava no ar.
///
/// O próprio plugin manda fazer assim: "You must subscribe to this stream as soon
/// as your app launches, preferably before returning your main App Widget in
/// main()" (in_app_purchase-3.3.1/lib/in_app_purchase.dart:64-66).
class ApoioBilling {
  ApoioBilling({
    InAppPurchase? loja,
    ConsumirCompra? consumir,
    this.aoApoiarSemSheet,
  })  : _injetada = loja,
        _consumir = consumir ?? _consumirNoPlay;

  /// Trocável em teste (mesmo padrão de LojaApoio/ReviewService).
  static ApoioBilling instance = ApoioBilling();

  final InAppPurchase? _injetada;
  final ConsumirCompra _consumir;

  /// Uma compra de apoio chegou e não havia sheet esperando por ela: processo
  /// morto no meio, confirmação lenta do Play, compra iniciada fora do app.
  /// Ligado em `main.dart` para gravar o apoio de todo jeito — quem pagou não
  /// pode continuar recebendo pedido.
  Future<void> Function(String produtoId)? aoApoiarSemSheet;

  /// Resolvido tarde, de propósito. `InAppPurchase.instance` estoura quando não
  /// há plugin registrado — é o que acontece sob `flutter test`.
  InAppPurchase get _loja => _injetada ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _assinatura;
  bool _ligado = false;

  /// Compra em andamento. Fora de uma tentativa é `null`, e aí o que chega pelo
  /// stream é drenado em silêncio, sem "Obrigado" na cara de quem não pediu.
  Completer<ResultadoCompra>? _emCurso;
  String? _idEmCurso;

  /// Assina o stream e drena o que ficou pendurado. Idempotente.
  ///
  /// Chamado no launch (`main.dart`) e, defensivamente, por `produtos()` e
  /// `comprar()`.
  void iniciar() {
    if (_ligado) return;
    try {
      final loja = _loja;
      _assinatura = loja.purchaseStream.listen(
        _aoChegarCompra,
        onError: (Object e) {
          debugPrint('[Apoio] purchaseStream falhou: $e');
          _concluir(const ResultadoCompra(
            ResultadoApoio.erroIndeterminado,
            codigo: 'stream',
          ));
        },
      );
      _ligado = true;
      // Drenagem de abertura: sem ela, uma compra confirmada e não consumida
      // deixa ITEM_ALREADY_OWNED para sempre.
      loja.restorePurchases().catchError((Object _) {});
    } catch (e) {
      // Sem plugin nativo (flutter test) ou sem Play Services. Degrada: as
      // entradas de apoio somem via LojaApoio.
      debugPrint('[Apoio] ouvinte não subiu: $e');
    }
  }

  Future<List<ProdutoApoio>> produtos() async {
    try {
      if (!await _loja.isAvailable()) return const [];
      iniciar();
      final resposta = await _loja.queryProductDetails(kProdutosApoio.toSet());
      if (resposta.error != null) return const [];
      final lista = resposta.productDetails
          .map((p) => ProdutoApoio(
                id: p.id,
                precoFormatado: p.price,
                precoBruto: p.rawPrice,
                nativo: p,
              ))
          .toList()
        ..sort((a, b) => a.precoBruto.compareTo(b.precoBruto));
      return lista;
    } catch (e) {
      debugPrint('[Apoio] produtos falharam: $e');
      return const [];
    }
  }

  Future<ResultadoCompra> comprar(ProdutoApoio produto) async {
    final detalhes = produto.nativo;
    if (detalhes is! ProductDetails) {
      // O fluxo não tocou no plugin: a afirmação é verificável.
      return const ResultadoCompra(
        ResultadoApoio.erroNadaCobrado,
        codigo: 'sem_produto',
      );
    }
    iniciar();

    final espera = Completer<ResultadoCompra>();
    _emCurso = espera;
    _idEmCurso = produto.id;

    try {
      // autoConsume não basta (ver o cabeçalho, ponto 2), mas ligado cobre o
      // caminho feliz sem uma ida extra ao Play.
      final lancou = await _loja.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: detalhes),
        autoConsume: true,
      );
      if (!lancou) {
        // `buyNonConsumable` devolve `billingResultWrapper.responseCode == ok`
        // (platform:179) e `buyConsumable` só delega (platform:183-188). O
        // `false` é o mesmo para BILLING_UNAVAILABLE e para ITEM_ALREADY_OWNED
        // — e neste a pessoa JÁ FOI cobrada por uma compra não consumida. O
        // booleano não carrega o motivo, então não há como afirmar que nada foi
        // cobrado: copy neutra. A causa raiz, a compra que ficou owned, é
        // resolvida pela drenagem de `iniciar()`, que agora consome.
        return _concluirCom(const ResultadoCompra(
          ResultadoApoio.erroIndeterminado,
          codigo: 'nao_lancou',
        ));
      }
    } catch (e) {
      // Exceção do canal. Pode ter estourado depois de o Play abrir, então
      // também não dá para prometer que nada foi cobrado.
      debugPrint('[Apoio] buyConsumable estourou: $e');
      return _concluirCom(const ResultadoCompra(
        ResultadoApoio.erroIndeterminado,
        codigo: 'excecao_lancamento',
      ));
    }

    return espera.future;
  }

  /// O sheet fechou. Solta quem esperava; a assinatura do processo FICA.
  void desistir() => _concluir(const ResultadoCompra(ResultadoApoio.cancelado));

  // ── Stream ───────────────────────────────────────────────────────────────

  Future<void> _aoChegarCompra(List<PurchaseDetails> compras) async {
    for (final c in compras) {
      try {
        await _tratar(c);
      } catch (e) {
        debugPrint('[Apoio] evento de compra falhou: $e');
      }
    }
  }

  Future<void> _tratar(PurchaseDetails c) async {
    // Evento sintético (platform:295-317): sem produto e sem token. Não há o que
    // reconhecer nem o que consumir — é só o desfecho da tentativa em curso.
    // Chamar completePurchase aqui estoura no assert/cast de platform:192-197.
    if (c.productID.isEmpty) {
      _concluir(_desfechoSintetico(c));
      return;
    }

    if (_compraPaga(c)) {
      await _entregar(c);
      if (_emCurso != null && c.productID == _idEmCurso) {
        _concluir(const ResultadoCompra(ResultadoApoio.concluido));
      } else if (kProdutosApoio.contains(c.productID)) {
        await aoApoiarSemSheet?.call(c.productID);
      }
      return;
    }

    // Não paga. Nada a reconhecer, e completar uma pendente estoura
    // (in_app_purchase.dart:166-167).
    if (_emCurso == null || c.productID != _idEmCurso) return;
    switch (c.status) {
      case PurchaseStatus.canceled:
        _concluir(const ResultadoCompra(ResultadoApoio.cancelado));
      case PurchaseStatus.pending:
        // Boleto não é aceito no Google Play Brasil e Pix confirma em segundos,
        // então isto é defensivo. Neutra: pendente pode virar cobrança a
        // qualquer momento — e agora o ouvinte do processo está lá para receber.
        _concluir(const ResultadoCompra(
          ResultadoApoio.erroIndeterminado,
          codigo: 'pendente',
        ));
      case PurchaseStatus.error:
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _concluir(ResultadoCompra(
          ResultadoApoio.erroIndeterminado,
          codigo: c.error?.code ?? 'erro',
        ));
    }
  }

  /// A pessoa pagou por esta compra?
  ///
  /// `status` não serve sozinho: platform:288-291 sobrescreve `canceled` em cima
  /// de `PurchaseWrapper` REAIS quando o responseCode do lote é userCanceled.
  /// `purchaseState` é o que o Play disse sobre a compra
  /// (google_play_purchase_details.dart:41).
  bool _compraPaga(PurchaseDetails c) {
    if (c is GooglePlayPurchaseDetails) {
      return c.billingClientPurchase.purchaseState ==
          PurchaseStateWrapper.purchased;
    }
    return c.status == PurchaseStatus.purchased ||
        c.status == PurchaseStatus.restored;
  }

  /// Reconhece e consome. Nesta ordem e sempre as duas.
  Future<void> _entregar(PurchaseDetails c) async {
    // `pendingCompletePurchase` é `!isAcknowledged`
    // (google_play_purchase_details.dart:23), e platform:199-201 já devolve ok
    // cedo quando reconhecida. Chamar de novo é ida ao nativo por nada.
    if (c.pendingCompletePurchase) {
      try {
        // A facade devolve `Future<void>` (in_app_purchase.dart:188) e engole o
        // BillingResultWrapper de platform:191. Só a exceção sobra como sinal —
        // e mesmo falhando, o consumo abaixo reconhece por conta própria
        // (`consumeAsync` também faz acknowledge).
        await _loja.completePurchase(c);
      } catch (e) {
        debugPrint('[Apoio] completePurchase falhou: $e');
      }
    }

    // Consumo explícito. É o ponto 2 do cabeçalho: sem isto a compra fica paga,
    // reconhecida e owned para sempre, e toda tentativa seguinte morre em
    // ITEM_ALREADY_OWNED.
    if (!kProdutosApoio.contains(c.productID)) return;
    if (!await _consumir(c)) {
      debugPrint('[Apoio] consumo recusado para ${c.productID}');
    }
  }

  ResultadoCompra _desfechoSintetico(PurchaseDetails c) {
    switch (c.status) {
      case PurchaseStatus.canceled:
        return const ResultadoCompra(ResultadoApoio.cancelado);

      case PurchaseStatus.purchased:
        // platform:298-302: responseCode ok com `purchasesList` vazia. Não há
        // token nem produto — nada para entregar e nada que prove pagamento.
        // "Obrigado" aqui seria chute.
        return const ResultadoCompra(
          ResultadoApoio.erroIndeterminado,
          codigo: 'ok_sem_compra',
        );

      case PurchaseStatus.error:
      case PurchaseStatus.pending:
      case PurchaseStatus.restored:
        final codigo = _codigoBilling(c);
        if (codigo == 'itemAlreadyOwned') {
          // Já cobrado e não consumido. Restaurar traz a compra pelo stream, e
          // aí `_entregar` consome — é o que destrava a próxima tentativa.
          try {
            _loja.restorePurchases().catchError((Object _) {});
          } catch (_) {}
        }
        return ResultadoCompra(
          _codigosSemCobranca.contains(codigo)
              ? ResultadoApoio.erroNadaCobrado
              : ResultadoApoio.erroIndeterminado,
          codigo: codigo,
        );
    }
  }

  /// O responseCode de verdade, que o plugin guarda em `error.message`
  /// (platform:275-281: `message: resultWrapper.responseCode.toString()`). É o
  /// único lugar em que ele sobrevive até aqui.
  String _codigoBilling(PurchaseDetails c) {
    final m = c.error?.message ?? '';
    const prefixo = 'BillingResponse.';
    if (m.startsWith(prefixo)) return m.substring(prefixo.length);
    return m.isEmpty ? 'erro' : m;
  }

  ResultadoCompra _concluirCom(ResultadoCompra r) {
    _concluir(r);
    return r;
  }

  void _concluir(ResultadoCompra r) {
    final espera = _emCurso;
    _emCurso = null;
    _idEmCurso = null;
    if (espera != null && !espera.isCompleted) espera.complete(r);
  }

  /// Só para teste — solta a assinatura do processo.
  @visibleForTesting
  Future<void> parar() async {
    await _assinatura?.cancel();
    _assinatura = null;
    _ligado = false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementação Google Play vista pela UI
// ─────────────────────────────────────────────────────────────────────────────

/// Fachada fina sobre [ApoioBilling]. Descartável: é criada e jogada fora pelo
/// ciclo de vida do sheet, e `dispose()` não toca na assinatura do processo.
class CompraApoioPlay implements CompraApoio {
  /// Sem argumentos usa o ouvinte do processo. Passar qualquer seam cria um
  /// ouvinte dedicado — é o que isola um teste do outro.
  CompraApoioPlay({
    InAppPurchase? loja,
    ConsumirCompra? consumir,
    Future<void> Function(String produtoId)? aoApoiarSemSheet,
  }) : _billing =
            (loja == null && consumir == null && aoApoiarSemSheet == null)
                ? ApoioBilling.instance
                : ApoioBilling(
                    loja: loja,
                    consumir: consumir,
                    aoApoiarSemSheet: aoApoiarSemSheet,
                  );

  final ApoioBilling _billing;

  @override
  Future<List<ProdutoApoio>> produtos() => _billing.produtos();

  @override
  Future<ResultadoCompra> comprar(ProdutoApoio produto) =>
      _billing.comprar(produto);

  @override
  void dispose() => _billing.desistir();
}
