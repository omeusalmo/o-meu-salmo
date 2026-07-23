import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Rótulos de exibição dos temas emocionais dos Salmos.
///
/// A fonte da verdade (`temas[]` em salmos.json) é minúscula e sem acento —
/// aqui vira português correto para a UI. Fonte única de tradução dos temas.
const Map<String, String> kTemaLabels = {
  'abandono': 'Abandono',
  'adoracao': 'Adoração',
  'alegria': 'Alegria',
  'amor': 'Amor',
  'ansiedade': 'Ansiedade',
  'arrependimento': 'Arrependimento',
  'bencao': 'Bênção',
  'bondade': 'Bondade',
  'brevidade': 'Brevidade',
  'caminho': 'Caminho',
  'clamor': 'Clamor',
  'confianca': 'Confiança',
  'conforto': 'Conforto',
  'confusao': 'Confusão',
  'criacao': 'Criação',
  'cura': 'Cura',
  'descanso': 'Descanso',
  'esperanca': 'Esperança',
  'exilio': 'Exílio',
  'familia': 'Família',
  'fe': 'Fé',
  'gratidao': 'Gratidão',
  'historia': 'História',
  'humildade': 'Humildade',
  'identidade': 'Identidade',
  'integridade': 'Integridade',
  'justica': 'Justiça',
  'lei': 'Lei',
  'louvor': 'Louvor',
  'luto': 'Luto',
  'manha': 'Manhã',
  'meditacao': 'Meditação',
  'medo': 'Medo',
  'memoria': 'Memória',
  'misericordia': 'Misericórdia',
  'missao': 'Missão',
  'noite': 'Noite',
  'oracao': 'Oração',
  'pastor': 'Pastor',
  'paz': 'Paz',
  'perdao': 'Perdão',
  'perseveranca': 'Perseverança',
  'promessas': 'Promessas',
  'protecao': 'Proteção',
  'reinado': 'Reinado',
  'restauracao': 'Restauração',
  'riquezas': 'Riquezas',
  'sabedoria': 'Sabedoria',
  'santidade': 'Santidade',
  'saudade': 'Saudade',
  'sede': 'Sede',
  'solidao': 'Solidão',
  'sono': 'Sono',
  'traicao': 'Traição',
  'unidade': 'Unidade',
  'urgencia': 'Urgência',
  'velhice': 'Velhice',
  'vitoria': 'Vitória',
};

/// Humaniza um tema cru. Fallback seguro: capitaliza a inicial.
String temaLabel(String raw) => kTemaLabels[raw] ??
    (raw.isEmpty ? raw : '${raw[0].toUpperCase()}${raw.substring(1)}');

/// Chips discretos de emoção/curadoria — cobalt + Instrument Sans, pill 999.
///
/// Reforça o sentimento do Salmo (nosso moat editorial) sem competir com o
/// versículo em âmbar. `Wrap` garante que reflui com fontes grandes.
class TemaChips extends StatelessWidget {
  final List<String> temas;

  /// Máximo de chips visíveis — mantém a peça discreta.
  final int max;

  const TemaChips(this.temas, {super.key, this.max = 2});

  @override
  Widget build(BuildContext context) {
    final visiveis = temas.take(max).toList();
    if (visiveis.isEmpty) return const SizedBox.shrink();

    final accent = context.colorAccent;
    return Wrap(
      spacing: AppTheme.sp2,
      runSpacing: AppTheme.sp2,
      children: [
        for (final t in visiveis) _chip(accent, temaLabel(t)),
      ],
    );
  }

  Widget _chip(Color accent, String label) => Semantics(
        label: 'Tema: $label',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withAlpha(18),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: accent.withAlpha(60), width: 0.5),
          ),
          child: Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: accent,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
}
