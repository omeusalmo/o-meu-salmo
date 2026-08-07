import 'package:flutter/material.dart';
import '../../core/extensions/build_context_extensions.dart';

/// Botão circular com borda fina — voltar, fechar, ação de ícone em headers
/// customizados. Borda sempre em `context.colorBorder` (acompanha dark/light).
class CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final String semanticsLabel;
  final double size;

  const CircleIconButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.semanticsLabel,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colorBorder, width: 0.5),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
