import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tokens de cor — O meu Salmo Design System v1.0
// Fonte: o-meu-salmo-design/colors_and_type.css
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Cobalto — único acento de interface
  static const cobalt400 = Color(0xFF5567EA); // texto/ícone sobre escuro
  static const cobalt500 = Color(0xFF2A47DD); // ★ primária da marca
  static const cobalt600 = Color(0xFF1B33B4); // pressed / shadow base

  // Âmbar — SOMENTE versículo em destaque e peças sociais
  static const gold    = Color(0xFFC4A86A); // sobre escuro (AAA 8.5:1)
  static const goldInk = Color(0xFF6B4E1C); // sobre claro (AAA 7.2:1) — escurecido p/ público +velho

  // Modo noturno (padrão emocional)
  static const nightBase  = Color(0xFF080B1C);
  static const nightPlus  = Color(0xFF10142C);
  static const nightLine  = Color(0xFF1E2348);
  static const nightMuted = Color(0xFF353C73);
  static const nightText  = Color(0xFF8C97D4); // AA 6.9:1
  static const nightCream = Color(0xFFEEF0FC); // AAA 17:1

  // Modo diurno
  static const dayBase  = Color(0xFFF5F7FE);
  static const dayPlus  = Color(0xFFE9EDFD);
  static const dayLine  = Color(0xFFD5DCF3);
  static const dayMuted = Color(0xFF8C97D4);
  static const dayText  = Color(0xFF2E3A86); // AA
  static const dayTitle = Color(0xFF0C1230); // AAA

  // Cores de emoção (chips de curadoria)
  static const emoAnsiedadeBg  = Color(0xFFEEEDF8);
  static const emoAnsiedadeFg  = Color(0xFF3D3889);
  static const emoAnsiedadeDot = Color(0xFF5567EA);
  static const emoPazBg        = Color(0xFFEAF1E6);
  static const emoPazFg        = Color(0xFF446650);
  static const emoPazDot       = Color(0xFF6A9A62);
  static const emoGratidaoBg   = Color(0xFFFAF2E0);
  static const emoGratidaoFg   = Color(0xFF7A5A18);
  static const emoGratidaoDot  = Color(0xFFC99A38);
  static const emoLutoBg       = Color(0xFFF1EBEF);
  static const emoLutoFg       = Color(0xFF7A4A66);
  static const emoLutoDot      = Color(0xFF9A6A86);
  static const emoDuvidaBg     = Color(0xFFECECF2);
  static const emoDuvidaFg     = Color(0xFF5E5A82);
  static const emoDuvidaDot    = Color(0xFF8480AA);
  static const emoEsperancaBg  = Color(0xFFE6EAFD);
  static const emoEsperancaFg  = Color(0xFF1B33B4);
  static const emoEsperancaDot = Color(0xFF2A47DD);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tema — O meu Salmo
