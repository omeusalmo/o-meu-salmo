import 'package:in_app_review/in_app_review.dart';

import '../constants/app_constants.dart';
import '../services/link_service.dart';

/// Casca fina sobre o `in_app_review` e sobre o link da ficha da loja.
///
/// Toda a decisão de QUANDO pedir saiu daqui e foi para
/// [Elegibilidade]/`ApoioService`. O que sobrou é o que depende de plataforma —
/// e é justamente o que precisa ser trocável em teste, no mesmo padrão de
/// [LinkService]: sob `flutter test` não existe Play Store, então o serviço real
/// devolveria `false` e nenhum teste conseguiria provar que o toque faz algo.
///
/// Política do Google Play: o prompt nativo não pode ser precedido de pergunta
/// de opinião ("você gosta do app?"), nem condicionado a nota. Por isso nenhum
/// ramo do sheet de apoio chega aqui, e o pedido de avaliação acontece noutro
/// momento, sem pergunta antes.
class ReviewService {
  ReviewService();

  /// Trocável em teste. Em produção nunca é reatribuído.
  static ReviewService instance = ReviewService();

  Future<bool> disponivel() {
    try {
      return InAppReview.instance.isAvailable();
    } catch (_) {
      return Future.value(false);
    }
  }

  Future<void> pedirAvaliacao() => InAppReview.instance.requestReview();

  /// Abre a ficha do app na loja.
  ///
  /// `market://` primeiro porque abre o app da Play Store direto, sem passar
  /// pelo navegador. A `https` é o plano B de aparelho sem Play Services, onde
  /// o esquema `market` não resolve e o toque morreria em silêncio.
  Future<bool> abrirFichaDaLoja() async {
    final nativo = await LinkService.instance.abrir(
      Uri.parse(AppConstants.uriLojaNativa),
      externo: true,
    );
    if (nativo) return true;
    return LinkService.instance.abrir(
      Uri.parse(AppConstants.urlLojaWeb),
      externo: true,
    );
  }
}
