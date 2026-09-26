import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/apoio/apoio_service.dart';
import '../../core/apoio/compra_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/copy_apoio.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/services/link_service.dart';
import '../../core/theme/app_theme.dart';
import 'apoio_botao.dart';
import 'eyebrow_label.dart';

/// Sheet de apoio — os cinco estados da seção 11 do Design System.
///
/// Uma superfície só, três entradas: o gatilho depois da leitura (com a pergunta
/// de sentimento), o card da Home e a linha de Ajustes (as duas direto no passo
/// do valor). Antes disto existia um `_ApoieSheet` com chave Pix dentro de
/// `ajustes_screen.dart`, invisível para o resto do app.
///
/// Nenhum ramo daqui leva à Play Store. A política da In-App Review proíbe
/// perguntar opinião antes do prompt, e "Tem sim" + botão de avaliar é
/// exatamente isso.
///
/// Abre no passo do valor quando [comPergunta] é `false`.
Future<void> mostrarApoioSheet(
  BuildContext context, {
  required bool comPergunta,
  required CompraApoio compra,
  required String origem,
}) async {
  // Movimento zero quando o sistema pede movimento zero. O sheet aparece, não
  // desliza. Sem isto o `showModalBottomSheet` ignora `disableAnimations`.
  final semMovimento = MediaQuery.of(context).disableAnimations;
  final controlador = semMovimento
      ? (BottomSheet.createAnimationController(Navigator.of(context))
        ..duration = Duration.zero
        ..reverseDuration = Duration.zero)
      : null;

  try {
    final respondeu = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.colorSurface,
      // O conteúdo manda na altura, e rola quando a fonte do sistema estoura os
      // 92% — nunca o contrário.
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      transitionAnimationController: controlador,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => ApoioSheet(
        comPergunta: comPergunta,
        compra: compra,
        origem: origem,
      ),
    );

    // Arrastar para baixo, tocar fora e o botão voltar equivalem a "Agora não" e
    // contam como recusa. Vindo do card ou de Ajustes não há pergunta a recusar,
    // então o sheet devolve `true` na abertura e nada é logado.
    if (respondeu != true) ApoioService.instance.registrarRecusa();
  } finally {
    controlador?.dispose();
    compra.dispose();
  }
}

enum _Passo { pergunta, valores, obrigado, erro, feedback }

class ApoioSheet extends StatefulWidget {
  final bool comPergunta;
  final CompraApoio compra;

  /// De onde o sheet foi aberto: `gatilho`, `card` ou `ajustes`. Vai para o
  /// `feedback_email_opened` — a sugestão de quem foi interrompido depois de
  /// uma leitura não é a mesma coisa que a de quem procurou o item em Ajustes.
  final String origem;

  const ApoioSheet({
    super.key,
    required this.comPergunta,
    required this.compra,
    this.origem = 'sheet',
  });

  @override
  State<ApoioSheet> createState() => _ApoioSheetState();
}

class _ApoioSheetState extends State<ApoioSheet> {
  late _Passo _passo;

  /// `null` enquanto a loja não respondeu. Vazio = produtos não publicados ou
  /// Play indisponível, e aí o passo do valor não tem o que mostrar.
  List<ProdutoApoio>? _produtos;
  String? _selecionado;
  bool _comprando = false;

  /// `true` quando dá para afirmar que nada foi cobrado. Ver [CopyApoio].
  bool _erroNadaCobrado = true;

  /// Mensagem de cancelamento sobre o próprio sheet. Cancelar não é erro e não
  /// merece um painel novo.
  String? _aviso;

  /// Já houve resposta explícita à pergunta — impede que o fechamento vire um
  /// segundo evento de recusa.
  late bool _respondeu;

  @override
  void initState() {
    super.initState();
    _passo = widget.comPergunta ? _Passo.pergunta : _Passo.valores;
    _respondeu = !widget.comPergunta;
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final lista = await widget.compra.produtos();
    if (!mounted) return;
    setState(() {
      _produtos = lista;
      _selecionado = _padrao(lista);
      // Sem produto não há como mostrar preço, e o preço nunca é hardcoded.
      // Nada foi cobrado aqui: o fluxo não chegou perto da cobrança.
      if (lista.isEmpty && _passo == _Passo.valores) {
        _erroNadaCobrado = true;
        _passo = _Passo.erro;
      }
    });
  }

