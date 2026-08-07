import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ambient_glow.dart';
import '../../shared/widgets/breathing_circle.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/eyebrow_label.dart';
import '../../shared/widgets/staggered_entrance.dart';

/// Um momento para respirar — ciclo guiado 4-1-4 com o Salmo 46.
/// Interlúdio "Respire" da LP V2, agora dentro do app.
class RespirarScreen extends StatelessWidget {
  const RespirarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = context.colorBg;
    final muted = context.colorText;
    final scripture = context.colorVerse;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AmbientGlow(
              color: AppColors.cobalt500,
              alignment: Alignment.center,
              alpha: 28,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Fechar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.sp3, AppTheme.sp1 + 2, AppTheme.sp3, 0,
                  ),
                  child: Row(
                    children: [
                      CircleIconButton(
                        onTap: () => context.pop(),
                        semanticsLabel: 'Fechar',
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const StaggeredEntrance(
                  index: 0,
                  child: EyebrowLabel('Um momento'),
                ),
                const SizedBox(height: AppTheme.sp10),
                const StaggeredEntrance(
                  index: 1,
                  child: BreathingCircle(),
                ),
                const SizedBox(height: AppTheme.sp12),
                StaggeredEntrance(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sp8,
                    ),
                    child: Text(
                      '"Aquietai-vos, e sabei que eu sou Deus."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorant(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: scripture,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.sp3),
                StaggeredEntrance(
                  index: 3,
                  child: Text(
                    'SALMO 46 · 10',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2.6,
                      color: muted,
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: AppTheme.sp8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
