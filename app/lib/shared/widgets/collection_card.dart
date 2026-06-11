import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

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

  static Color _emoDot(String? id) => switch (id) {
    'ansiedade'            => AppColors.emoAnsiedadeDot,
    'sono' || 'protecao'   => AppColors.emoPazDot,
    'gratidao' || 'louvor' => AppColors.emoGratidaoDot,
    'luto'                 => AppColors.emoLutoDot,
    'perdao'               => AppColors.emoDuvidaDot,
    _                      => AppColors.emoEsperancaDot,
  };

  @override
  Widget build(BuildContext context) {
    final surface  = context.colorSurface;
    final border   = context.colorBorder;
    final titleClr = context.colorTitle;
    final bodyClr  = context.colorText;
    final accent   = context.colorAccent;
    final dotColor = _emoDot(emocaoId);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Stack(
        children: [
          Material(
            color: surface,
            child: InkWell(
              splashColor: accent.withAlpha(30),
              highlightColor: accent.withAlpha(15),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sp5,
                  vertical: AppTheme.sp5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          ),
          // Borda: full uniform (0.5px) + topo+cantos colorido (1.5px)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CardBorderPainter(
                  sideColor: border,
                  topColor: dotColor.withAlpha(128),
                  radius: AppTheme.radiusMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBorderPainter extends CustomPainter {
  final Color sideColor;
  final Color topColor;
  final double radius;

  const _CardBorderPainter({
    required this.sideColor,
    required this.topColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Borda uniforme fina em todos os lados
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.25, 0.25, size.width - 0.5, size.height - 0.5),
        Radius.circular(radius),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = sideColor,
    );

    // Topo colorido: arco canto superior esquerdo → linha topo → arco canto superior direito
    // Replica o comportamento CSS de border-top + border-radius
    final path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0),     radius: Radius.circular(radius), clockwise: true)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius), clockwise: true);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.butt
        ..color = topColor,
    );
  }

  @override
  bool shouldRepaint(_CardBorderPainter old) =>
      old.sideColor != sideColor ||
      old.topColor != topColor ||
      old.radius != radius;
}
