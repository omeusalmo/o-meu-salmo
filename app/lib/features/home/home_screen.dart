import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/staggered_entrance.dart';
import '../../shared/widgets/starfield_background.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/tema_chip.dart';
import '../../shared/widgets/word_reveal_text.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSalmo = ref.watch(salmoDoDialProvider);
    final isDark = context.isDark;
    final bg = isDark ? AppColors.nightBase : AppColors.dayBase;

    // Desbloqueia a reflexão do Salmo do Dia automaticamente
    ref.listen<AsyncValue<Salmo?>>(salmoDoDialProvider, (_, next) {
      next.whenData((salmo) {
        if (salmo != null) {
          ref.read(unlockedPsalmsProvider.notifier).unlock(salmo.numero);
        }
      });
    });

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
          child: asyncSalmo.when(
            loading: () => Center(
              key: const ValueKey('loading'),
              child: CircularProgressIndicator(
                color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
                strokeWidth: 1.5,
              ),
            ),
            error: (_, __) => _ErrorView(
              key: const ValueKey('error'),
              onRetry: () => ref.invalidate(salmoDoDialProvider),
            ),
            data: (salmo) => salmo == null
                ? _EmptyView(
                    key: const ValueKey('empty'),
                    onRetry: () => ref.invalidate(salmoDoDialProvider),
                  )
                : _HomeContent(key: ValueKey('data-${salmo.numero}'), salmo: salmo),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conteúdo principal
// ─────────────────────────────────────────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  final Salmo salmo;
  const _HomeContent({super.key, required this.salmo});

  @override
  Widget build(BuildContext context) {
    final isDark  = context.isDark;
    final accent  = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final muted   = isDark ? AppColors.nightText  : AppColors.dayText;

    return Stack(
      children: [
        // Céu de partículas calmas atrás de todo o conteúdo (conceito LP V2)
        const Positioned.fill(child: StarfieldBackground()),
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.sp5, AppTheme.sp5, AppTheme.sp5, 0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Cabeçalho: wordmark + engrenagem ─────────────────────
                  StaggeredEntrance(
                    index: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'O MEU ',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 2.8,
                                  color: muted,
                                ),
                              ),
                              TextSpan(
                                text: 'Salmo',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 19,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                  color: accent,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          label: 'Configurações',
                          button: true,
                          child: GestureDetector(
                            onTap: () => context.push('/ajustes'),
                            child: Icon(Icons.settings_outlined, size: 20, color: muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp10),

                  StaggeredEntrance(
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(DateTime.now()),
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.nightText : AppColors.dayText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppTheme.sp1),
                        Text(
                          'Para hoje,',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: titleClr,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.sp8),

                  // ── Número hero do salmo ──────────────────────────────────
                  StaggeredEntrance(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 52,
                              fontWeight: FontWeight.w400,
                              color: titleClr,
                              height: 0.88,
                              letterSpacing: -1.3,
                            ),
                            children: [
                              const TextSpan(text: 'Salmo '),
                              TextSpan(
                                text: '${salmo.numero}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (salmo.titulo.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.sp2),
                          Text(
                            salmo.titulo,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppColors.nightText : AppColors.dayText,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                        if (salmo.temas.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.sp3),
                          // Emoção da curadoria — reforça o sentimento do dia.
                          TemaChips(salmo.temas, max: 2),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.sp6),

                  // ── Versículo-âncora (em âmbar, palavra a palavra) ────────
                  if (salmo.versiculos.isNotEmpty) ...[
                    StaggeredEntrance(
                      index: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: accent, width: 2),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: AppTheme.sp4),
                        child: WordRevealText(
                          text: salmo.versiculos.first,
                          delay: const Duration(milliseconds: 450),
                          style: GoogleFonts.cormorant(
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: isDark ? AppColors.gold : AppColors.goldInk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.sp8),
                  ],

                  // ── CTAs ──────────────────────────────────────────────────
                  StaggeredEntrance(
                    index: 4,
                    child: _PrimaryButton(
                      label: 'Ler o salmo',
                      onTap: () => context.push('/salmos/${salmo.numero}'),
                    ),
                  ),

                  if (salmo.reflexao?.isNotEmpty == true) ...[
                    const SizedBox(height: AppTheme.sp3),
                    StaggeredEntrance(
                      index: 5,
                      child: Semantics(
                        label: 'Reflexão liberada. Abrir o Salmo.',
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.push('/salmos/${salmo.numero}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withAlpha(18),
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              border: Border.all(color: accent.withAlpha(60), width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_open_outlined, size: 12, color: accent),
                                const SizedBox(width: 5),
                                Text(
                                  'reflexão liberada',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: accent,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppTheme.sp12),

                  // ── Respirar — pausa guiada com o Salmo 46 ────────────────
                  const StaggeredEntrance(
                    index: 6,
                    child: _RespirarCard(),
                  ),

                  const SizedBox(height: AppTheme.sp3),

                  // ── Atalho coleções ───────────────────────────────────────
                  const StaggeredEntrance(
                    index: 7,
                    child: _CollectionsShortcut(),
                  ),

                  const SizedBox(height: AppTheme.sp10),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Data em português sem depender do pacote intl
  static String _formatDate(DateTime d) {
    const days = [
      'domingo', 'segunda-feira', 'terça-feira', 'quarta-feira',
      'quinta-feira', 'sexta-feira', 'sábado',
    ];
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    // weekday: 1=seg … 7=dom → índice 0=dom
    return '${days[d.weekday % 7]}, ${d.day} de ${months[d.month - 1]}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Respirar — pausa guiada
// ─────────────────────────────────────────────────────────────────────────────

class _RespirarCard extends StatelessWidget {
  const _RespirarCard();

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final textClr  = context.colorText;
    final accent   = context.colorAccent;

    return Semantics(
      label: 'Respirar. Um minuto de pausa com o Salmo 46.',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/respirar');
        },
        child: Container(
          padding: const EdgeInsets.all(AppTheme.sp5),
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: context.colorBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.cobalt400.withAlpha(95),
                      AppColors.cobalt500.withAlpha(0),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.cobalt400.withAlpha(70),
                    width: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Respirar',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: titleClr,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Um minuto de pausa com o Salmo 46.',
                      style: GoogleFonts.cormorant(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: textClr,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 14, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Atalho para Coleções
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionsShortcut extends StatelessWidget {
  const _CollectionsShortcut();

  @override
  Widget build(BuildContext context) {
    final isDark   = context.isDark;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final accent   = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final cardBg   = isDark
        ? AppColors.cobalt600.withAlpha(45)
        : AppColors.cobalt400.withAlpha(25);

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: accent.withAlpha(50), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowLabel('Encontre pelo que sente'),
          const SizedBox(height: AppTheme.sp2),
          Text(
            'Como você está\nse sentindo hoje?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: titleClr,
              height: 1.1,
              letterSpacing: -0.36,
            ),
          ),
          const SizedBox(height: AppTheme.sp1 + 2),
          Text(
            'Escolha um sentimento — eu encontro as palavras.',
            style: GoogleFonts.cormorant(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.nightText : AppColors.dayText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.sp4),
          Semantics(
            label: 'Ver coleções',
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/colecoes');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver coleções',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp1),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: accent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botões CTA
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3 + 2),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.cobalt600.withAlpha(77),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.nightCream,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados de erro / vazio
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => ErrorStateView(
        titulo: 'Não consegui carregar o Salmo de hoje',
        mensagem: 'Verifique sua conexão e tente de novo.',
        acaoLabel: 'Tentar de novo',
        onAcao: onRetry,
      );
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => ErrorStateView(
        titulo: 'Nenhum Salmo por aqui ainda',
        mensagem: 'Tente de novo em instantes.',
        icon: Icons.menu_book_outlined,
        acaoLabel: 'Tentar de novo',
        onAcao: onRetry,
      );
}
