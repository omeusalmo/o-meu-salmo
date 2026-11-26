import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

enum EmocaoInicial { ansiedade, gratidao, luto, sono, esperanca, paz }

extension EmocaoInicialX on EmocaoInicial {
  String get label {
    switch (this) {
      case EmocaoInicial.ansiedade: return 'Ansioso(a)';
      case EmocaoInicial.gratidao:  return 'Grato(a)';
      case EmocaoInicial.luto:      return 'Triste';
      case EmocaoInicial.sono:      return 'Sem dormir';
      case EmocaoInicial.esperanca: return 'Esperançoso(a)';
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

/// Emoção salva nas prefs (paz se não houver). Leitura direta, para quem não
/// pode esperar o carregamento assíncrono do [emocaoInicialProvider].
EmocaoInicial emocaoSalva(SharedPreferences prefs) {
  final saved = prefs.getString(AppConstants.prefEmocaoInicial);
  return EmocaoInicial.values.firstWhere(
    (e) => e.name == saved,
    orElse: () => EmocaoInicial.paz,
  );
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
    if (prefs.containsKey(AppConstants.prefEmocaoInicial)) {
      state = emocaoSalva(prefs);
    }
  }

  Future<void> set(EmocaoInicial emocao) async {
    // Grava antes de notificar: quem reage ao state (Salmo do Dia) lê as prefs.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefEmocaoInicial, emocao.name);
    state = emocao;
  }
}

final emocaoInicialProvider =
    NotifierProvider<EmocaoInicialNotifier, EmocaoInicial>(
        EmocaoInicialNotifier.new);
