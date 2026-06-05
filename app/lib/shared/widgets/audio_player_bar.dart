import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/audio_provider.dart';

/// Barra de player de áudio.
///
/// Carrega o áudio via [audioPath] ao montar. Se o arquivo não existe no
/// bundle ainda, exibe o player desabilitado — sem erro visível ao usuário.
/// Quando os MP3s chegarem em assets/audios/, funciona sem mudança de código.
class AudioPlayerBar extends ConsumerStatefulWidget {
  final String audioPath;

  const AudioPlayerBar({super.key, required this.audioPath});

  @override
  ConsumerState<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends ConsumerState<AudioPlayerBar> {
  @override
  void initState() {
    super.initState();
    // Carrega após o frame para não bloquear o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioPlayerProvider.notifier).load(widget.audioPath);
    });
  }

  @override
  void didUpdateWidget(AudioPlayerBar old) {
    super.didUpdateWidget(old);
    if (old.audioPath != widget.audioPath) {
      ref.read(audioPlayerProvider.notifier).load(widget.audioPath);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audio  = ref.watch(audioPlayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;
    final border = isDark ? AppColors.nightLine : AppColors.dayLine;
    final text   = isDark ? AppColors.nightText : AppColors.dayText;
    final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final muted  = isDark ? AppColors.nightText  : AppColors.dayText;

    final available = audio.isAvailable;
    final btnColor  = available ? accent : muted;

    // Progresso 0.0–1.0
    final progress = (audio.duration.inMilliseconds > 0)
        ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp5,
        vertical: AppTheme.sp3 + 2,
      ),
      child: Row(
        children: [
          // Botão play/pause
          GestureDetector(
            onTap: available
                ? () => ref.read(audioPlayerProvider.notifier).playPause()
                : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: btnColor,
                shape: BoxShape.circle,
                boxShadow: available
                    ? [
                        BoxShadow(
                          color: AppColors.cobalt600.withAlpha(77),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: audio.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.nightCream,
                        ),
                      )
                    : _PlayerIcon(isPlaying: audio.isPlaying),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp3),

          // Timecode posição
          Text(
            available ? _fmt(audio.position) : '0:00',
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              color: available ? text : muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppTheme.sp2 + 2),

          // Barra de progresso com seek
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
              onTapUp: available
                  ? (d) {
                      final ratio = (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                      final target = Duration(
                        milliseconds:
                            (audio.duration.inMilliseconds * ratio).round(),
                      );
                      ref.read(audioPlayerProvider.notifier).seek(target);
                    }
                  : null,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Progress fill — interpolado para suavidade
                  if (available)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  // Thumb — segue o mesmo tween do fill
                  if (available)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => Positioned(
                        left: 0,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cobalt400
                                    : AppColors.cobalt500,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(width: AppTheme.sp2 + 2),

          // Timecode duração
          Text(
            available ? _fmt(audio.duration) : '--:--',
            style: GoogleFonts.instrumentSans(
              fontSize: 10,
              color: isDark ? AppColors.nightText : AppColors.dayText,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PlayerIcon extends StatelessWidget {
  final bool isPlaying;
  const _PlayerIcon({super.key, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    // Triângulo em creme — contraste 6.2:1 (AAA) sobre cobalto
    const color = AppColors.nightCream;
    if (isPlaying) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 3, height: 12, color: color),
          const SizedBox(width: 3),
          Container(width: 3, height: 12, color: color),
        ],
      );
    }
    return CustomPaint(
      size: const Size(10, 12),
      painter: _TrianglePainter(color: color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
