import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Rótulo de sobrelinha — Instrument Sans uppercase, tracking largo.
/// Equivalente ao `.ds-eyebrow` do Design System.
///
/// Uso: contexto de emoção ("PARA A ANSIEDADE"), seção ("REFLEXÃO"), tradução.
class EyebrowLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const EyebrowLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.nightMuted : AppColors.dayMuted;

    return Text(
      text.toUpperCase(),
      style: GoogleFonts.instrumentSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 3.74, // 0.34em × 11px — tracking do "O MEU" no DS
        color: color ?? defaultColor,
      ),
    );
  }
}
