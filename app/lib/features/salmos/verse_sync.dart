/// Sincronização estimada entre narração e versículos (karaokê da V2).
///
/// Os MP3 não têm timestamps por versículo, então estimamos: a narração
/// percorre o texto em ritmo aproximadamente constante, logo o versículo
/// ativo é aquele cuja fatia proporcional de caracteres contém a posição
/// atual do áudio.
library;

/// Índice (0-based) do versículo ativo para a [position] atual do áudio.
///
/// Retorna 0 quando não há dados suficientes (lista vazia, duração zero).
int activeVerseIndex({
  required Duration position,
  required Duration duration,
  required List<String> versiculos,
}) {
  if (versiculos.isEmpty || duration <= Duration.zero) return 0;

  final totalChars =
      versiculos.fold<int>(0, (sum, v) => sum + v.length);
  if (totalChars == 0) return 0;

  final fraction =
      (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  final target = fraction * totalChars;

  var accumulated = 0;
  for (var i = 0; i < versiculos.length; i++) {
    accumulated += versiculos[i].length;
    if (target < accumulated) return i;
  }
  return versiculos.length - 1;
}