//
// Noturno (padrão) / Diurno via ThemeMode.system
//
// Tipografia:
//   Playfair Display — números de Salmo, títulos H1/H2
//   Cormorant Italic — corpo dos versículos (≥18px, lh 1.65)
//   Instrument Sans  — toda a UI: labels, eyebrows, nav, botões
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme  => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg      = isDark ? AppColors.nightBase  : AppColors.dayBase;
    final surface = isDark ? AppColors.nightPlus  : AppColors.dayPlus;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final text    = isDark ? AppColors.nightText  : AppColors.dayText;
    final title   = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final accent  = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final onAccent = isDark ? AppColors.nightCream : Colors.white;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cobalt500,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: onAccent,
      secondary: AppColors.cobalt400,
      onSecondary: AppColors.nightCream,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: _textTheme(title, text),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: title,
        titleTextStyle: GoogleFonts.instrumentSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: text,
          letterSpacing: 0.01,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withAlpha(38), // ~15%
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.instrumentSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.04,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Espaçamento base 4px — constantes de conveniência
  static const double sp1  = 4;
  static const double sp2  = 8;
  static const double sp3  = 12;
  static const double sp4  = 16;
  static const double sp5  = 20;
  static const double sp6  = 24;
  static const double sp8  = 32;
  static const double sp10 = 40;
  static const double sp12 = 48;
  static const double sp16 = 64;

  // Raios
  static const double radiusSm   = 8;
  static const double radiusMd   = 14;
  static const double radiusLg   = 22;
  static const double radiusPill = 999;

  // Easing e durações de animação — calmo, sem bounce
  static const Duration durFast = Duration(milliseconds: 180);
  static const Duration dur     = Duration(milliseconds: 350);
  static const Duration durSlow = Duration(milliseconds: 700);
  static const Curve ease = Curves.easeOutCubic;

  static TextTheme _textTheme(Color title, Color body) => TextTheme(
    // ── Playfair Display — números de Salmo, títulos ──────────────────────
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 80, fontWeight: FontWeight.w400, color: title,
      height: 0.88, letterSpacing: -2.0,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 52, fontWeight: FontWeight.w400, color: title,
      height: 0.88, letterSpacing: -1.3,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 40, fontWeight: FontWeight.w400, color: title,
      height: 0.95, letterSpacing: -0.8,
    ),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 36, fontWeight: FontWeight.w400, color: title,
      height: 0.95, letterSpacing: -0.72,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontSize: 28, fontWeight: FontWeight.w400, color: title,
      height: 1.0, letterSpacing: -0.42,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontSize: 22, fontWeight: FontWeight.w400, color: title,
      height: 1.1,
    ),

    // ── Instrument Sans — UI, labels, títulos de telas ───────────────────
    titleLarge: GoogleFonts.instrumentSans(
      fontSize: 16, fontWeight: FontWeight.w500, color: title,
    ),
    titleMedium: GoogleFonts.instrumentSans(
      fontSize: 15, fontWeight: FontWeight.w500, color: title,
    ),
    titleSmall: GoogleFonts.instrumentSans(
      fontSize: 14, fontWeight: FontWeight.w400, color: body,
    ),

    // ── Cormorant Italic — versículos ─────────────────────────────────────
    bodyLarge: GoogleFonts.cormorant(
      fontSize: 20, fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic, color: body, height: 1.65,
    ),

    // ── Instrument Sans — corpo genérico de UI ────────────────────────────
    bodyMedium: GoogleFonts.instrumentSans(
      fontSize: 16, fontWeight: FontWeight.w400, color: body, height: 1.55,
    ),
    bodySmall: GoogleFonts.instrumentSans(
      fontSize: 13, fontWeight: FontWeight.w400,
      color: body,
    ),

    // ── Labels — Instrument Sans uppercase com tracking ───────────────────
    labelLarge: GoogleFonts.instrumentSans(
      fontSize: 14, fontWeight: FontWeight.w500, color: body,
    ),
    labelMedium: GoogleFonts.instrumentSans(
      fontSize: 12, fontWeight: FontWeight.w400, color: body,
      letterSpacing: 1.92, // 0.16em × 12
    ),
    labelSmall: GoogleFonts.instrumentSans(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: body,
      letterSpacing: 1.76,
    ),
  );

  // ── Estilos nomeados reutilizados ──────────────────────────────────────
  // Fora dos 13 papéis fixos do Material TextTheme acima — cobrem combinações
  // de fonte que se repetem 3+ vezes pelas telas (ver revisao-codigo-2026-08.md,
  // achado #3). Cor é sempre parâmetro: dark/light já vem de context.colorX.

  static TextStyle caption14([Color? color]) =>
      GoogleFonts.instrumentSans(fontSize: 14, color: color);

  static TextStyle eyebrowLabel([Color? color]) => GoogleFonts.instrumentSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 3.74,
        color: color,
      );

  static TextStyle body15([Color? color]) =>
      GoogleFonts.instrumentSans(fontSize: 15, color: color);

  static TextStyle buttonLabel([Color? color]) => GoogleFonts.instrumentSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle emphasis14([Color? color]) => GoogleFonts.instrumentSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyRelaxed15([Color? color]) => GoogleFonts.instrumentSans(
        fontSize: 15,
        height: 1.6,
        color: color,
      );

  static TextStyle emphasisTracked15([Color? color]) =>
      GoogleFonts.instrumentSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle sectionHeadline([Color? color]) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.42,
        height: 1.2,
        color: color,
      );
}
