import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/review/review_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/audio_provider.dart';
import '../../data/providers/favoritos_provider.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/audio_player_bar.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../shared/widgets/tema_chip.dart';
import '../../shared/widgets/verse_line.dart';
import 'verse_sync.dart';

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
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      ReviewService.instance.maybeRequestReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncSalmo = ref.watch(salmoDetalheProvider(widget.numero));

    return asyncSalmo.when(
      loading: () => _LoadingView(numero: widget.numero),
      error: (_, __) => _ErrorView(
        numero: widget.numero,
        onRetry: () => ref.invalidate(salmoDetalheProvider(widget.numero)),
      ),
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

  const _LeituraSalmoView({required this.salmo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg     = context.colorBg;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTheme.caption14(context.colorTitle),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colorSurface,
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
    required this.salmo,
    required this.isFavorito,
    required this.onFavoritoTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = context.colorBorder;
    final muted  = context.colorText;
    final accent = context.colorAccent;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp3, AppTheme.sp3,
      ),
      child: Row(
        children: [
          CircleIconButton(
            onTap: () => context.popOrGo('/salmos'),
            semanticsLabel: 'Voltar',
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
          const Spacer(),
          CircleIconButton(
            onTap: () => context.push('/compositor?numero=${salmo.numero}'),
            semanticsLabel: 'Compartilhar Salmo',
            child: Icon(Icons.ios_share_rounded, size: 18, color: muted),
          ),
          const SizedBox(width: AppTheme.sp2),
          CircleIconButton(
            onTap: onFavoritoTap,
            semanticsLabel: isFavorito ? 'Remover dos favoritos' : 'Guardar nos favoritos',
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

class _Body extends ConsumerStatefulWidget {
  final Salmo salmo;

  const _Body({required this.salmo});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _revealed = false;

  void _reveal() {
    HapticFeedback.mediumImpact();
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final accent  = context.colorAccent;
    final title   = context.colorTitle;
    final border  = context.colorBorder;
    final text    = context.colorText;

    final salmo = widget.salmo;
    final unlocked = ref.watch(unlockedPsalmsProvider).value
        ?.contains(salmo.numero) ?? false;
    final hasReflexao = salmo.reflexao?.isNotEmpty == true;

    // Karaokê da narração: enquanto o áudio toca, o versículo ativo
    // (estimado pela posição) recebe o destaque âmbar. O select limita o
    // rebuild ao momento em que o índice muda, não a cada tick de posição.
    final versoAtivo = ref.watch(
      audioPlayerProvider.select((audio) {
        final narrando = audio.isPlaying &&
            audio.isAvailable &&
            audio.duration > Duration.zero;
        if (!narrando) return 0;
        return activeVerseIndex(
          position: audio.position,
          duration: audio.duration,
          versiculos: salmo.versiculos,
        );
      }),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp5, AppTheme.sp4 + 2, AppTheme.sp5, AppTheme.sp8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título hero
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

          // Subtítulo
          if (salmo.titulo.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sp2),
            Text(
              salmo.titulo,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: text,
                letterSpacing: 0.2,
              ),
            ),
          ],

          if (salmo.temas.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sp3),
            // Emoções da curadoria — reforça o sentimento do Salmo.
            TemaChips(salmo.temas, max: 3),
          ],

          const SizedBox(height: AppTheme.sp6),

          // Versículos — destaque acompanha a narração quando tocando
          ...salmo.versiculos.asMap().entries.map(
            (e) => VerseLine(
              numero: e.key + 1,
              texto: e.value,
              destaque: e.key == versoAtivo,
            ),
          ),

          // Reflexão
          if (hasReflexao) ...[
            const SizedBox(height: AppTheme.sp8),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border, width: 0.5)),
              ),
              padding: const EdgeInsets.only(top: AppTheme.sp6),
              child: unlocked
                  ? _UnlockedReflexao(
                      salmo: salmo,
                      revealed: _revealed,
                      onReveal: _reveal,
                    )
                  : _LockedReflexao(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado bloqueado — reflexão ainda não disponível
// ─────────────────────────────────────────────────────────────────────────────

class _LockedReflexao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final muted  = context.colorText;
    final accent = context.colorAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowLabel('Reflexão'),
        const SizedBox(height: AppTheme.sp4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: muted,
            ),
            const SizedBox(width: AppTheme.sp2),
            Expanded(
              child: Text(
                'Esta reflexão se revela quando este Salmo for o seu Salmo do Dia.\nAbra o app amanhã — pode ser ele.',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: muted,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.sp4),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/colecoes');
          },
          style: TextButton.styleFrom(
            foregroundColor: accent,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Explorar coleções',
            style: AppTheme.emphasis14(accent),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado desbloqueado — botão de revelar + conteúdo animado
// ─────────────────────────────────────────────────────────────────────────────

class _UnlockedReflexao extends StatelessWidget {
  final Salmo salmo;
  final bool revealed;
  final VoidCallback onReveal;

  const _UnlockedReflexao({
    required this.salmo,
    required this.revealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.colorAccent;
    final text   = context.colorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowLabel('Reflexão'),
        const SizedBox(height: AppTheme.sp4),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 480),
          crossFadeState: revealed
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeOut,
          sizeCurve: Curves.easeOutCubic,
          firstChild: _RevealButton(onTap: onReveal, accent: accent),
          secondChild: _ReflexaoContent(salmo: salmo, text: text, accent: accent),
        ),
      ],
    );
  }
}

class _RevealButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color accent;

  const _RevealButton({
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ler a reflexão deste Salmo',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3 + 4),
          decoration: BoxDecoration(
            color: accent.withAlpha(22),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: accent.withAlpha(160), width: 1.0),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_outlined, size: 16, color: accent),
                const SizedBox(width: AppTheme.sp2),
                Text(
                  'Ler a reflexão',
                  style: AppTheme.emphasisTracked15(accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReflexaoContent extends StatelessWidget {
  final Salmo salmo;
  final Color text;
  final Color accent;

  const _ReflexaoContent({
    required this.salmo,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salmo.reflexao!,
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: text,
            height: 1.65,
          ),
        ),
        if (salmo.reflexaoPergunta?.isNotEmpty == true) ...[
          const SizedBox(height: AppTheme.sp4),
          Text(
            salmo.reflexaoPergunta!,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: accent,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados de carregamento / erro / não encontrado
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final int numero;
  const _LoadingView({required this.numero});

  @override
  Widget build(BuildContext context) {
    final bg      = context.colorBg;
    final accent  = context.colorAccent;

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
  final VoidCallback onRetry;
  const _ErrorView({required this.numero, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBg,
      body: SafeArea(
        child: Column(
          children: [
            const _BackBar(),
            Expanded(
              child: ErrorStateView(
                titulo: 'Não consegui carregar este Salmo',
                mensagem: 'Verifique sua conexão e tente de novo.',
                acaoLabel: 'Tentar de novo',
                onAcao: onRetry,
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
  const _NotFoundView({required this.numero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBg,
      body: SafeArea(
        child: Column(
          children: [
            const _BackBar(),
            Expanded(
              child: ErrorStateView(
                titulo: 'Salmo $numero não encontrado',
                mensagem: 'Ele pode não existir nesta edição.',
                icon: Icons.menu_book_outlined,
                acaoLabel: 'Ver todos os salmos',
                onAcao: () => context.go('/salmos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    final muted  = context.colorText;
    final border = context.colorBorder;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp3, AppTheme.sp3,
      ),
      child: Row(
        children: [
          CircleIconButton(
            onTap: () => context.popOrGo('/salmos'),
            semanticsLabel: 'Voltar',
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
        ],
      ),
    );
  }
}
