import 'package:flutter/material.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Rótulo de sobrelinha — Instrument Sans uppercase, tracking largo.
/// Equivalente ao `.ds-eyebrow` do Design System.
///
/// Uso: contexto de emoção ("PARA A ANSIEDADE"), seção ("REFLEXÃO"), tradução.
class EyebrowLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const EyebrowLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // Continua em colorText mesmo depois do DS v1.2 ter subido os muted para
    // AA: muted é rótulo de metadado e dot, e aqui o eyebrow é conteúdo.
    // nightText 6.05:1 e dayText 8.19:1 sobre a superfície.
    final defaultColor = context.colorText;

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Text(
        text.toUpperCase(),
        style: AppTheme.eyebrowLabel(color ?? defaultColor),
      ),
    );
  }
}
