import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

  /// Falhou ANTES de chegar à cobrança. Aqui "Nada foi cobrado" é verdade.
  erroNadaCobrado,

  /// Falhou e não há como afirmar que nada foi cobrado: pendência do Billing,
  /// compra anterior não consumida, erro genérico da loja. Copy neutra.
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
// Implementação Google Play
// ─────────────────────────────────────────────────────────────────────────────

class CompraApoioPlay implements CompraApoio {
  CompraApoioPlay({InAppPurchase? loja}) : _injetada = loja;

  final InAppPurchase? _injetada;

  /// Resolvido tarde, de propósito. `InAppPurchase.instance` estoura quando não
  /// há plugin registrado — é o que acontece sob `flutter test`. Resolvendo aqui,
  /// dentro dos try/catch de quem usa, a tela degrada para "loja indisponível"
  /// em vez de derrubar o widget na construção.
  InAppPurchase get _loja => _injetada ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _assinatura;

  /// Compra em andamento. Fora de uma tentativa é `null`, e aí tudo que chega
  /// pelo stream é resto de sessão anterior: consumido em silêncio, sem
  /// "Obrigado" na cara de quem não pediu nada agora.
  Completer<ResultadoCompra>? _emCurso;
  String? _idEmCurso;

  bool _ligado = false;

  /// Assina o stream e drena compras penduradas.
  ///
  /// Sem a drenagem, uma compra que o Play confirmou mas o app não consumiu
  /// (processo morto no meio) faz a próxima tentativa falhar com
  /// ITEM_ALREADY_OWNED para sempre.
  void _ligar() {
    if (_ligado) return;
    _ligado = true;
    final loja = _loja;
    _assinatura = loja.purchaseStream.listen(
      _aoChegarCompra,
      onError: (Object e) => _concluir(
        const ResultadoCompra(
          ResultadoApoio.erroIndeterminado,
          codigo: 'stream',
        ),
      ),
    );
    loja.restorePurchases().catchError((Object _) {});
  }

  @override
  Future<List<ProdutoApoio>> produtos() async {
    try {
      if (!await _loja.isAvailable()) return const [];
      _ligar();
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

  @override
  Future<ResultadoCompra> comprar(ProdutoApoio produto) async {
    final detalhes = produto.nativo;
    if (detalhes is! ProductDetails) {
      return const ResultadoCompra(ResultadoApoio.erroNadaCobrado,
          codigo: 'sem_produto');
    }
    _ligar();

    final espera = Completer<ResultadoCompra>();
    _emCurso = espera;
    _idEmCurso = produto.id;

    try {
      // autoConsume: o Android consome sozinho, o que é o que queremos — apoiar
      // de novo no mês seguinte tem de funcionar.
      final lancou = await _loja.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: detalhes),
        autoConsume: true,
      );
      if (!lancou) {
        // O Play recusou ABRIR a cobrança. Nada foi cobrado, com certeza.
        return _concluirCom(const ResultadoCompra(
          ResultadoApoio.erroNadaCobrado,
          codigo: 'nao_lancou',
        ));
      }
    } catch (e) {
      debugPrint('[Apoio] buyConsumable estourou: $e');
      return _concluirCom(const ResultadoCompra(
        ResultadoApoio.erroNadaCobrado,
        codigo: 'excecao_lancamento',
      ));
    }

    return espera.future;
  }

  Future<void> _aoChegarCompra(List<PurchaseDetails> compras) async {
    for (final c in compras) {
      // completePurchase é obrigatório em qualquer desfecho que não seja
      // pendente: sem ele o Play reembolsa em três dias.
      if (c.status != PurchaseStatus.pending) {
        try {
          await _loja.completePurchase(c);
        } catch (e) {
          debugPrint('[Apoio] completePurchase falhou: $e');
        }
      }

      // Resto de sessão anterior: consumido acima, e nada na tela.
      if (_emCurso == null || c.productID != _idEmCurso) continue;

      switch (c.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _concluir(const ResultadoCompra(ResultadoApoio.concluido));
        case PurchaseStatus.canceled:
          _concluir(const ResultadoCompra(ResultadoApoio.cancelado));
        case PurchaseStatus.error:
          // Não dá para afirmar que nada foi cobrado: o erro pode ter vindo
          // depois do débito. Copy neutra.
          _concluir(ResultadoCompra(
            ResultadoApoio.erroIndeterminado,
            codigo: c.error?.code ?? 'erro',
          ));
        case PurchaseStatus.pending:
          // Boleto não é aceito no Google Play Brasil e Pix confirma em
          // segundos, então isto é defensivo, não um fluxo. Cai no estado de
          // erro — com a frase neutra, porque um pagamento pendente pode virar
          // cobrança a qualquer momento.
          _concluir(const ResultadoCompra(
            ResultadoApoio.erroIndeterminado,
            codigo: 'pendente',
          ));
      }
    }
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

  @override
  void dispose() {
    _assinatura?.cancel();
    _assinatura = null;
    _ligado = false;
    _concluir(const ResultadoCompra(ResultadoApoio.cancelado));
  }
}
