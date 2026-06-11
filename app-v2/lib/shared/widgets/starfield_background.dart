import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';

/// Fundo de partículas calmas — deriva vertical lenta + cintilação suave.
/// Conceito da LP V2 portado para o app ("starfield").
///
/// Pinta atrás do conteúdo (use dentro de um Stack com Positioned.fill).
/// Com MediaQuery.disableAnimations vira um céu estático, sem ticker.
class StarfieldBackground extends StatefulWidget {
  final int particleCount;

  const StarfieldBackground({super.key, this.particleCount = 70});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  // Um ciclo completo de deriva dura 60s — lento o bastante para acalmar.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  late final List<_Star> _stars = _seed(widget.particleCount);

  // Semente fixa: o céu é o mesmo a cada abertura — constância, não ruído.
  static List<_Star> _seed(int count) {
    final rnd = Random(7);
    return List.generate(count, (_) {
      return _Star(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        radius: 0.4 + rnd.nextDouble() * 1.2,
        speed: 0.004 + rnd.nextDouble() * 0.016,
        phase: rnd.nextDouble() * 2 * pi,
        depth: 0.4 + rnd.nextDouble() * 0.6,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.colorTitle;

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _StarfieldPainter(
            stars: _stars,
            animation: _ctrl,
            color: baseColor,
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double speed; // fração da altura por segundo
  final double phase;
  final double depth; // 0..1 — profundidade afeta brilho

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.depth,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> animation;
  final Color color;

  _StarfieldPainter({
    required this.stars,
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 60; // segundos decorridos no ciclo
    final paint = Paint();

    for (final s in stars) {
      // Deriva para cima, com wrap vertical
      final y = ((s.y - t * s.speed) % 1.0 + 1.0) % 1.0;
      // Cintilação senoidal por fase própria
      final twinkle = 0.30 + 0.55 * (0.5 + 0.5 * sin(t * 0.7 + s.phase));
      final alpha = (90 * twinkle * s.depth).round().clamp(0, 255);

      paint.color = color.withAlpha(alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, y * size.height),
        s.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.color != color || old.stars != stars;
}
