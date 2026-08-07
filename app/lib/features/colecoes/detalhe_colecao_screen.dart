import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/psalm_card.dart';

class DetalheColecaoScreen extends ConsumerWidget {
  final String colecaoId;

  const DetalheColecaoScreen({super.key, required this.colecaoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colecaoAsync = ref.watch(colecaoDetalheProvider(colecaoId));
    final salmosAsync  = ref.watch(salmosProvider);

    final isDark = context.isDark;
    final bg     = context.colorBg;

    // Aguarda ambos os providers
    if (colecaoAsync.isLoading || salmosAsync.isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            color: context.colorAccent,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (colecaoAsync.hasError || salmosAsync.hasError) {
      return _ErrorView(onRetry: () {
        ref.invalidate(colecaoDetalheProvider(colecaoId));
        ref.invalidate(salmosProvider);
      });
    }

    final colecao = colecaoAsync.value;
    if (colecao != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          AnalyticsService.instance.logCollectionOpened(colecao.id));
    }
    if (colecao == null) {
      return const _NotFoundView();
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
                  const SizedBox(height: AppTheme.sp5),
                  // Título hero — referência: CollectionScreen do UI kit
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w400,
                        color: context.colorTitle,
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
                      color: context.colorText,
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

  const _Header({required this.titulo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = context.colorBorder;
    final accent = context.colorAccent;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp4, AppTheme.sp5, AppTheme.sp3,
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
                    color: context.colorText,
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
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorBg,
        body: SafeArea(
          child: ErrorStateView(
            titulo: 'Não consegui carregar esta coleção',
            mensagem: 'Verifique sua conexão e tente de novo.',
            acaoLabel: 'Tentar de novo',
            onAcao: onRetry,
          ),
        ),
      );
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorBg,
        body: SafeArea(
          child: ErrorStateView(
            titulo: 'Coleção não encontrada',
            mensagem: 'Ela pode ter sido movida ou removida.',
            icon: Icons.explore_off_outlined,
            acaoLabel: 'Ver coleções',
            onAcao: () => context.go('/colecoes'),
          ),
        ),
      );
}
