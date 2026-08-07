import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Estado de erro / vazio acolhedor e consistente (cobalt DS).
///
/// Informa o que houve em linguagem simples e sóbria e oferece uma saída
/// (tentar de novo / voltar). Usado em falhas de carregamento e rotas inválidas
/// para que o usuário nunca fique num spinner sem explicação nem caminho.
class ErrorStateView extends StatelessWidget {
  final String titulo;
  final String? mensagem;
  final IconData icon;
  final String? acaoLabel;
  final VoidCallback? onAcao;

  const ErrorStateView({
    super.key,
    required this.titulo,
    this.mensagem,
    this.icon = Icons.cloud_off_outlined,
    this.acaoLabel,
    this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    final accent = context.colorAccent;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: accent.withValues(alpha: 0.55)),
            const SizedBox(height: AppTheme.sp4),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                color: context.colorTitle,
                height: 1.2,
              ),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: AppTheme.sp2),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: context.colorText,
                  height: 1.55,
                ),
              ),
            ],
            if (onAcao != null && acaoLabel != null) ...[
              const SizedBox(height: AppTheme.sp5),
              OutlinedButton(
                onPressed: onAcao,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.5)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sp6,
                    vertical: AppTheme.sp3,
                  ),
                ),
                child: Text(
                  acaoLabel!,
                  style: AppTheme.emphasis14(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
