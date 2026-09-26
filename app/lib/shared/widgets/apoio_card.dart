import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/apoio/apoio_service.dart';
import '../../core/apoio/compra_service.dart';
import '../../core/constants/copy_apoio.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import 'apoio_botao.dart';
import 'apoio_sheet.dart';
import 'eyebrow_label.dart';

/// Card discreto de apoio na Home.
///
/// Contorno e fundo transparente, nunca preenchido: ele não pode competir com o
/// Salmo do dia, que é o motivo de a pessoa ter aberto o app. Fica abaixo do
/// conteúdo, sempre.
///
/// Tocar em "Apoiar o app" abre o passo do valor direto — quem toca num card que
/// já diz "apoie o app" não precisa da pergunta de sentimento antes.
class ApoioCardHome extends StatefulWidget {
  /// Chamado depois do X, para a Home tirar o card da árvore.
  final VoidCallback onDispensar;

  /// Injetável em teste. Em produção é o Google Play Billing.
  final CompraApoio Function()? criarCompra;

  const ApoioCardHome({
    super.key,
    required this.onDispensar,
    this.criarCompra,
  });

  @override
  State<ApoioCardHome> createState() => _ApoioCardHomeState();
}

class _ApoioCardHomeState extends State<ApoioCardHome> {
  @override
  void initState() {
    super.initState();
    ApoioService.instance.registrarCardExibido();
  }

  Future<void> _abrir() async {
    HapticFeedback.selectionClick();
    await mostrarApoioSheet(
      context,
      comPergunta: false,
      compra: (widget.criarCompra ?? CompraApoioPlay.new)(),
      origem: 'card',
    );
    // Apoiou pelo card: o card não deveria continuar na tela.
    if (mounted && await ApoioService.instance.mostrarCard() == false) {
      widget.onDispensar();
    }
  }

  Future<void> _dispensar() async {
    HapticFeedback.lightImpact();
    await ApoioService.instance.dispensarCard();
    widget.onDispensar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colorBorder, width: 0.5),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.sp5,
              AppTheme.sp4,
              AppTheme.sp5,
              AppTheme.sp4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel(CopyApoio.cardEyebrow),
                const SizedBox(height: AppTheme.sp2),
                Padding(
                  // Abre espaço para o X sem largura fixa: o título quebra antes
                  // de passar por baixo do botão.
                  padding: const EdgeInsets.only(right: AppTheme.sp10),
                  child: Text(
                    CopyApoio.cardTitulo,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: context.colorTitle,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.sp1 + 2),
                Text(
                  CopyApoio.cardCorpo,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    height: 1.55,
                    color: context.colorText,
                  ),
                ),
                const SizedBox(height: AppTheme.sp4),
                // Alinha à esquerda e não ocupa a linha inteira: o botão de
                // largura total é do Salmo do dia, não deste card.
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotaoApoio(
                    rotulo: CopyApoio.cardCta,
                    estilo: EstiloApoio.contorno,
                    larguraTotal: false,
                    onTap: _abrir,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            // MergeSemantics junta o rótulo com a ação de toque num nó só.
            // excludeSemantics derrubaria a ação junto com o ícone.
            child: MergeSemantics(
              child: Semantics(
                label: CopyApoio.cardDispensar,
                button: true,
                child: InkWell(
                  onTap: _dispensar,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    // 48dp, o mínimo do DS — não o tamanho do ícone.
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: context.colorText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
