import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/error_state_view.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/eyebrow_label.dart';

// Fundos disponíveis pro card de compartilhamento — constantes fixas, não
// fazem parte do estado da tela (por isso ficam fora de _CompositorBody).
const _fundos = [
  AppColors.nightBase,  // Noite
  AppColors.nightPlus,  // Profundo
  AppColors.cobalt500,  // Cobalto
  AppColors.dayBase,    // Névoa (day-base)
  AppColors.dayPlus,    // Bruma (day-plus)
];
const _fundoLabels = ['Noite', 'Profundo', 'Cobalto', 'Névoa', 'Bruma'];

class CompositorScreen extends ConsumerStatefulWidget {
  final int numero;

  const CompositorScreen({super.key, required this.numero});

  @override
  ConsumerState<CompositorScreen> createState() => _CompositorScreenState();
}

class _CompositorScreenState extends ConsumerState<CompositorScreen> {
  final _cardKey = GlobalKey();
  int _versicoloIdx = 0;
  int _fundoIdx = 0;
  bool _sharing = false;

  Future<void> _share(Salmo salmo) async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;

      final png = bytes.buffer.asUint8List();
      if (salmo.versiculos.isEmpty) return;
      final idx = _versicoloIdx.clamp(0, salmo.versiculos.length - 1);
      final verse = salmo.versiculos[idx];
      final refStr = 'Salmo ${salmo.numero} · ${idx + 1}';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(png, mimeType: 'image/png', name: 'salmo_${salmo.numero}.png')],
          text: '"$verse"\n— $refStr',
          subject: refStr,
        ),
      );
      AnalyticsService.instance.logPsalmShared(
        salmo.numero,
        _versicoloIdx,
        _fundoLabels[_fundoIdx],
      );
    } catch (_) {
      // Cancelamento ou erro — silencioso
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncSalmo = ref.watch(salmoDetalheProvider(widget.numero));
    final bg = context.colorBg;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: asyncSalmo.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: context.colorAccent,
              strokeWidth: 1.5,
            ),
          ),
          error: (_, __) => const _ErrorView(),
          data: (salmo) => salmo == null
              ? const _ErrorView()
              : _CompositorBody(
                  salmo: salmo,
                  cardKey: _cardKey,
                  versicoloIdx: _versicoloIdx,
                  fundoIdx: _fundoIdx,
                  sharing: _sharing,
                  onVersicoloChanged: (i) => setState(() => _versicoloIdx = i),
                  onFundoChanged: (i) => setState(() => _fundoIdx = i),
                  onShare: () => _share(salmo),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CompositorBody extends StatelessWidget {
  final Salmo salmo;
  final GlobalKey cardKey;
  final int versicoloIdx;
  final int fundoIdx;
  final bool sharing;
  final ValueChanged<int> onVersicoloChanged;
  final ValueChanged<int> onFundoChanged;
  final VoidCallback onShare;

  const _CompositorBody({
    required this.salmo,
    required this.cardKey,
    required this.versicoloIdx,
    required this.fundoIdx,
    required this.sharing,
    required this.onVersicoloChanged,
    required this.onFundoChanged,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final border = context.colorBorder;

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.sp4),

                // Preview 1:1
                AspectRatio(
                  aspectRatio: 1,
                  child: RepaintBoundary(
                    key: cardKey,
                    child: _ShareCard(
                      salmo: salmo,
                      versicoloIdx: versicoloIdx,
                      fundo: _fundos[fundoIdx],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.sp6),

                const EyebrowLabel('Fundo'),
                const SizedBox(height: AppTheme.sp3),
                Row(
                  children: List.generate(_fundos.length, (i) => Padding(
                    padding: EdgeInsets.only(
                        right: i < _fundos.length - 1 ? AppTheme.sp3 : 0),
                    child: _FundoChip(
                      color: _fundos[i],
                      label: _fundoLabels[i],
                      selected: i == fundoIdx,
                      onTap: () => onFundoChanged(i),
                    ),
                  )),
                ),

                const SizedBox(height: AppTheme.sp6),

                const EyebrowLabel('Versículo'),
                const SizedBox(height: AppTheme.sp3),
                ...salmo.versiculos.asMap().entries.map((e) => _VersicoloOption(
                  index: e.key,
                  texto: e.value,
                  selected: e.key == versicoloIdx,
                  onTap: () => onVersicoloChanged(e.key),
                )),

                const SizedBox(height: AppTheme.sp8),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border, width: 0.5)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppTheme.sp5, AppTheme.sp4, AppTheme.sp5, AppTheme.sp5,
          ),
          child: _ShareButton(sharing: sharing, onTap: onShare),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de imagem (capturado via RepaintBoundary)
// ─────────────────────────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final Salmo salmo;
  final int versicoloIdx;
  final Color fundo;

  const _ShareCard({
    required this.salmo,
    required this.versicoloIdx,
    required this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    final verse = salmo.versiculos.isNotEmpty
        ? salmo.versiculos[versicoloIdx.clamp(0, salmo.versiculos.length - 1)]
        : '';

    final isLightBg = fundo.computeLuminance() > 0.5;
    final verseColor   = isLightBg ? AppColors.goldInk   : AppColors.gold;
    final eyebrowColor = isLightBg ? AppColors.dayMuted   : AppColors.cobalt400;
    final logoWordColor = isLightBg
        ? AppColors.dayTitle.withAlpha(153)
        : AppColors.nightCream.withAlpha(153);
    final logoSalmoColor = isLightBg ? AppColors.cobalt500 : AppColors.cobalt400;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: fundo,
      padding: const EdgeInsets.all(AppTheme.sp8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Text(
            'SALMO ${salmo.numero}',
            style: AppTheme.eyebrowLabel(eyebrowColor),
          ),
          const Spacer(),

          // Versículo
          Text(
            '"$verse"',
            style: GoogleFonts.cormorant(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: verseColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppTheme.sp4),

          // Referência
          Text(
            '${salmo.numero} · ${versicoloIdx + 1}',
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: eyebrowColor,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),

          // Logotipo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O MEU',
                style: GoogleFonts.instrumentSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: logoWordColor,
                  letterSpacing: 8 * 0.34,
                ),
              ),
              Text(
                'Salmo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: logoSalmoColor,
                  height: 0.9,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FundoChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FundoChip({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border  = context.colorBorder;
    final accent  = context.colorAccent;
    final lblClr  = context.colorText;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppTheme.durFast,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: selected ? accent : border,
                width: selected ? 2 : 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sp1 + 2),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              color: selected ? accent : lblClr,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersicoloOption extends StatelessWidget {
  final int index;
  final String texto;
  final bool selected;
  final VoidCallback onTap;

  const _VersicoloOption({
    required this.index,
    required this.texto,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = context.colorSurface;
    final border  = context.colorBorder;
    final accent  = context.colorAccent;
    final textClr = context.colorText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durFast,
        margin: const EdgeInsets.only(bottom: AppTheme.sp2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp4,
          vertical: AppTheme.sp3,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withAlpha(26) : surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: selected ? accent : border,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 10,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.sp2),
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.cormorant(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: textClr,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final border   = context.colorBorder;
    final muted    = context.colorMuted;
    final titleClr = context.colorTitle;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp5, AppTheme.sp3,
      ),
      child: Row(
        children: [
          CircleIconButton(
            onTap: () => context.popOrGo('/salmos'),
            semanticsLabel: 'Voltar',
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
          const SizedBox(width: AppTheme.sp3),
          Text(
            'Compositor',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: titleClr,
              letterSpacing: -0.33,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final bool sharing;
  final VoidCallback onTap;

  const _ShareButton({required this.sharing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = context.colorAccent;

    return GestureDetector(
      onTap: sharing ? null : onTap,
      child: AnimatedContainer(
        duration: AppTheme.durFast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3 + 2),
        decoration: BoxDecoration(
          color: sharing ? accent.withAlpha(128) : accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: sharing
              ? null
              : [
                  BoxShadow(
                    color: AppColors.cobalt600.withAlpha(77),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Center(
          child: sharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.nightCream,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.ios_share_rounded,
                      size: 16,
                      color: AppColors.nightCream,
                    ),
                    const SizedBox(width: AppTheme.sp2),
                    Text(
                      'Compartilhar',
                      style: AppTheme.emphasisTracked15(AppColors.nightCream),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) => ErrorStateView(
        titulo: 'Não foi possível abrir o compositor',
        mensagem: 'Feche e tente de novo.',
        icon: Icons.image_not_supported_outlined,
        acaoLabel: 'Fechar',
        onAcao: () => context.pop(),
      );
}
