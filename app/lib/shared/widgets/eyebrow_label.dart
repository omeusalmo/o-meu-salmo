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
    // nightMuted (1.90:1) e dayMuted (2.62:1) reprovam WCAG AA para texto normal.
    // nightText (6.9:1) e dayText (9.5:1) garantem AA.
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
