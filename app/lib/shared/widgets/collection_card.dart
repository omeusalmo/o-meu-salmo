import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Card de coleção temática — título Playfair + subtítulo Cormorant + emotion dot.
class CollectionCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final int totalSalmos;
  final String? emocaoId;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.totalSalmos,
    required this.onTap,
    this.emocaoId,
  });

  // Mapeia o id da coleção para a cor emocional do design system.
  static Color _emotionColor(String? id, bool isDark) {
    switch (id) {
      case 'ansiedade': return AppColors.emoAnsiedadeDot;
      case 'sono':
      case 'protecao':  return AppColors.emoPazDot;
      case 'gratidao':
      case 'louvor':    return AppColors.emoGratidaoDot;
      case 'luto':      return AppColors.emoLutoDot;
      case 'perdao':    return AppColors.emoDuvidaDot;
      case 'esperanca': return isDark ? AppColors.cobalt400 : AppColors.cobalt500;
      default:           return isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final surface  = isDark ? AppColors.nightPlus  : AppColors.dayPlus;
    final border   = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final bodyClr  = isDark ? AppColors.nightText  : AppColors.dayText;
    final accent   = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final dotColor = _emotionColor(emocaoId, isDark);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: accent.withAlpha(30),
        highlightColor: accent.withAlpha(15),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp5,
            vertical: AppTheme.sp5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow: dot emocional + count
              // dotColor fica apenas no ponto decorativo; texto usa bodyClr (AA 6.9:1 / 9.5:1)
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$totalSalmos SALMOS',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.74,
                      color: bodyClr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.sp2),
              Text(
                titulo,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: titleClr,
                  height: 1.15,
                  letterSpacing: -0.33,
                ),
              ),
              const SizedBox(height: AppTheme.sp1 + 2),
              Text(
                subtitulo,
                style: GoogleFonts.cormorant(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: bodyClr,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.sp4),
              Row(
                children: [
                  Text(
                    'Ver salmos',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: AppTheme.sp1),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
