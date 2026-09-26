/// Toda a copy da feature de apoio e de avaliação, num arquivo só.
///
/// O app não tem l10n hoje e as strings vivem soltas dentro dos widgets. Aqui
/// não: centralizar é o que transforma a extração para ARB, no dia em que o EN
/// entrar, numa mudança mecânica em vez de uma varredura por 40 arquivos.
///
/// Copy final aprovada em 2026-09-26 (marketing + UX writing, pós no-ai-slop).
/// Não editar sem passar pelo mesmo caminho: `ui_kits/app/modal-apoio.html` e a
/// seção 11 do design-system.html são a referência.
class CopyApoio {
  CopyApoio._();

  // ── 1 · Pergunta de sentimento ───────────────────────────────────────────
  static const perguntaEyebrow = 'Uma pergunta';
  static const perguntaTitulo = 'O meu Salmo tem feito companhia a você?';
  static const perguntaSim = 'Tem sim';
  static const perguntaNao = 'Nem tanto';

  /// Saída de qualquer passo. Arrastar para baixo, tocar fora e o botão voltar
  /// do sistema equivalem a isto.
  static const agoraNao = 'Agora não';

  // ── 2 · Apoio ────────────────────────────────────────────────────────────
  static const apoioEyebrow = 'Apoio';
  static const apoioTitulo = 'Que bom saber.';
  static const apoioCorpo =
      'O app é gratuito, sem anúncios e sem cadastro, e quem faz é uma pessoa '
      'só. Se ele ajudou você, um apoio único mantém tudo gratuito para quem '
      'chegar aqui numa noite difícil.';
  static const apoioNota =
      'Pagamento único pelo Google Play. Não libera nada novo no app.';
  static const apoioValoresLabel = 'Valor do apoio';

  /// O preço vem de `ProductDetails.formattedPrice`, nunca de constante.
  static String apoioCta(String precoFormatado) =>
      'Apoiar com $precoFormatado';
  static const apoioCompartilhar = 'Enviar o app para alguém';

  /// Texto do compartilhamento nativo.
  static const apoioCompartilharTexto =
      'O meu Salmo — 150 Salmos com áudio, sem anúncios e sem cadastro.';

  // ── 3a · Obrigado ────────────────────────────────────────────────────────
  static const obrigadoTitulo = 'Obrigado.';
  static const obrigadoCorpo =
      'Seu apoio mantém o app gratuito para a próxima pessoa.';
  static const fechar = 'Fechar';

  // ── 3b · Cancelado ───────────────────────────────────────────────────────
  /// Snackbar sobre o próprio sheet. Cancelar não é erro e não merece painel.
  static const canceladoSnack = 'Apoio cancelado. Nada foi cobrado.';

  // ── 3c · Erro ────────────────────────────────────────────────────────────
  static const erroTitulo = 'Não foi possível concluir.';

  /// Só para os códigos em que o fluxo comprovadamente não chegou à cobrança
  /// (ver `CodigoErroApoio.nadaFoiCobrado`). Afirmar isto sem garantia seria
  /// mentir para quem acabou de ser debitado.
  static const erroCorpoNadaCobrado =
      'Nada foi cobrado. Verifique a conexão e tente de novo.';

  /// Quando não há como saber se houve cobrança: pendência do Billing, compra
  /// já existente e falha genérica. Neutra de propósito.
  static const erroCorpoNeutro =
      'Verifique a conexão e tente de novo. Se algum valor tiver sido cobrado, '
      'ele aparece no histórico de compras do Google Play.';
  static const erroTentarNovamente = 'Tentar novamente';

  // ── 2b · Ramo "Nem tanto" ────────────────────────────────────────────────
  static const feedbackTitulo = 'Obrigado pela sinceridade. O que faltou?';
  static const feedbackCorpo = 'Sua mensagem vai por e-mail.';
  static const feedbackCta = 'Enviar sugestão';
  static const feedbackAssunto = 'O que faltou — O meu Salmo';
  static const feedbackCorpoEmail = 'Olá,\n\nO que senti falta no app:\n\n';

  // ── Card da Home ─────────────────────────────────────────────────────────
  static const cardEyebrow = 'Apoie o app';
  static const cardTitulo = 'O meu Salmo é gratuito';
  static const cardCorpo =
      'Sem anúncios e sem assinatura. Se ele faz parte do seu dia, você pode '
      'ajudar a mantê-lo assim.';
  static const cardCta = 'Apoiar o app';
  static const cardDispensar = 'Dispensar';

  // ── Ajustes ──────────────────────────────────────────────────────────────
  static const ajustesAvaliar = 'Avaliar na Play Store';
  static const ajustesAvaliarApoio =
      'Conte o que achou. Isso ajuda outras pessoas a encontrar o app.';
  static const ajustesApoiar = 'Apoiar o app';
  static const ajustesApoiarApoio = 'Valor único, sem assinatura.';

  /// A loja não abriu (device sem Play Store, link bloqueado).
  static const avaliarFalhou = 'Não foi possível abrir a Play Store.';

  // ── Nunca mais ───────────────────────────────────────────────────────────
  static const naoPerguntarMais = 'Não perguntar de novo';
}