  /// R$ 10 pré-selecionado. Se o id padrão não vier da loja, o do meio da lista.
  static String? _padrao(List<ProdutoApoio> lista) {
    if (lista.isEmpty) return null;
    for (final p in lista) {
      if (p.id == kProdutoApoioPadrao) return p.id;
    }
    return lista[lista.length ~/ 2].id;
  }

  ProdutoApoio? get _produtoSelecionado {
    final lista = _produtos;
    if (lista == null) return null;
    for (final p in lista) {
      if (p.id == _selecionado) return p;
    }
    return null;
  }

  // ── Ações ────────────────────────────────────────────────────────────────

  void _irParaValores() {
    _respondeu = true;
    ApoioService.instance.registrarTemSim();
    setState(() {
      if (_produtos != null && _produtos!.isEmpty) {
        _erroNadaCobrado = true;
        _passo = _Passo.erro;
      } else {
        _passo = _Passo.valores;
      }
    });
  }

  Future<void> _irParaFeedback() async {
    _respondeu = true;
    await ApoioService.instance.registrarNemTanto();
    if (!mounted) return;
    setState(() => _passo = _Passo.feedback);
  }

  void _selecionar(ProdutoApoio p) {
    HapticFeedback.selectionClick();
    AnalyticsService.instance.logSupportValueSelected(p.id);
    setState(() => _selecionado = p.id);
  }

  Future<void> _comprar() async {
    final produto = _produtoSelecionado;
    if (produto == null || _comprando) return;
    setState(() {
      _comprando = true;
      _aviso = null;
    });

    final r = await widget.compra.comprar(produto);
    if (!mounted) return;
    setState(() => _comprando = false);

    switch (r.resultado) {
      case ResultadoApoio.concluido:
        await ApoioService.instance.registrarApoio(produto.id);
        if (!mounted) return;
        setState(() => _passo = _Passo.obrigado);
      case ResultadoApoio.cancelado:
        AnalyticsService.instance.logSupportPurchaseCanceled();
        _mostrarAviso(CopyApoio.canceladoSnack);
      case ResultadoApoio.erroNadaCobrado:
      case ResultadoApoio.erroIndeterminado:
        AnalyticsService.instance
            .logSupportPurchaseError(r.codigo ?? 'desconhecido');
        setState(() {
          _erroNadaCobrado = r.resultado == ResultadoApoio.erroNadaCobrado;
          _passo = _Passo.erro;
        });
    }
  }

