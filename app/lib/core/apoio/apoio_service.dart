import 'package:flutter/foundation.dart';

import '../analytics/analytics_service.dart';
import '../review/review_service.dart';
import 'apoio_prefs.dart';
import 'elegibilidade.dart';

/// Orquestra apoio e avaliação: junta o que está em disco ([ApoioPrefs]), o que
/// vale só nesta sessão e a regra pura ([Elegibilidade]).
///
/// O que mudou em relação ao que havia antes: o pedido de avaliação era um
/// `Future.delayed(10s)` dentro de `leitura_salmo_screen.dart` e caía no meio da
/// leitura, inclusive na coleção de Luto. Agora nada dispara durante o conteúdo.
/// O único momento de pedido é a volta à Home depois de uma leitura ou de uma
/// narração concluída, e mesmo aí passa pelos bloqueios.
class ApoioService {
  ApoioService();

  /// Trocável em teste (mesmo padrão de LinkService/ReviewService).
  static ApoioService instance = ApoioService();

  // ── Estado de sessão. Morre com o processo, de propósito. ────────────────
  int _sessao = 0;
  bool _porNotificacao = false;
  bool _sensivelNaSessao = false;
  bool _reviewNestaSessao = false;
  bool _apoioNestaSessao = false;

  /// Leitura concluída esperando a volta à Home. `null` = nada a fazer.
  _EventoLeitura? _pendente;

  /// Bate a cada leitura concluída. A Home ouve e reavalia quando volta a ser a
  /// tela visível — é o que substitui o timer que rodava dentro do Salmo.
  final ValueNotifier<int> volta = ValueNotifier<int>(0);

  bool get primeiraSessao => _sessao == 1;

  /// Há uma leitura concluída esperando a volta à Home.
  bool get temPendente => _pendente != null;

  /// Chamado na splash, uma vez por abertura.
  Future<void> iniciarSessao() async {
    _sessao = await ApoioPrefs.registrarSessao();
  }

  /// A sessão começou com um toque na notificação do Salmo do dia.
  ///
  /// Único funil: `main.dart` chama isto no mesmo lugar em que loga
  /// `notif_opened`, cobrindo app vivo e app morto.
  void marcarAberturaPorNotificacao() => _porNotificacao = true;

  /// A pessoa passou pelo Respirar. Bloqueia a sessão inteira: quem procura um
  /// minuto de pausa não recebe pedido de dinheiro na saída.
  void marcarRespirar() => _sensivelNaSessao = true;

  /// Uma tela de leitura foi fechada.
  ///
  /// [leituraConcluida] já vem decidido pelo piso de tempo em tela da própria
  /// tela — é o mesmo critério de `psalm_read_complete`, para o contador do
  /// apoio e a métrica de ativação nunca divergirem.
  /// [sensivel] = o Salmo pertence a Luto, Ansiedade ou Sono.
  Future<void> registrarLeitura({
    required bool leituraConcluida,
    required bool audioConcluido,
    required bool sensivel,
  }) async {
    if (sensivel) _sensivelNaSessao = true;
    if (leituraConcluida) await ApoioPrefs.somarLeitura();
    if (!leituraConcluida && !audioConcluido) return;
    _pendente = _EventoLeitura(
      leituraConcluida: leituraConcluida,
      audioConcluido: audioConcluido,
    );
    volta.value++;
  }

