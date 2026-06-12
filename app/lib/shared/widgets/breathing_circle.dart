import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Círculo de respiração guiada — ciclo de 9s: 4s inspira, 1s segura,
/// 4s expira. Conceito do interlúdio "Respire" da LP V2.
///
/// Com MediaQuery.disableAnimations mostra o círculo estático com o
/// convite "Respire".
class BreathingCircle extends StatefulWidget {
  final double size;

  const BreathingCircle({super.key, this.size = 230});

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  static const _cycle = Duration(seconds: 9);

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  // 4s sobe (1 → 1.34), 1s segura, 4s desce (1.34 → 1)
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.34)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 4,
    ),
    TweenSequenceItem(tween: ConstantTween(1.34), weight: 1),
    TweenSequenceItem(
      tween: Tween(begin: 1.34, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 4,
    ),
  ]).animate(_ctrl);

  bool _started = false;
  bool _animar = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    _animar = !MediaQuery.of(context).disableAnimations;
    if (_animar) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _cue {
    if (!_animar) return 'Respire';
    final v = _ctrl.value;
    if (v < 4 / 9) return 'Inspire';
    if (v < 5 / 9) return 'Segure';
    return 'Expire';
  }

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;

    return Semantics(
      label: 'Respiração guiada. Inspire por quatro segundos, '
          'segure por um, expire por quatro.',
      excludeSemantics: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final s = _scale.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Anel externo — respira junto, mais discreto
                Transform.scale(
                  scale: 1 + (s - 1) * 0.45,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cobalt400.withAlpha(90),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Núcleo — gradiente radial cobalto
                Transform.scale(
                  scale: s,
                  child: Container(
                    width: widget.size * 0.66,
                    height: widget.size * 0.66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.cobalt400.withAlpha(80),
                          AppColors.cobalt500.withAlpha(28),
                          AppColors.cobalt500.withAlpha(0),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Cue textual
                Text(
                  _cue.toUpperCase(),
                  style: GoogleFonts.instrumentSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 3.74,
                    color: titleClr,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
