/// Quando o app pode pedir avaliação e quando pode pedir apoio.
///
/// Sem Flutter, sem SharedPreferences, sem UI: entra um retrato do que já
/// aconteceu, sai uma decisão. Os números moram todos aqui, num lugar só, e
/// `test/core/apoio/elegibilidade_test.dart` cobre cada bloqueio isolado.
///
/// A razão de ser uma classe pura é o histórico do app: o pedido de avaliação
/// vivia num `Future.delayed(10s)` dentro da tela de leitura e disparava no meio
/// do Salmo — inclusive na coleção de Luto. Regra espalhada por tela não dá para
/// auditar; esta dá.
library;

/// O que o app decide fazer quando a pessoa volta à Home.
///
/// No máximo um por sessão: avaliação e apoio nunca competem pela mesma volta.
enum Gatilho {
  /// Não pedir nada.
  nenhum,

  /// Prompt nativo da In-App Review. Nunca precedido de pergunta de opinião
  /// (é proibido pela política do Google Play).
  review,

  /// Sheet de apoio, começando pela pergunta de sentimento.
  apoio,
}

/// Retrato do que está gravado em disco. Dias são inteiros (já resolvidos pelo
/// chamador) para a regra não precisar de relógio nem de fuso.
class EstadoApoio {
  /// Leituras que passaram do piso de tempo em tela — não aberturas de tela.
  final int leiturasCompletas;

  /// Aberturas do app, contadas na splash.
  final int sessoes;

  /// Dias corridos desde a primeira abertura.
  final int diasDeUso;

  /// Dias desde o último pedido de avaliação. `null` = nunca pediu.
  final int? diasDesdeReview;

  /// Quantas vezes o sheet de apoio já foi mostrado nesta instalação.
  final int exposicoesApoio;

  /// Dias desde a última exibição do sheet. `null` = nunca mostrou.
  final int? diasDesdeApoio;

  /// Dias desde a resposta "Nem tanto". `null` = nunca respondeu.
  final int? diasDesdeFeedback;

  /// Dias desde o X no card da Home. `null` = nunca dispensou.
  final int? diasDesdeDispensaCard;

  /// Já apoiou — em qualquer valor, em qualquer momento.
  final bool apoiou;

  /// Tocou "Não perguntar de novo".
  final bool naoPerguntarMais;

  const EstadoApoio({
    this.leiturasCompletas = 0,
    this.sessoes = 0,
    this.diasDeUso = 0,
    this.diasDesdeReview,
    this.exposicoesApoio = 0,
    this.diasDesdeApoio,
    this.diasDesdeFeedback,
    this.diasDesdeDispensaCard,
    this.apoiou = false,
    this.naoPerguntarMais = false,
  });
}

/// O que vale só para esta volta à Home: a sessão e o evento que a causou.
class ContextoGatilho {
  /// Primeira sessão da instalação. Ninguém pede nada a quem acabou de chegar.
  final bool primeiraSessao;

  /// A sessão começou com um toque na notificação do Salmo do dia. A pessoa
  /// veio buscar uma coisa específica; não é hora de interromper.
  final bool porNotificacao;

  /// A leitura saiu de Luto, Ansiedade ou Sono, ou a pessoa passou pelo
  /// Respirar. Quem está nesses lugares não recebe pedido de dinheiro nem de
  /// nota na loja.
  final bool contextoSensivel;

  /// Avaliação já pedida nesta sessão.
  final bool reviewNestaSessao;

  /// Sheet de apoio já mostrado nesta sessão.
  final bool apoioNestaSessao;

  /// A leitura que acabou passou do piso de tempo em tela.
  final bool leituraConcluida;

  /// A narração chegou ao fim.
  final bool audioConcluido;

  const ContextoGatilho({
    this.primeiraSessao = false,
    this.porNotificacao = false,
    this.contextoSensivel = false,
    this.reviewNestaSessao = false,
    this.apoioNestaSessao = false,
    this.leituraConcluida = false,
    this.audioConcluido = false,
  });
}

class Elegibilidade {
  Elegibilidade._();

  // ── Avaliação ────────────────────────────────────────────────────────────
  static const int leiturasParaReview = 3;
  static const int diasParaReview = 3;

