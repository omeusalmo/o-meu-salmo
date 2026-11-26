/// Copy da contagem discreta de dias na Home. Sem gamificação: nunca fala em
/// perda, sequência ou meta.
class CopyJornada {
  CopyJornada._();

  static String diasComSalmos(int n) =>
      n == 1 ? '1 dia com os Salmos' : '$n dias com os Salmos';
}