  /// A Home voltou a ser a tela visível. Devolve o que fazer.
  ///
  /// [Gatilho.review] já foi executado aqui (o prompt é nativo, não tem UI
  /// nossa). [Gatilho.apoio] é só a decisão: quem abre o sheet é o widget, que é
  /// quem tem BuildContext.
  Future<Gatilho> aoVoltarParaHome() async {
    final evento = _pendente;
    if (evento == null) return Gatilho.nenhum;
    _pendente = null;

    final estado = await ApoioPrefs.ler();
    final contexto = ContextoGatilho(
      primeiraSessao: primeiraSessao,
      porNotificacao: _porNotificacao,
      contextoSensivel: _sensivelNaSessao,
      reviewNestaSessao: _reviewNestaSessao,
      apoioNestaSessao: _apoioNestaSessao,
      leituraConcluida: evento.leituraConcluida,
      audioConcluido: evento.audioConcluido,
    );

    switch (Elegibilidade.decidir(estado: estado, contexto: contexto)) {
      case Gatilho.review:
        // Indisponível (sem Play Services, cota do Google estourada): não gasta
        // a trava de 120 dias num pedido que não apareceu.
        if (!await ReviewService.instance.disponivel()) return Gatilho.nenhum;
        _reviewNestaSessao = true;
        await ApoioPrefs.marcarReviewPedido();
        AnalyticsService.instance.logReviewPromptRequested(
          sessionCount: estado.sessoes,
          reads: estado.leiturasCompletas,
        );
        await ReviewService.instance.pedirAvaliacao();
        return Gatilho.review;

      case Gatilho.apoio:
        _apoioNestaSessao = true;
        final n = await ApoioPrefs.marcarApoioMostrado();
        AnalyticsService.instance
            .logSupportPromptShown(surface: 'sheet', exposureN: n);
        return Gatilho.apoio;

      case Gatilho.nenhum:
        return Gatilho.nenhum;
    }
  }

  /// O card discreto da Home deve aparecer?
  Future<bool> mostrarCard() async =>
      Elegibilidade.mostrarCard(await ApoioPrefs.ler());

  /// Card exibido — evento de analytics, sem gastar exposição do sheet.
  /// O card não interrompe nada, então não entra no teto de 3 na vida.
  void registrarCardExibido() => AnalyticsService.instance
      .logSupportPromptShown(surface: 'card', exposureN: 0);

  /// X do card. Soma 90 dias de silêncio.
  ///
  /// ⚠️ A seção 11 do design-system.html diz "dispensa de vez"; a decisão de
  /// produto de 2026-09-26 diz 90 dias. Vale a de produto. Se mudar, é uma linha
  /// aqui e a constante `Elegibilidade.diasDeSilencio`.
  Future<void> dispensarCard() async {
    AnalyticsService.instance.logSupportPromptAnswer('dismiss');
    await ApoioPrefs.marcarCardDispensado();
  }

  /// Fechou o sheet sem responder (arrastar, tocar fora, botão voltar, "Agora
  /// não"). Conta como recusa: a trava de 90 dias já foi gravada na exibição.
  void registrarRecusa() =>
      AnalyticsService.instance.logSupportPromptAnswer('dismiss');

  /// Respondeu "Nem tanto": vai para o e-mail e espera 90 dias.
  Future<void> registrarNemTanto() async {
    AnalyticsService.instance.logSupportPromptAnswer('no');
    await ApoioPrefs.marcarFeedback();
  }

  void registrarTemSim() =>
      AnalyticsService.instance.logSupportPromptAnswer('yes');

  /// Apoiou. Nunca mais vê card nem sheet.
  Future<void> registrarApoio(String produtoId) async {
    AnalyticsService.instance.logSupportPurchaseCompleted(produtoId);
    await ApoioPrefs.marcarApoiou();
  }

  /// "Não perguntar de novo" — nunca mais card nem sheet.
  ///
  /// ⚠️ A regra existe e está coberta por teste, mas NÃO há superfície na UI:
  /// a copy aprovada em 2026-09-26 não tem esse botão em nenhum dos estados do
  /// sheet, e inventar um seria mexer em copy que já passou por marketing, UX
  /// writing e design. Fica pronto para o dia em que houver decisão.
  Future<void> registrarNaoPerguntarMais() async {
    AnalyticsService.instance.logSupportPromptAnswer('never');
    await ApoioPrefs.marcarNaoPerguntarMais();
  }
}

class _EventoLeitura {
  final bool leituraConcluida;
  final bool audioConcluido;
  const _EventoLeitura({
    required this.leituraConcluida,
    required this.audioConcluido,
  });
}
