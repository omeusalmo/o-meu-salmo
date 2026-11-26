import '../../data/providers/onboarding_provider.dart';

/// Copy da notificação contextual por emoção e do seletor em Ajustes.
///
/// A frase vai no título do aviso e aparece na tela bloqueada, então nunca
/// nomeia a emoção. Também não supõe hora do dia: o aviso chega no horário
/// que a pessoa escolheu.
class CopyEmocao {
  CopyEmocao._();

  static const ajustesLabel = 'Como você está';
  static const seletorTitulo = 'Como você está chegando hoje?';
  static const seletorApoio =
      'O Salmo do dia e a notificação vão levar em conta o que você escolher.';

  /// Sem entrada para paz: aviso clássico 'Salmo N · titulo'.
  static const fraseAviso = <EmocaoInicial, String>{
    EmocaoInicial.ansiedade: 'Um instante de calma para você',
    EmocaoInicial.sono: 'Descanse nesta palavra',
    EmocaoInicial.luto: 'Fique um pouco, sem pressa',
    EmocaoInicial.gratidao: 'Para guardar o que é bom',
    EmocaoInicial.esperanca: 'Ainda há caminho à frente',
  };
}
