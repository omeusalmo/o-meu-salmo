import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Luz ambiente radial — a cor da emoção tinge o fundo da tela, como o
/// `#ambient` da LP V2. Use dentro de um Stack, atrás do conteúdo.
///
/// A troca de cor anima suavemente (AnimatedContainer interpola o gradiente).
class AmbientGlow extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double radius;
  final int alpha;

  const AmbientGlow({
    super.key,
    required this.color,
    this.alignment = const Alignment(0, -0.6),
    this.radius = 1.1,
    this.alpha = 36,
  });

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.of(context).disableAnimations;

    return IgnorePointer(
      child: AnimatedContainer(
        duration: disable ? Duration.zero : AppTheme.durSlow,
        curve: AppTheme.ease,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [
              color.withAlpha(alpha),
              color.withAlpha(0),
            ],
            stops: const [0.0, 0.75],
          ),
        ),
      ),
    );
  }
}
