class Colecao {
  final String id;
  final String titulo;
  final String subtitulo;

  /// Números dos Salmos que compõem esta coleção (referência, não embed).
  final List<int> salmos;

  const Colecao({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.salmos,
  });

  factory Colecao.fromJson(Map<String, dynamic> json) => Colecao(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        subtitulo: json['subtitulo'] as String,
        salmos: List<int>.from(json['salmos'] as List),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'subtitulo': subtitulo,
        'salmos': salmos,
      };
}
