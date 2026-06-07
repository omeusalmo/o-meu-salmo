import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/verse_line.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSalmo = ref.watch(salmoDoDialProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            error: (_, __) => _ErrorView(key: const ValueKey('error'), isDark: isDark),
            data: (salmo) => salmo == null
                ? _EmptyView(key: const ValueKey('empty'), isDark: isDark)
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
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final accent  = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final muted   = isDark ? AppColors.nightText  : AppColors.dayText;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.sp5, AppTheme.sp5, AppTheme.sp5, 0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Cabeçalho: wordmark + engrenagem ─────────────────────
              Row(
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
              const SizedBox(height: AppTheme.sp10),

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

              const SizedBox(height: AppTheme.sp8),

              // ── Número hero do salmo ──────────────────────────────────
              RichText(
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
              const SizedBox(height: AppTheme.sp2),

              // Título
              if (salmo.titulo.isNotEmpty)
                Text(
                  salmo.titulo,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.nightText : AppColors.dayText,
                    letterSpacing: 0.2,
                  ),
                ),

              const SizedBox(height: AppTheme.sp6),

              // ── Versículo-âncora (em âmbar) ───────────────────────────
              if (salmo.versiculos.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: accent, width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: AppTheme.sp4),
                  child: VerseLine(
                    numero: 1,
                    texto: salmo.versiculos.first,
                    destaque: true,
                  ),
                ),
                const SizedBox(height: AppTheme.sp8),
              ],

              // ── CTAs ──────────────────────────────────────────────────
              _PrimaryButton(
                label: 'Ler o salmo',
                onTap: () => context.push('/salmos/${salmo.numero}'),
              ),

              if (salmo.reflexao?.isNotEmpty == true) ...[
                const SizedBox(height: AppTheme.sp3),
                Semantics(
                  label: 'Este Salmo tem uma reflexão. Abrir o Salmo.',
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
                          Icon(Icons.auto_stories_outlined, size: 12, color: accent),
                          const SizedBox(width: 5),
                          Text(
                            'tem reflexão',
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
              ],

              const SizedBox(height: AppTheme.sp12),
              Divider(height: 0.5, thickness: 0.5, color: border),
              const SizedBox(height: AppTheme.sp6),

              // ── Atalho coleções ───────────────────────────────────────
              _CollectionsShortcut(),

              const SizedBox(height: AppTheme.sp10),
            ]),
          ),
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
// Atalho para Coleções
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionsShortcut extends StatelessWidget {
  const _CollectionsShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final muted   = isDark ? AppColors.nightText  : AppColors.dayText;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final accent  = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel('Encontre pelo que sente'),
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
            onTap: () => context.go('/colecoes'),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botões CTA
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final border = isDark ? AppColors.nightLine  : AppColors.dayLine;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3 + 2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones_outlined, size: 16, color: accent),
              const SizedBox(width: AppTheme.sp2),
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
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
  final bool isDark;
  const _ErrorView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Não consegui carregar o Salmo de hoje.\nTente novamente.',
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

class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum Salmo por aqui ainda.\nTente novamente em instantes.',
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          color: isDark ? AppColors.nightText : AppColors.dayText,
        ),
      ),
    );
  }
}
