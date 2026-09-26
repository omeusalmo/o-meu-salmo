import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Os três papéis de botão da seção 11 do Design System.
enum EstiloApoio {
  /// Preenchimento cobalt-500 com creme por cima (6.08:1 nos dois modos).
  preenchido,

  /// Contorno no acento de TEXTO (5.50:1 escuro / 5.56:1 claro).
  contorno,

  /// Botão de texto na cor de texto. É a saída ("Agora não", "Fechar").
  texto,
}

/// Botão do fluxo de apoio.
///
/// Três regras duras do DS moram aqui, e não em cada chamada:
/// piso de 48dp de altura, largura do container (nunca fixa, nunca dividida em
/// partes iguais com o botão vizinho) e rótulo de 15px que cresce com a fonte do
/// sistema em vez de ser cortado.
///
/// [larguraTotal] só é `false` no card da Home, onde o botão é discreto e se
/// ajusta ao rótulo.
class BotaoApoio extends StatelessWidget {
  final String rotulo;
  final VoidCallback? onTap;
  final EstiloApoio estilo;
  final bool larguraTotal;

  /// Troca o rótulo por um indicador enquanto a loja responde. Mantém a altura,
  /// então o sheet não pula.
  final bool ocupado;

  const BotaoApoio({
    super.key,
    required this.rotulo,
    required this.onTap,
    this.estilo = EstiloApoio.preenchido,
    this.larguraTotal = true,
    this.ocupado = false,
  });

  @override
  Widget build(BuildContext context) {
    final preenchido = estilo == EstiloApoio.preenchido;
    final corDoRotulo = switch (estilo) {
      EstiloApoio.preenchido => AppColors.nightCream,
      EstiloApoio.contorno => context.colorAccentText,
      EstiloApoio.texto => context.colorText,
    };

    // Ocupado: o rótulo sai da tela mas não do TalkBack, senão o botão vira um
    // "botão" sem nome no meio da compra.
    final filho = ocupado
        ? Semantics(
            label: rotulo,
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: corDoRotulo,
              ),
            ),
          )
        : Text(
            rotulo,
            textAlign: TextAlign.center,
            style: AppTheme.body15(corDoRotulo)
                .copyWith(fontWeight: FontWeight.w500, height: 1.3),
          );

    // MergeSemantics + Semantics(button:), e NÃO excludeSemantics: excluir o
    // filho derrubaria junto a ação de toque do InkWell, e o TalkBack anunciaria
    // um botão que ele não sabe acionar. O rótulo vem do próprio conteúdo.
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: preenchido ? context.colorAccentFill : Colors.transparent,
          shape: StadiumBorder(
            side: estilo == EstiloApoio.contorno
                ? BorderSide(color: context.colorAccentText, width: 1)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Container(
              width: larguraTotal ? double.infinity : null,
              // minHeight, não height: em 2.0x o rótulo vira duas linhas e o
              // botão precisa crescer em vez de cortar.
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp6,
                vertical: AppTheme.sp3,
              ),
              alignment: Alignment.center,
              child: filho,
            ),
          ),
        ),
      ),
    );
  }
}
