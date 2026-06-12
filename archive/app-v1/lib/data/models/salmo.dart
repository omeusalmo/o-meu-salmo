class Salmo {
  final int numero;
  final String titulo;
  final String traducao;

  /// Versículos como strings simples — a posição na lista é o número do versículo.
  /// Índice 0 = versículo 1, índice n-1 = último versículo.
  final List<String> versiculos;

  final List<String> temas;
  final String? reflexao;
  final String? reflexaoPergunta;

  /// Caminho relativo ao bundle, ex.: "audios/salmo_023.mp3".
  /// Vazio enquanto o MP3 não está disponível.
  final String audio;

  final bool favorito;

  const Salmo({
    required this.numero,
    required this.titulo,
    required this.traducao,
    required this.versiculos,
    required this.temas,
    this.reflexao,
    this.reflexaoPergunta,
    required this.audio,
    this.favorito = false,
  });

  factory Salmo.fromJson(Map<String, dynamic> json) => Salmo(
        numero: json['numero'] as int,
        titulo: json['titulo'] as String,
        traducao: json['traducao'] as String,
        versiculos: List<String>.from(json['versiculos'] as List),
        temas: List<String>.from(json['temas'] as List),
        reflexao: (json['reflexao'] as String?)?.isNotEmpty == true
            ? json['reflexao'] as String
            : null,
        reflexaoPergunta:
            (json['reflexao_pergunta'] as String?)?.isNotEmpty == true
                ? json['reflexao_pergunta'] as String
                : null,
        audio: json['audio'] as String? ?? '',
        favorito: json['favorito'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'titulo': titulo,
        'traducao': traducao,
        'versiculos': versiculos,
        'temas': temas,
        if (reflexao != null) 'reflexao': reflexao,
        if (reflexaoPergunta != null) 'reflexao_pergunta': reflexaoPergunta,
        'audio': audio,
        'favorito': favorito,
      };

  Salmo copyWith({bool? favorito}) => Salmo(
        numero: numero,
        titulo: titulo,
        traducao: traducao,
        versiculos: versiculos,
        temas: temas,
        reflexao: reflexao,
        reflexaoPergunta: reflexaoPergunta,
        audio: audio,
        favorito: favorito ?? this.favorito,
      );
}