  void _mostrarAviso(String texto) {
    setState(() => _aviso = texto);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _aviso == texto) setState(() => _aviso = null);
    });
  }

  Future<void> _compartilhar() async {
    AnalyticsService.instance.logSupportShare();
    try {
      await SharePlus.instance.share(ShareParams(
        text: '${CopyApoio.apoioCompartilharTexto}\n\n'
            '${AppConstants.siteBaseUrl}',
      ));
    } catch (_) {
      // Cancelamento do share sheet nativo — silencioso, como no compositor.
    }
  }

  Future<void> _enviarSugestao() async {
    AnalyticsService.instance.logFeedbackEmailOpened(widget.origem);
    await LinkService.instance.abrir(Uri(
      scheme: 'mailto',
      path: AppConstants.emailContato,
      queryParameters: {
        'subject': CopyApoio.feedbackAssunto,
        'body': CopyApoio.feedbackCorpoEmail,
      },
    ));
    if (mounted) Navigator.of(context).pop(_respondeu);
  }

  void _fechar() => Navigator.of(context).pop(_respondeu);

  // ── Render ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final aviso = _aviso;

    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.sp5,
              AppTheme.sp3,
              AppTheme.sp5,
              AppTheme.sp8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Alca(),
                ..._conteudo(),
              ],
            ),
          ),
        ),
        if (aviso != null)
          Positioned(
            left: AppTheme.sp4,
            right: AppTheme.sp4,
            bottom: AppTheme.sp4,
            child: _AvisoApoio(texto: aviso),
          ),
      ],
    );
  }

  List<Widget> _conteudo() => switch (_passo) {
        _Passo.pergunta => [
            const EyebrowLabel(CopyApoio.perguntaEyebrow),
            const SizedBox(height: AppTheme.sp3),
            const _Titulo(CopyApoio.perguntaTitulo),
            const SizedBox(height: AppTheme.sp5),
            _Acoes([
              BotaoApoio(
                rotulo: CopyApoio.perguntaSim,
                onTap: _irParaValores,
              ),
              BotaoApoio(
                rotulo: CopyApoio.perguntaNao,
                estilo: EstiloApoio.contorno,
                onTap: _irParaFeedback,
              ),
              BotaoApoio(
                rotulo: CopyApoio.agoraNao,
                estilo: EstiloApoio.texto,
                onTap: _fechar,
              ),
            ]),
          ],

        _Passo.valores => [
            const EyebrowLabel(CopyApoio.apoioEyebrow),
            const SizedBox(height: AppTheme.sp3),
            const _Titulo(CopyApoio.apoioTitulo),
            const SizedBox(height: AppTheme.sp3),
            const _Corpo(CopyApoio.apoioCorpo),
            const SizedBox(height: AppTheme.sp5),
            if (_produtos == null)
              const _Carregando()
            else
              _ListaDeValores(
                produtos: _produtos!,
                selecionado: _selecionado,
                onSelecionar: _selecionar,
              ),
            const SizedBox(height: AppTheme.sp3),
            const _Nota(CopyApoio.apoioNota),
            const SizedBox(height: AppTheme.sp4),
            _Acoes([
              BotaoApoio(
                rotulo: CopyApoio.apoioCta(
                  _produtoSelecionado?.precoFormatado ?? '',
                ),
                ocupado: _comprando,
                onTap: _produtoSelecionado == null ? null : _comprar,
              ),
              BotaoApoio(
                rotulo: CopyApoio.apoioCompartilhar,
                estilo: EstiloApoio.contorno,
                onTap: _comprando ? null : _compartilhar,
              ),
              BotaoApoio(
                rotulo: CopyApoio.agoraNao,
                estilo: EstiloApoio.texto,
                onTap: _comprando ? null : _fechar,
              ),
            ]),
          ],

        _Passo.obrigado => [
            const _Titulo(CopyApoio.obrigadoTitulo),
            const SizedBox(height: AppTheme.sp3),
            const _Corpo(CopyApoio.obrigadoCorpo),
            const SizedBox(height: AppTheme.sp5),
            _Acoes([
              BotaoApoio(rotulo: CopyApoio.fechar, onTap: _fechar),
            ]),
          ],

        _Passo.erro => [
            const _Titulo(CopyApoio.erroTitulo),
            const SizedBox(height: AppTheme.sp3),
            _Corpo(_erroNadaCobrado
                ? CopyApoio.erroCorpoNadaCobrado
                : CopyApoio.erroCorpoNeutro),
            const SizedBox(height: AppTheme.sp5),
            _Acoes([
              BotaoApoio(
                rotulo: CopyApoio.erroTentarNovamente,
                ocupado: _comprando,
                onTap: _tentarNovamente,
              ),
              BotaoApoio(
                rotulo: CopyApoio.fechar,
                estilo: EstiloApoio.texto,
                onTap: _fechar,
              ),
            ]),
          ],

        _Passo.feedback => [
            const _Titulo(CopyApoio.feedbackTitulo),
            const SizedBox(height: AppTheme.sp3),
            const _Corpo(CopyApoio.feedbackCorpo),
            const SizedBox(height: AppTheme.sp5),
            _Acoes([
              BotaoApoio(rotulo: CopyApoio.feedbackCta, onTap: _enviarSugestao),
              BotaoApoio(
                rotulo: CopyApoio.agoraNao,
                estilo: EstiloApoio.texto,
                onTap: _fechar,
              ),
            ]),
          ],
      };

  Future<void> _tentarNovamente() async {
    // Produto nenhum carregado: o problema foi a consulta à loja, então é ela
    // que se repete, não a cobrança.
    if (_produtos == null || _produtos!.isEmpty) {
      setState(() {
        _produtos = null;
        _passo = _Passo.valores;
      });
      await _carregarProdutos();
      return;
    }
    setState(() => _passo = _Passo.valores);
    await _comprar();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Peças do sheet
// ─────────────────────────────────────────────────────────────────────────────

class _Alca extends StatelessWidget {
  const _Alca();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: AppTheme.sp5),
          decoration: BoxDecoration(
            color: context.colorBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.25,
          letterSpacing: -0.24,
          color: context.colorTitle,
        ),
      );
}

class _Corpo extends StatelessWidget {
  final String texto;
  const _Corpo(this.texto);

