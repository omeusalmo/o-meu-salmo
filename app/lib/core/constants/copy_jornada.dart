/// Copy da Jornada na Home. Sem gamificação: nunca fala em perda, meta,
/// "streak" ou "sequência". "Seguidos" liberado pelo Jeff em 27/11/2026.
class CopyJornada {
  CopyJornada._();

  /// Número em destaque (Playfair) e o resto da frase, separados para estilo.
  static (String, String) contagem(int n) =>
      n == 1 ? ('1º', ' dia com os Salmos') : ('$n', ' dias seguidos');

  /// Só quando a última leitura foi ontem.
  static String falta(int n) => ' · o ${n + 1}º é hoje';

  static String leitor(int n, {required bool leuHoje}) =>
      '${n == 1 ? '1 dia' : '$n dias seguidos'} lendo o Salmo do dia. '
      '${leuHoje ? 'Você já leu o de hoje.' : 'Falta ler o de hoje.'}';
}
