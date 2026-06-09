import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/collection_card.dart';

class ColecoesScreen extends ConsumerWidget {
  const ColecoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncColecoes = ref.watch(colecoesProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.nightBase  : AppColors.dayBase;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border   = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted    = isDark ? AppColors.nightMuted : AppColors.dayMuted;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Semantics(
            label: 'Configurações',
            button: true,
            child: GestureDetector(
              onTap: () => context.push('/ajustes'),
              child: Padding(
                padding: const EdgeInsets.only(right: AppTheme.sp4),
                child: Icon(Icons.settings_outlined, size: 20, color: muted),
              ),
            ),
          ),
        ],
        title: Text(
          'Coleções',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: titleClr,
            letterSpacing: -0.42,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: border),
        ),
      ),
      body: asyncColecoes.when(
        loading: () => const _LoadingState(),
        error: (_, __) => const _ErrorState(),
        data: (colecoes) {
          if (colecoes.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp5,
              vertical: AppTheme.sp6,
            ),
            itemCount: colecoes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sp3),
            itemBuilder: (_, i) {
              final c = colecoes[i];
              return CollectionCard(
                titulo: c.titulo,
                subtitulo: c.subtitulo,
                totalSalmos: c.salmos.length,
                emocaoId: c.id,
                onTap: () => context.push('/colecoes/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cobalt400
        : AppColors.cobalt500;
    return Center(
      child: CircularProgressIndicator(color: accent, strokeWidth: 1.5),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'Não consegui carregar as coleções.\nTente novamente.',
        textAlign: TextAlign.center,
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          color: isDark ? AppColors.nightText : AppColors.dayText,
          height: 1.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'Nenhuma coleção por aqui.\nTente novamente em instantes.',
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          color: isDark ? AppColors.nightText : AppColors.dayText,
        ),
      ),
    );
  }
}