  @override
  Widget build(BuildContext context) =>
      Text(texto, style: AppTheme.bodyRelaxed15(context.colorText));
}

/// A nota de pagamento.
///
/// Cor: `colorText` (night-text 6.05:1 / day-text 8.19:1 sobre a superfície).
/// NÃO pode ser muted — muted sobre a superfície dá 4.53:1, passa raspando.
/// Tamanho: 14px, e não os 13px do mock. É texto de decisão — diz o que a pessoa
/// recebe pelo dinheiro —, e o piso de decisão do DS v1.2 é 14.
class _Nota extends StatelessWidget {
  final String texto;
  const _Nota(this.texto);

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          height: 1.5,
          color: context.colorText,
        ),
      );
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp6),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: context.colorAccentText,
          ),
        ),
      );
}

/// Botões empilhados, largura do container.
///
/// Nunca em `Row` com `Expanded`: em 2.0x dois botões lado a lado cortam o
/// rótulo, e a regra do DS é explícita sobre partes iguais.
class _Acoes extends StatelessWidget {
  final List<Widget> botoes;
  const _Acoes(this.botoes);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < botoes.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTheme.sp2),
            botoes[i],
          ],
        ],
      );
}

/// Lista de valores com radio — obrigatoriamente lista.
///
/// Três colunas iguais (SegmentedButton, chips em Expanded) truncam "R$ 25" com
/// a fonte do sistema em 2.0x. A lista só cresce na altura. Linha de 56dp, alvo
/// de toque na largura inteira, radio de 20px na cor muted (5.22:1 escuro /
/// 6.17:1 claro — é elemento não textual, o piso é 3:1).
class _ListaDeValores extends StatelessWidget {
  final List<ProdutoApoio> produtos;
  final String? selecionado;
  final ValueChanged<ProdutoApoio> onSelecionar;

  const _ListaDeValores({
    required this.produtos,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: CopyApoio.apoioValoresLabel,
        child: Container(
          decoration: BoxDecoration(
            color: context.colorBg,
            border: Border.all(color: context.colorBorder, width: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < produtos.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: context.colorBorder,
                  ),
                _LinhaDeValor(
                  produto: produtos[i],
                  selecionado: produtos[i].id == selecionado,
                  onTap: () => onSelecionar(produtos[i]),
                ),
              ],
            ],
          ),
        ),
      );
}

class _LinhaDeValor extends StatelessWidget {
  final ProdutoApoio produto;
  final bool selecionado;
  final VoidCallback onTap;

  const _LinhaDeValor({
    required this.produto,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentText = context.colorAccentText;

    return MergeSemantics(
      child: Semantics(
        // Sem isto o TalkBack não anuncia "1 de 3" nem o estado escolhido.
        inMutuallyExclusiveGroup: true,
        selected: selecionado,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp4,
                vertical: AppTheme.sp3,
              ),
              child: Row(
                children: [
                  _Radio(selecionado: selecionado),
                  const SizedBox(width: AppTheme.sp3),
                  Expanded(
                    child: Text(
                      produto.precoFormatado,
                      style: AppTheme.body15(
                        selecionado ? accentText : context.colorText,
                      ).copyWith(
                        fontWeight:
                            selecionado ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selecionado;
  const _Radio({required this.selecionado});

  @override
  Widget build(BuildContext context) {
    final accentText = context.colorAccentText;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selecionado ? accentText : context.colorMuted,
          width: 1.5,
        ),
      ),
      child: selecionado
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: accentText),
              ),
            )
          : null,
    );
  }
}

/// Aviso de cancelamento, sobre o próprio sheet.
///
/// Não é um `SnackBar` do Material de propósito: o ScaffoldMessenger desenha
/// dentro do Scaffold, que fica ABAIXO da rota do bottom sheet — a mensagem
/// apareceria escondida atrás do painel.
class _AvisoApoio extends StatelessWidget {
  final String texto;
  const _AvisoApoio({required this.texto});

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp4,
            vertical: AppTheme.sp3 + 2,
          ),
          decoration: BoxDecoration(
            color: context.colorBg,
            border: Border.all(color: context.colorBorder, width: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: const [
              BoxShadow(
                color: Color(0x73040610),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Text(
            texto,
            style: AppTheme.caption14(context.colorTitle).copyWith(height: 1.45),
          ),
        ),
      );
}
