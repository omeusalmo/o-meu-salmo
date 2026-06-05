import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/favoritos_provider.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/audio_player_bar.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/verse_line.dart';

class LeituraSalmoScreen extends ConsumerStatefulWidget {
  final int numero;

  const LeituraSalmoScreen({super.key, required this.numero});

  @override
  ConsumerState<LeituraSalmoScreen> createState() => _LeituraSalmoScreenState();
}

class _LeituraSalmoScreenState extends ConsumerState<LeituraSalmoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.instance.logPsalmOpened(widget.numero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncSalmo = ref.watch(salmoDetalheProvider(widget.numero));

    return asyncSalmo.when(
      loading: () => _LoadingView(numero: widget.numero),
      error: (_, __) => _ErrorView(numero: widget.numero),
      data: (salmo) => salmo == null
          ? _NotFoundView(numero: widget.numero)
          : _LeituraSalmoView(salmo: salmo),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tela principal de leitura
// ─────────────────────────────────────────────────────────────────────────────

class _LeituraSalmoView extends ConsumerWidget {
  final Salmo salmo;

  const _LeituraSalmoView({super.key, required this.salmo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;
    final isFav  = ref.watch(favoritosProvider).value?.contains(salmo.numero) ?? false;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              salmo: salmo,
              isFavorito: isFav,
              onFavoritoTap: () => _toggleFavorito(context, ref, isFav),
            ),
            Expanded(child: _Body(salmo: salmo)),
            AudioPlayerBar(audioPath: salmo.audio),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorito(BuildContext context, WidgetRef ref, bool atual) async {
    HapticFeedback.lightImpact();
    await ref.read(favoritosProvider.notifier).toggle(salmo.numero);
    if (!context.mounted) return;
    final msg = atual ? 'Removido dos favoritos.' : 'Guardado no seu coração.';
    final isDarkCtx = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            color: isDarkCtx ? AppColors.nightCream : AppColors.dayTitle,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.nightPlus
                : AppColors.dayPlus,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — volta, compartilhar, favoritar
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Salmo salmo;
  final bool isFavorito;
  final VoidCallback onFavoritoTap;

  const _Header({
    super.key,
    required this.salmo,
    required this.isFavorito,
    required this.onFavoritoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted  = isDark ? AppColors.nightMuted : AppColors.dayMuted;
    final accent = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp3, AppTheme.sp3,
      ),
      child: Row(
        children: [
          _IconBtn(
            onTap: () => context.canPop() ? context.pop() : context.go('/salmos'),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
          const Spacer(),
          _IconBtn(
            onTap: () => context.push('/compositor?numero=${salmo.numero}'),
            child: Icon(Icons.ios_share_rounded, size: 18, color: muted),
          ),
          const SizedBox(width: AppTheme.sp2),
          _IconBtn(
            onTap: onFavoritoTap,
            child: AnimatedSwitcher(
              duration: AppTheme.durFast,
              child: Icon(
                isFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(isFavorito),
                size: 18,
                color: isFavorito ? accent : muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Corpo — eyebrow, título hero, versículos, reflexão
// ─────────────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final Salmo salmo;

  const _Body({super.key, required this.salmo});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final accent  = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final title   = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final text    = isDark ? AppColors.nightText  : AppColors.dayText;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp5, AppTheme.sp4 + 2, AppTheme.sp5, AppTheme.sp8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título hero — "Salmo [número em cobalto itálico]"
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(
                fontSize: 52,
                fontWeight: FontWeight.w400,
                color: title,
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

          // Subtítulo do salmo
          if (salmo.titulo.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sp2),
            Text(
              salmo.titulo,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.nightMuted : AppColors.dayMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],

          const SizedBox(height: AppTheme.sp6),

          // Versículos
          ...salmo.versiculos.asMap().entries.map(
            (e) => VerseLine(
              numero: e.key + 1,
              texto: e.value,
              destaque: e.key == 0,
            ),
          ),

          // Reflexão (quando existir)
          if (salmo.reflexao != null && salmo.reflexao!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sp8),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border, width: 0.5)),
              ),
              padding: const EdgeInsets.only(top: AppTheme.sp6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EyebrowLabel('Reflexão'),
                  const SizedBox(height: AppTheme.sp3),
                  Text(
                    salmo.reflexao!,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: text,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botão de ícone circular
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _IconBtn({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.nightLine : AppColors.dayLine;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados de carregamento / erro / não encontrado
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final int numero;
  const _LoadingView({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.nightBase : AppColors.dayBase;
    final accent  = isDark ? AppColors.cobalt400 : AppColors.cobalt500;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: CircularProgressIndicator(
          color: accent,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final int numero;
  const _ErrorView({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;
    final text   = isDark ? AppColors.nightText : AppColors.dayText;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _BackBar(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.sp5),
                  child: Text(
                    'Não consegui carregar este Salmo.\nTente novamente.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 15,
                      color: text,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  final int numero;
  const _NotFoundView({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;
    final text   = isDark ? AppColors.nightText : AppColors.dayText;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _BackBar(),
            Expanded(
              child: Center(
                child: Text(
                  'Salmo $numero não encontrado.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    color: text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted  = isDark ? AppColors.nightMuted : AppColors.dayMuted;
    final border = isDark ? AppColors.nightLine  : AppColors.dayLine;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp3, AppTheme.sp3,
      ),
      child: Row(
        children: [
          _IconBtn(
            onTap: () => context.canPop() ? context.pop() : context.go('/salmos'),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
        ],
      ),
    );
  }
}
