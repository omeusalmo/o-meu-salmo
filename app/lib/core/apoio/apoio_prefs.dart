import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'elegibilidade.dart';

/// A camada de disco do apoio: converte SharedPreferences em [EstadoApoio] e
/// grava os marcos de volta.
///
/// Fica separada de [Elegibilidade] de propósito. A regra é pura e testável sem
/// mock nenhum; aqui é só E/S, e o teste usa `setMockInitialValues`.
class ApoioPrefs {
  ApoioPrefs._();

  /// Milissegundos em um dia. Os marcos são gravados em epoch ms e comparados
  /// em dias corridos: fuso e horário de verão não mudam o resultado porque a
  /// conta é sempre diferença, nunca data civil.
  static const _msPorDia = 86400000;

  static Future<EstadoApoio> ler() async {
    final p = await SharedPreferences.getInstance();
    final agora = DateTime.now().millisecondsSinceEpoch;

    // Migração do gate antigo: `review_requested == true` era o booleano que
    // dizia "já pediu uma vez, nunca mais". Sem data, a única leitura honesta é
    // "pediu agora" — quem já viu o prompt espera os 120 dias em vez de levar
    // outro pedido no dia em que atualizar o app.
    var reviewMs = p.getInt(AppConstants.prefReviewPedidoMs);
    if (reviewMs == null &&
        (p.getBool(AppConstants.prefReviewRequested) ?? false)) {
      reviewMs = agora;
      await p.setInt(AppConstants.prefReviewPedidoMs, reviewMs);
    }

    return EstadoApoio(
      leiturasCompletas: p.getInt(AppConstants.prefLeiturasCompletas) ?? 0,
      sessoes: p.getInt(AppConstants.prefReviewSessionCount) ?? 0,
      diasDeUso:
          _dias(p.getInt(AppConstants.prefPrimeiraAberturaMs), agora) ?? 0,
      diasDesdeReview: _dias(reviewMs, agora),
      exposicoesApoio: p.getInt(AppConstants.prefApoioExposicoes) ?? 0,
      diasDesdeApoio: _dias(p.getInt(AppConstants.prefApoioMostradoMs), agora),
      diasDesdeFeedback:
          _dias(p.getInt(AppConstants.prefApoioFeedbackMs), agora),
      diasDesdeDispensaCard:
          _dias(p.getInt(AppConstants.prefApoioCardDispensadoMs), agora),
      apoiou: p.getBool(AppConstants.prefApoiou) ?? false,
      naoPerguntarMais: p.getBool(AppConstants.prefApoioNaoPerguntar) ?? false,
    );
  }

  /// Marca a abertura: soma uma sessão e registra a primeira de todas.
  /// Devolve o número da sessão atual (1 na primeira).
  static Future<int> registrarSessao() async {
    final p = await SharedPreferences.getInstance();
    final sessao = (p.getInt(AppConstants.prefReviewSessionCount) ?? 0) + 1;
    await p.setInt(AppConstants.prefReviewSessionCount, sessao);
    if (p.getInt(AppConstants.prefPrimeiraAberturaMs) == null) {
      await p.setInt(
        AppConstants.prefPrimeiraAberturaMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
    return sessao;
  }

  /// Leitura de fato — a que passou do piso de tempo em tela. Devolve o total.
  static Future<int> somarLeitura() async {
    final p = await SharedPreferences.getInstance();
    final total = (p.getInt(AppConstants.prefLeiturasCompletas) ?? 0) + 1;
    await p.setInt(AppConstants.prefLeiturasCompletas, total);
    return total;
  }

  static Future<void> marcarReviewPedido() => _marcarAgora(
        AppConstants.prefReviewPedidoMs,
      );

  /// Uma exposição do sheet: a data e o contador de 3 na vida.
  static Future<int> marcarApoioMostrado() async {
    final p = await SharedPreferences.getInstance();
    final n = (p.getInt(AppConstants.prefApoioExposicoes) ?? 0) + 1;
    await p.setInt(AppConstants.prefApoioExposicoes, n);
    await p.setInt(
      AppConstants.prefApoioMostradoMs,
      DateTime.now().millisecondsSinceEpoch,
    );
    return n;
  }

  static Future<void> marcarFeedback() =>
      _marcarAgora(AppConstants.prefApoioFeedbackMs);

  static Future<void> marcarCardDispensado() =>
      _marcarAgora(AppConstants.prefApoioCardDispensadoMs);

  static Future<void> marcarApoiou() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefApoiou, true);
  }

  static Future<void> marcarNaoPerguntarMais() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefApoioNaoPerguntar, true);
  }

  static Future<void> _marcarAgora(String chave) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(chave, DateTime.now().millisecondsSinceEpoch);
  }

  /// Dias corridos entre [marcoMs] e [agoraMs]. `null` entra, `null` sai: é
  /// assim que [Elegibilidade] distingue "nunca aconteceu" de "aconteceu hoje".
  ///
  /// Marco no futuro (relógio do aparelho ajustado para trás) devolve 0, não
  /// negativo: sem isso a trava de 120 dias viraria uma trava de 240.
  static int? _dias(int? marcoMs, int agoraMs) {
    if (marcoMs == null) return null;
    final dif = agoraMs - marcoMs;
    return dif <= 0 ? 0 : dif ~/ _msPorDia;
  }
}
