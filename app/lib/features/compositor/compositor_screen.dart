import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/eyebrow_label.dart';

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

  static const _fundos = [
    Color(0xFF080B1C), // Noite — nightBase
    Color(0xFF10142C), // Profundo — nightPlus
    Color(0xFF2A47DD), // Cobalto — accent
  ];
  static const _fundoLabels = ['Noite', 'Profundo', 'Cobalto'];

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
      final verse = salmo.versiculos[_versicoloIdx];
      final refStr = 'Salmo ${salmo.numero} · ${_versicoloIdx + 1}';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.nightBase : AppColors.dayBase;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: asyncSalmo.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
              strokeWidth: 1.5,
            ),
          ),
          error: (_, __) => _ErrorView(isDark: isDark),
          data: (salmo) => salmo == null
              ? _ErrorView(isDark: isDark)
              : _CompositorBody(
                  salmo: salmo,
                  cardKey: _cardKey,
                  versicoloIdx: _versicoloIdx,
                  fundoIdx: _fundoIdx,
                  fundos: _fundos,
                  fundoLabels: _fundoLabels,
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
  final List<Color> fundos;
  final List<String> fundoLabels;
  final bool sharing;
  final ValueChanged<int> onVersicoloChanged;
  final ValueChanged<int> onFundoChanged;
  final VoidCallback onShare;

  const _CompositorBody({
    super.key,
    required this.salmo,
    required this.cardKey,
    required this.versicoloIdx,
    required this.fundoIdx,
    required this.fundos,
    required this.fundoLabels,
    required this.sharing,
    required this.onVersicoloChanged,
    required this.onFundoChanged,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.nightLine : AppColors.dayLine;

    return Column(
      children: [
        _Header(isDark: isDark),
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
                      fundo: fundos[fundoIdx],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.sp6),

                EyebrowLabel('Fundo'),
                const SizedBox(height: AppTheme.sp3),
                Row(
                  children: List.generate(fundos.length, (i) => Padding(
                    padding: EdgeInsets.only(
                        right: i < fundos.length - 1 ? AppTheme.sp3 : 0),
                    child: _FundoChip(
                      color: fundos[i],
                      label: fundoLabels[i],
                      selected: i == fundoIdx,
                      onTap: () => onFundoChanged(i),
                    ),
                  )),
                ),

                const SizedBox(height: AppTheme.sp6),

                EyebrowLabel('Versículo'),
                const SizedBox(height: AppTheme.sp3),
                ...salmo.versiculos.asMap().entries.map((e) => _VersicoloOption(
                  index: e.key,
                  texto: e.value,
                  selected: e.key == versicoloIdx,
                  isDark: isDark,
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
    super.key,
    required this.salmo,
    required this.versicoloIdx,
    required this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    final verse = salmo.versiculos.isNotEmpty
        ? salmo.versiculos[versicoloIdx.clamp(0, salmo.versiculos.length - 1)]
        : '';

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
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.cobalt400,
              letterSpacing: 3.74,
            ),
          ),
          const Spacer(),

          // Versículo em âmbar
          Text(
            '"$verse"',
            style: GoogleFonts.cormorant(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.gold,
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
              color: AppColors.cobalt400,
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
                  color: AppColors.nightCream.withAlpha(153),
                  letterSpacing: 8 * 0.34,
                ),
              ),
              Text(
                'Salmo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cobalt400,
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
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final accent  = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final lblClr  = isDark ? AppColors.nightText  : AppColors.dayText;

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
  final bool isDark;
  final VoidCallback onTap;

  const _VersicoloOption({
    super.key,
    required this.index,
    required this.texto,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.nightPlus  : AppColors.dayPlus;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final accent  = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final textClr = isDark ? AppColors.nightText  : AppColors.dayText;

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
  final bool isDark;
  const _Header({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border   = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted    = isDark ? AppColors.nightMuted : AppColors.dayMuted;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp5, AppTheme.sp3,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/salmos'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 0.5),
              ),
              child: Center(
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
              ),
            ),
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

  const _ShareButton({super.key, required this.sharing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;

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
                      style: GoogleFonts.instrumentSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.nightCream,
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

class _ErrorView extends StatelessWidget {
  final bool isDark;
  const _ErrorView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Não foi possível abrir o compositor. Tente fechar e reabrir.',
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          color: isDark ? AppColors.nightText : AppColors.dayText,
        ),
      ),
    );
  }
}
