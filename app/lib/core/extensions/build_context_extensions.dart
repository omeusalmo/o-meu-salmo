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
  Color get colorAccent  => isDark ? AppColors.cobalt400  : AppColors.cobalt500;
  Color get colorVerse   => isDark ? AppColors.gold       : AppColors.goldInk;

  /// Volta se der (pilha de navegação tem histórico); senão vai pra [fallback].
  /// Cobre o caso de abrir a tela direto por deep link, sem histórico.
  void popOrGo(String fallback) => canPop() ? pop() : go(fallback);
}
