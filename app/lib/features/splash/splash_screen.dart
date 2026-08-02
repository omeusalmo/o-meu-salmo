import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/review/review_service.dart';
import '../../data/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Bookmark — entra primeiro
  late Animation<double> _bookmarkFade;
  late Animation<double> _bookmarkSlide;
  late Animation<double> _bookmarkScale;

  // "O MEU" — segunda onda
  late Animation<double> _eyebrowFade;
  late Animation<Offset> _eyebrowSlide;

  // "Salmo" — terceira onda
  late Animation<double> _titleFade;
  late Animation<double> _titleScale;
  late Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();

    // Aquece o provider em T+0 para que _load() complete antes do delay de 3s
    ref.read(onboardingProvider);
    ReviewService.instance.incrementSession();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Bookmark: fade 0–35%, slide 0–50%, scale easeOutBack 0–45%
    _bookmarkFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _bookmarkSlide = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );
    _bookmarkScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // "O MEU": fade + slide up 30–60%
    _eyebrowFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.60, curve: Curves.easeOut),
    );
    _eyebrowSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.60, curve: Curves.easeOutCubic),
    ));

    // "Salmo": fade + scale + slide up 40–78%
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.78, curve: Curves.easeOut),
    );
    _titleScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.78, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.78, curve: Curves.easeOutCubic),
    ));

    _controller.forward();

    // Navega logo após a animação (1800ms) + respiro curto. Antes: 3000ms cegos.
    // onboardingProvider (prefs, ~ms) já resolveu bem antes disso.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final done = ref.read(onboardingProvider);
      context.go(done ? '/home' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final noMotion = MediaQuery.of(context).disableAnimations;

    final bookmarkFade =
        noMotion ? const AlwaysStoppedAnimation<double>(1.0) : _bookmarkFade;
    final bookmarkScale =
        noMotion ? const AlwaysStoppedAnimation<double>(1.0) : _bookmarkScale;
    final eyebrowFade =
        noMotion ? const AlwaysStoppedAnimation<double>(1.0) : _eyebrowFade;
    final eyebrowSlide = noMotion
        ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
        : _eyebrowSlide;
    final titleFade =
        noMotion ? const AlwaysStoppedAnimation<double>(1.0) : _titleFade;
    final titleScale =
        noMotion ? const AlwaysStoppedAnimation<double>(1.0) : _titleScale;
    final titleSlide = noMotion
        ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
        : _titleSlide;

    return Scaffold(
      backgroundColor: const Color(0xFF2A47DD),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4363F0),
              Color(0xFF2A47DD),
              Color(0xFF1B33B4),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Bookmark — cai do topo com scale easeOutBack
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Positioned(
                top: topPadding + 24 + (noMotion ? 0 : _bookmarkSlide.value),
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: bookmarkFade,
                  child: Center(
                    child: ScaleTransition(
                      scale: bookmarkScale,
                      child: const _BookmarkIcon(),
                    ),
                  ),
                ),
              ),
            ),

            // Logo: "O MEU" + "Salmo" em ondas separadas
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: eyebrowFade,
                    child: SlideTransition(
                      position: eyebrowSlide,
                      child: Text(
                        'O MEU',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha(200),
                          letterSpacing: 5.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FadeTransition(
                    opacity: titleFade,
                    child: SlideTransition(
                      position: titleSlide,
                      child: ScaleTransition(
                        scale: titleScale,
                        child: Text(
                          'Salmo',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 80,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 0.92,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 70,
      child: CustomPaint(
        painter: _BookmarkPainter(),
      ),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
