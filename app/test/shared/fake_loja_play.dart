import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart'
    show InAppPurchasePlatformAddition;

/// Loja falsa no nível do `purchaseStream`.
///
/// O `FakeCompraApoio` de `fake_compra.dart` substitui no nível de
/// [ResultadoCompra] — acima de onde os bugs do Billing vivem. Um fake ali não
/// consegue emitir o evento sintético de `productID: ''`, não consegue devolver
/// `false` de `buyConsumable` e não consegue produzir um `status: restored`.
/// Este substitui o [InAppPurchase] inteiro, então o mapeamento de status, o
/// acknowledge, o consumo e o ciclo de vida da assinatura ficam sob teste.
///
/// Aquele continua servindo os widget tests, que precisam de um resultado pronto
/// e não do protocolo do Play.
class FakeLojaPlay implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _stream =
      StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _stream.stream;

  /// `false` simula device sem Play Services.
  bool disponivel = true;

  /// O que `buyConsumable` devolve. `false` = o Play recusou ABRIR a cobrança
  /// (in_app_purchase_android_platform.dart:179 — `responseCode != ok`, sem
  /// dizer qual código, que é a raiz do bug 2).
  bool lancamentoOk = true;

  List<ProductDetails> catalogo = const [];
  IAPError? erroCatalogo;

  /// Tokens passados a `completePurchase` (= acknowledge no Android,
  /// in_app_purchase_android_platform.dart:191-206).
  final List<String> reconhecidas = [];

  /// Ids passados a `buyConsumable`.
  final List<String> lancadas = [];

  int restauracoes = 0;

  @override
  Future<bool> isAvailable() async => disponivel;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: catalogo,
        notFoundIDs: const [],
        error: erroCatalogo,
      );

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    lancadas.add(purchaseParam.productDetails.id);
    return lancamentoOk;
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) =>
      buyConsumable(purchaseParam: purchaseParam);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    // O plugin real estoura aqui num PurchaseDetails que não seja
    // GooglePlayPurchaseDetails (in_app_purchase_android_platform.dart:192-197:
    // assert + cast). O fake reproduz para que chamar isto no evento sintético
    // apareça como falha, e não como silêncio.
    if (purchase is! GooglePlayPurchaseDetails) {
      throw StateError(
        'completePurchase num PurchaseDetails que não é GooglePlayPurchaseDetails',
      );
    }
    reconhecidas.add(purchase.verificationData.serverVerificationData);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restauracoes++;
  }

  @override
  Future<String> countryCode() async => 'BR';

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() =>
      throw UnimplementedError(
        'InAppPurchaseAndroidPlatformAddition exige um BillingClientManager real '
        '(in_app_purchase_android_platform_addition.dart:19-23). O consumo entra '
        'pelo seam ConsumirCompra.',
      );

  /// Empurra um evento pelo stream, como `_getPurchaseDetailsFromResult` faz
  /// (in_app_purchase_android_platform.dart:43-45).
  void emitir(List<PurchaseDetails> compras) => _stream.add(compras);

  void emitirErro(Object e) => _stream.addError(e);

  Future<void> fechar() => _stream.close();
}

/// Registra as chamadas de consumo.
class ConsumoFalso {
  final List<String> tokens = [];
  bool ok = true;

  Future<bool> call(PurchaseDetails compra) async {
    tokens.add(compra.verificationData.serverVerificationData);
    return ok;
  }
}

/// O evento SINTÉTICO que o plugin emite quando `purchasesList` vem vazia —
/// `productID: ''` e `purchaseID: ''`
/// (in_app_purchase_android_platform.dart:295-317).
///
/// [codigoBilling] vira `error.message`, que é onde o plugin guarda o
/// `responseCode` de verdade
/// (in_app_purchase_android_platform.dart:275-281: `message:
/// resultWrapper.responseCode.toString()`).
PurchaseDetails compraSintetica(
  PurchaseStatus status, {
  BillingResponse? codigoBilling,
}) {
  final d = PurchaseDetails(
    purchaseID: '',
    productID: '',
    status: status,
    transactionDate: null,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: kIAPSource,
    ),
  );
  if (codigoBilling != null) {
    d.error = IAPError(
      source: kIAPSource,
      code: kPurchaseErrorCode,
      message: codigoBilling.toString(),
    );
  }
  return d;
}

/// Uma compra REAL, do jeito que `GooglePlayPurchaseDetails.fromPurchase`
/// produz (google_play_purchase_details.dart:29-50) — inclusive
/// `pendingCompletePurchase = !isAcknowledged` (linha 23).
GooglePlayPurchaseDetails compraReal({
  required String produtoId,
  required PurchaseStatus status,
  String token = 'token-1',
  bool reconhecida = false,
  PurchaseStateWrapper estado = PurchaseStateWrapper.purchased,
}) {
  final wrapper = PurchaseWrapper(
    orderId: 'pedido-1',
    packageName: 'com.omeusalmo.app',
    purchaseTime: 0,
    purchaseToken: token,
    signature: 'sig',
    products: [produtoId],
    isAutoRenewing: false,
    originalJson: '{}',
    isAcknowledged: reconhecida,
    purchaseState: estado,
  );
  return GooglePlayPurchaseDetails(
    purchaseID: 'pedido-1',
    productID: produtoId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '{}',
      serverVerificationData: token,
      source: kIAPSource,
    ),
    transactionDate: '0',
    billingClientPurchase: wrapper,
    status: status,
  );
}

/// Um produto como a loja devolveria.
ProductDetails produtoFalso(String id, double preco) => ProductDetails(
      id: id,
      title: id,
      description: id,
      price: 'R\$ ${preco.toStringAsFixed(2)}',
      rawPrice: preco,
      currencyCode: 'BRL',
    );
