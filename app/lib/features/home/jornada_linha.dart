import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/copy_jornada.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/jornada.dart';
import '../../data/providers/jornada_provider.dart';
import '../../data/salmo_do_dia.dart';

/// Dias marcados entre os últimos 7 (hoje por último). Sem I/O.
List<bool> semanaJornada(Jornada j, int hoje) {
  final ultimo = j.ultimoDia ?? -1;
  return [
    for (var d = hoje - 6; d <= hoje; d++) d <= ultimo && d > ultimo - j.dias,
  ];
}

/// Régua dos 7 dias + "N dias seguidos", logo abaixo de "Ler o salmo".
/// Some por inteiro se a corrente não está viva.
class JornadaLinha extends ConsumerWidget {
  const JornadaLinha({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(jornadaProvider).valueOrNull;
    final hoje = diaCivil(DateTime.now());
    if (j == null || !jornadaViva(j, hoje)) return const SizedBox.shrink();

    final leuHoje = j.ultimoDia == hoje;
    final semana = semanaJornada(j, hoje);
    final (numero, resto) = CopyJornada.contagem(j.dias);
    final accent = context.colorAccent;

    Widget ponto(bool cheio, bool eHoje) {
      final lado = eHoje ? 10.0 : 8.0;
      return Container(
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cheio ? accent : null,
          border: Border.all(color: accent),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.sp3),
      child: Semantics(
        label: CopyJornada.leitor(j.dias, leuHoje: leuHoje),
        excludeSemantics: true,
        child: Wrap(
          spacing: AppTheme.sp3,
          runSpacing: AppTheme.sp2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: AppTheme.sp2),
                  ponto(semana[i], i == 6),
                ],
              ],
            ),
            Text.rich(
              TextSpan(
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: context.colorText,
                ),
                children: [
                  TextSpan(
                    text: numero,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: accent,
                    ),
                  ),
                  TextSpan(text: resto),
                  if (!leuHoje) TextSpan(text: CopyJornada.falta(j.dias)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
