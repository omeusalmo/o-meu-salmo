import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Card de listagem de Salmo — número Playfair cobalt + título + snippet.
class PsalmCard extends StatelessWidget {
  final int numero;
  final String titulo;
  final String snippet;
  final VoidCallback onTap;

  const PsalmCard({
    super.key,
    required this.numero,
    required this.titulo,
    required this.snippet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface  = context.colorSurface;
    final border   = context.colorBorder;
    final accent   = context.colorAccent;
    final titleClr = context.colorTitle;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        splashColor: accent.withAlpha(30),
        highlightColor: accent.withAlpha(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: AppTheme.sp4,
          ),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$numero',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: accent,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: titleClr,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (snippet.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        snippet,
                        style: GoogleFonts.cormorant(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: context.colorText,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          ),  // IntrinsicHeight
        ),
      ),
    );
  }
}
