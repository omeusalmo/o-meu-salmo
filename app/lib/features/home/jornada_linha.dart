import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/copy_jornada.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/jornada.dart';
import '../../data/providers/jornada_provider.dart';
import '../../data/salmo_do_dia.dart';

/// "N dias com os Salmos". Some por inteiro se a corrente não está viva.
class JornadaLinha extends ConsumerWidget {
  const JornadaLinha({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(jornadaProvider).valueOrNull;
    if (j == null || !jornadaViva(j, diaCivil(DateTime.now()))) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.sp3),
      child: Text(
        CopyJornada.diasComSalmos(j.dias),
        style: GoogleFonts.instrumentSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: context.colorMuted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