  /// A In-App Review só mostra o prompt algumas vezes por ano de qualquer
  /// forma; 120 dias é a nossa trava, independente da do Google.
  static const int diasEntreReviews = 120;

  // ── Apoio ────────────────────────────────────────────────────────────────
  static const int diasParaApoio = 7;
  static const int leiturasParaApoio = 10;
  static const int maxExposicoesApoio = 3;
  static const int diasEntreApoios = 90;

  /// "Nem tanto" e o X do card valem 90 dias de silêncio, igual a uma recusa.
  static const int diasDeSilencio = 90;

  /// Avaliação e apoio ficam longe um do outro mesmo entre sessões: dois
  /// pedidos na mesma semana lêem como cobrança, não como convite.
  static const int diasEntreReviewEApoio = 14;

  // ── Card da Home ─────────────────────────────────────────────────────────
  static const int diasParaCard = 7;

  /// A decisão da volta à Home.
  ///
  /// A avaliação tem prioridade quando as duas se qualificam: é o pedido mais
  /// barato para quem recebe e o mais raro (1x/120 dias).
  static Gatilho decidir({
    required EstadoApoio estado,
    required ContextoGatilho contexto,
  }) {
    if (podeReview(estado: estado, contexto: contexto)) return Gatilho.review;
    if (podeApoio(estado: estado, contexto: contexto)) return Gatilho.apoio;
    return Gatilho.nenhum;
  }

  static bool podeReview({
    required EstadoApoio estado,
    required ContextoGatilho contexto,
  }) {
    if (_bloqueado(contexto)) return false;
    if (!contexto.leituraConcluida && !contexto.audioConcluido) return false;
    if (contexto.apoioNestaSessao) return false;
    if (estado.leiturasCompletas < leiturasParaReview) return false;
    if (estado.diasDeUso < diasParaReview) return false;
    if (_passouMenosDe(estado.diasDesdeReview, diasEntreReviews)) return false;
    if (_passouMenosDe(estado.diasDesdeApoio, diasEntreReviewEApoio)) {
      return false;
    }
    return true;
  }

  static bool podeApoio({
    required EstadoApoio estado,
    required ContextoGatilho contexto,
  }) {
    if (estado.apoiou || estado.naoPerguntarMais) return false;
    if (_bloqueado(contexto)) return false;
    // Áudio não abre o sheet: ouvir com o telefone no bolso não é sinal de que
    // a pessoa está com o app na mão para decidir sobre dinheiro.
    if (!contexto.leituraConcluida) return false;
    if (contexto.reviewNestaSessao) return false;
    if (estado.leiturasCompletas < leiturasParaApoio) return false;
    if (estado.diasDeUso < diasParaApoio) return false;
    if (estado.exposicoesApoio >= maxExposicoesApoio) return false;
    if (_passouMenosDe(estado.diasDesdeApoio, diasEntreApoios)) return false;
    if (_passouMenosDe(estado.diasDesdeFeedback, diasDeSilencio)) return false;
    if (_passouMenosDe(estado.diasDesdeReview, diasEntreReviewEApoio)) {
      return false;
    }
    return true;
  }

  /// Card discreto da Home. Não depende da sessão nem do evento: ele não
  /// interrompe nada, fica parado abaixo do conteúdo.
  static bool mostrarCard(EstadoApoio estado) {
    if (estado.apoiou || estado.naoPerguntarMais) return false;
    if (estado.diasDeUso < diasParaCard) return false;
    if (_passouMenosDe(estado.diasDesdeDispensaCard, diasDeSilencio)) {
      return false;
    }
    // Quem disse "Nem tanto" não deveria reencontrar o pedido no dia seguinte
    // num outro formato: o silêncio vale para as duas superfícies.
    if (_passouMenosDe(estado.diasDesdeFeedback, diasDeSilencio)) return false;
    return true;
  }

  static bool _bloqueado(ContextoGatilho c) =>
      c.primeiraSessao || c.porNotificacao || c.contextoSensivel;

  /// `null` significa "nunca aconteceu", e aí nada barra.
  static bool _passouMenosDe(int? dias, int limite) =>
      dias != null && dias < limite;
}
