import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// IDs das 8 coleções emocionais oficiais (salmos.json). Fonte única —
/// atualizar aqui junto com [kColecaoDotColor] ao adicionar/remover coleção.
const List<String> kColecaoIds = [
  'ansiedade', 'sono', 'gratidao', 'luto',
  'esperanca', 'perdao', 'louvor', 'protecao',
];

/// Cor do indicador (dot) de cada coleção nos cards — agrupamento por
/// proximidade emocional é intencional (design system), não bug.
/// ⚠️ Coleção nova sem entrada aqui cai no fallback (cor de "esperança") em
/// vez de dar erro — atualizar junto com [kColecaoIds].
const Map<String, Color> kColecaoDotColor = {
  'ansiedade': AppColors.emoAnsiedadeDot,
  'sono': AppColors.emoPazDot,
  'protecao': AppColors.emoPazDot,
  'gratidao': AppColors.emoGratidaoDot,
  'louvor': AppColors.emoGratidaoDot,
  'luto': AppColors.emoLutoDot,
  'perdao': AppColors.emoDuvidaDot,
  'esperanca': AppColors.emoEsperancaDot,
};

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
