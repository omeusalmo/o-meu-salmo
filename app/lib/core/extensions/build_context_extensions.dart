import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

extension BuildContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colorBg      => isDark ? AppColors.nightBase  : AppColors.dayBase;
  Color get colorSurface => isDark ? AppColors.nightPlus  : AppColors.dayPlus;
  Color get colorBorder  => isDark ? AppColors.nightLine  : AppColors.dayLine;
  Color get colorTitle   => isDark ? AppColors.nightCream : AppColors.dayTitle;
  Color get colorText    => isDark ? AppColors.nightText  : AppColors.dayText;
  Color get colorMuted   => isDark ? AppColors.nightMuted : AppColors.dayMuted;
  /// Acento para borda, contorno e ícone puramente decorativo.
  ///
  /// Não use para texto: no escuro dá 3.64:1 sobre a superfície e reprova AA.
  /// Serve onde a exigência é a de elemento não textual (3:1).
  Color get colorAccent  => isDark ? AppColors.cobalt400  : AppColors.cobalt500;

  /// Acento para TEXTO e ícone que carrega informação.
  ///
  /// Escuro: cobalt350, 5.50:1 sobre a superfície. Claro: cobalt500, 5.56:1.
  Color get colorAccentText =>
      isDark ? AppColors.cobalt350 : AppColors.cobalt500;

  /// Acento para PREENCHIMENTO sólido que leva texto claro por cima.
  ///
  /// cobalt500 nos dois modos: com creme dá 6.08:1. É o inverso do acento de
  /// texto — cobalt350 como fundo cai para 2.72:1, e o 400 para 4.10:1.
  Color get colorAccentFill => AppColors.cobalt500;
  Color get colorVerse   => isDark ? AppColors.gold       : AppColors.goldInk;

  /// Volta se der (pilha de navegação tem histórico); senão vai pra [fallback].
  /// Cobre o caso de abrir a tela direto por deep link, sem histórico.
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
