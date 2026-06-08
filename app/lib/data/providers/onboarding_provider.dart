import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

enum EmocaoInicial { ansiedade, gratidao, luto, sono, esperanca, paz }

extension EmocaoInicialX on EmocaoInicial {
  String get label {
    switch (this) {
      case EmocaoInicial.ansiedade: return 'Ansioso';
      case EmocaoInicial.gratidao:  return 'Grato';
      case EmocaoInicial.luto:      return 'Triste';
      case EmocaoInicial.sono:      return 'Sem dormir';
      case EmocaoInicial.esperanca: return 'Esperançoso';
      case EmocaoInicial.paz:       return 'Em paz';
    }
  }

  String get emoji {
    switch (this) {
      case EmocaoInicial.ansiedade: return '😰';
      case EmocaoInicial.gratidao:  return '🙏';
      case EmocaoInicial.luto:      return '😔';
      case EmocaoInicial.sono:      return '🌙';
      case EmocaoInicial.esperanca: return '💪';
      case EmocaoInicial.paz:       return '😌';
    }
  }

  // ID da coleção correspondente em salmos.json; 'paz' redireciona para /home
  String get colecaoId {
    switch (this) {
      case EmocaoInicial.ansiedade: return 'ansiedade';
      case EmocaoInicial.gratidao:  return 'gratidao';
      case EmocaoInicial.luto:      return 'luto';
      case EmocaoInicial.sono:      return 'sono';
      case EmocaoInicial.esperanca: return 'esperanca';
      case EmocaoInicial.paz:       return '';
    }
  }
}

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.prefOnboardingDone) ?? false;
  }

  Future<void> markDone() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class EmocaoInicialNotifier extends Notifier<EmocaoInicial> {
  @override
  EmocaoInicial build() {
    _load();
    return EmocaoInicial.paz;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefEmocaoInicial);
    if (saved != null) {
      state = EmocaoInicial.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => EmocaoInicial.paz,
      );
    }
  }

  Future<void> set(EmocaoInicial emocao) async {
    state = emocao;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefEmocaoInicial, emocao.name);
  }
}

final emocaoInicialProvider =
    NotifierProvider<EmocaoInicialNotifier, EmocaoInicial>(
        EmocaoInicialNotifier.new);
