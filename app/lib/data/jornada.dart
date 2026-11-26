/// Regra da Jornada: dias seguidos em que a pessoa abriu a leitura do Salmo do
/// dia. Sem I/O; [hoje] e [ultimoDia] são dias civis (ver `diaCivil`).
library;

typedef Jornada = ({int? ultimoDia, int dias});

const jornadaVazia = (ultimoDia: null, dias: 0);

/// Estado depois de abrir o Salmo do dia em [hoje].
///
/// Mesmo dia ou relógio andando para trás: nada muda. Ontem: +1. Buraco de 1+
/// dias (ou primeira vez): recomeça em 1.
Jornada registrarDia(Jornada atual, int hoje) {
  final ultimo = atual.ultimoDia;
  if (ultimo == null) return (ultimoDia: hoje, dias: 1);
  if (hoje <= ultimo) return atual;
  return (
    ultimoDia: hoje,
    dias: hoje == ultimo + 1 ? atual.dias + 1 : 1,
  );
}

/// A contagem aparece só enquanto a corrente vive: hoje ou ontem.
bool jornadaViva(Jornada j, int hoje) {
  final ultimo = j.ultimoDia;
  return ultimo != null && j.dias > 0 && (ultimo == hoje || ultimo == hoje - 1);
}
