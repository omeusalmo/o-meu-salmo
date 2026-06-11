import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Uma linha de versículo com número superscrito à esquerda.
///
/// [destaque] aplica a cor âmbar (--gold / --gold-ink) ao versículo ativo.
/// Conforme DS: corpo em Cormorant Italic ≥18px, lh 1.65.
/// Âmbar NUNCA é usado como cor de UI — somente em versículo em destaque.
class VerseLine extends StatelessWidget {
  final int numero;
  final String texto;
  final bool destaque;

  const VerseLine({
    super.key,
    required this.numero,
    required this.texto,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final verseColor = destaque
        ? (isDark ? AppColors.gold : AppColors.goldInk)
        : context.colorText;

    final numColor = context.colorAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '$numero',
                style: GoogleFonts.instrumentSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: numColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.cormorant(
                fontSize: 19,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: verseColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
