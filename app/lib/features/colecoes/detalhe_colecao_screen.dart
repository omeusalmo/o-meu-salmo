import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/psalm_card.dart';

class DetalheColecaoScreen extends ConsumerWidget {
  final String colecaoId;

  const DetalheColecaoScreen({super.key, required this.colecaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colecaoAsync = ref.watch(colecaoDetalheProvider(colecaoId));
    final salmosAsync  = ref.watch(salmosProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;

    // Aguarda ambos os providers
    if (colecaoAsync.isLoading || salmosAsync.isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (colecaoAsync.hasError || salmosAsync.hasError) {
      return _ErrorView(isDark: isDark);
    }

    final colecao = colecaoAsync.value;
    if (colecao != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          AnalyticsService.instance.logCollectionOpened(colecao.id, colecao.titulo));
    }
    if (colecao == null) {
      return _NotFoundView(isDark: isDark);
    }

    final todosSalmos = salmosAsync.value ?? [];
    // Mantém a ordem definida na coleção
    final salmosDaColecao = colecao.salmos
        .map((n) => todosSalmos.where((s) => s.numero == n).firstOrNull)
        .whereType<Salmo>()
        .toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              titulo: colecao.titulo,
              isDark: isDark,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
                children: [
                  const SizedBox(height: AppTheme.sp1),
                  // Título hero — referência: CollectionScreen do UI kit
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.nightCream : AppColors.dayTitle,
                        height: 1.02,
                        letterSpacing: -0.76,
                      ),
                      children: [
                        TextSpan(text: '${salmosDaColecao.length} Salmos'),
                        const TextSpan(text: '\npara esse momento'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp2),
                  // Subtítulo em Cormorant italic
                  Text(
                    colecao.subtitulo,
                    style: GoogleFonts.cormorant(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.nightText  : AppColors.dayText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp6),
                  // Lista de PsalmCards
                  ...List.generate(salmosDaColecao.length, (i) {
                    final s = salmosDaColecao[i];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < salmosDaColecao.length - 1 ? AppTheme.sp3 : 0,
                      ),
                      child: PsalmCard(
                        numero: s.numero,
                        titulo: s.titulo,
                        snippet: s.versiculos.isNotEmpty
                            ? s.versiculos.first
                            : '',
                        onTap: () => context.push('/salmos/${s.numero}'),
                      ),
                    );
                  }),
                  const SizedBox(height: AppTheme.sp8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — back + eyebrow
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String titulo;
  final bool isDark;

  const _Header({super.key, required this.titulo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final accent = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp5, AppTheme.sp3,
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Voltar',
            button: true,
            child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/colecoes'),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 0.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: isDark ? AppColors.nightText : AppColors.dayText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp3),
          EyebrowLabel(titulo, color: accent),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados de erro / não encontrado
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final bool isDark;
  const _ErrorView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.nightBase : AppColors.dayBase,
      body: Center(
        child: Text(
          'Não consegui carregar esta coleção.\nTente novamente.',
          textAlign: TextAlign.center,
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            color: isDark ? AppColors.nightText : AppColors.dayText,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  final bool isDark;
  const _NotFoundView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.nightBase : AppColors.dayBase,
      body: Center(
        child: Text(
          'Coleção não encontrada.',
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            color: isDark ? AppColors.nightText : AppColors.dayText,
          ),
        ),
      ),
    );
  }
}
