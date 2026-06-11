import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  EmocaoInicial _selectedEmocao = EmocaoInicial.paz;

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _prevPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() async {
    await ref.read(onboardingProvider.notifier).markDone();
    if (mounted) context.go('/home');
  }

  Future<void> _complete() async {
    await ref.read(emocaoInicialProvider.notifier).set(_selectedEmocao);
    await ref.read(onboardingProvider.notifier).markDone();
    if (!mounted) return;
    final colId = _selectedEmocao.colecaoId;
    context.go(colId.isNotEmpty ? '/colecoes/$colId' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _currentPage == 0
            ? Brightness.light
            : (isDark ? Brightness.light : Brightness.dark),
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _currentPage == 0
            ? const Color(0xFF2A47DD)
            : (isDark ? AppColors.nightBase : AppColors.dayBase),
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _Page1(onNext: _nextPage),
                _Page2(onNext: _nextPage),
                _Page3(
                  selected: _selectedEmocao,
                  onSelect: (e) => setState(() => _selectedEmocao = e),
                  onComplete: _complete,
                ),
              ],
            ),
            // Back button — visible on pages 1 and 2
            if (_currentPage > 0)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _prevPage,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppTheme.sp5,
                        top: AppTheme.sp3,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22,
                        color: isDark ? AppColors.nightText : AppColors.dayText,
                      ),
                    ),
                  ),
                ),
              ),
            // Skip button — visible on pages 0 and 1 only
            if (_currentPage < 2)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _skip,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppTheme.sp5,
                        top: AppTheme.sp3,
                      ),
                      child: Text(
                        'Pular',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          color: _currentPage == 0
                              ? Colors.white.withAlpha(153)
                              : (isDark
                                  ? AppColors.nightText
                                  : AppColors.dayText),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Progress dots
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sp5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => _ProgressDot(
                        active: i == _currentPage,
                        onCobalt: _currentPage == 0,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool active;
  final bool onCobalt;
  final bool isDark;

  const _ProgressDot({
    required this.active,
    required this.onCobalt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        onCobalt ? Colors.white : AppColors.cobalt500;
    final Color inactiveColor = onCobalt
        ? Colors.white.withAlpha(77)
        : (isDark ? AppColors.nightMuted : AppColors.dayMuted);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Page 1: Welcome (cobalt gradient) ─────────────────────────────────────────

class _Page1 extends StatelessWidget {
  final VoidCallback onNext;

  const _Page1({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4363F0), Color(0xFF2A47DD), Color(0xFF1B33B4)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp6),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const SizedBox(
                width: 48,
                height: 70,
                child: CustomPaint(painter: _BookmarkPainter()),
              ),
              const SizedBox(height: AppTheme.sp8),
              Text(
                'Seu refúgio\ncomeça agora',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppTheme.sp4),
              Text(
                'Encontre o salmo certo para o que você está sentindo, a qualquer hora do dia.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorant(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withAlpha(204),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              OutlinedButton(
                onPressed: onNext,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54, width: 1),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sp12,
                    vertical: AppTheme.sp4,
                  ),
                ),
                child: Text(
                  'Quero começar',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.sp8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 2: How it works (theme-based) ────────────────────────────────────────

class _Page2 extends StatelessWidget {
  final VoidCallback onNext;

  const _Page2({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? AppColors.nightPlus : Colors.white;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final textClr = isDark ? AppColors.nightText : AppColors.dayText;
    final border = isDark ? AppColors.nightLine : AppColors.dayLine;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp6),
        child: Column(
          children: [
            const Spacer(flex: 2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, minHeight: 120),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.10,
                    child: Opacity(
                      opacity: 0.4,
                      child: _CollectionCard(
                        emoji: '💪',
                        colecao: 'Esperança',
                        verso: 'O Senhor é minha luz e minha salvação.',
                        cardBg: cardBg,
                        border: border,
                        titleClr: titleClr,
                        textClr: textClr,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.05,
                    child: Opacity(
                      opacity: 0.7,
                      child: _CollectionCard(
                        emoji: '🙏',
                        colecao: 'Gratidão',
                        verso: 'Dai graças ao Senhor, porque ele é bom.',
                        cardBg: cardBg,
                        border: border,
                        titleClr: titleClr,
                        textClr: textClr,
                      ),
                    ),
                  ),
                  _CollectionCard(
                    emoji: '🌙',
                    colecao: 'Sono',
                    verso: 'Em paz me deitarei e logo adormeço.',
                    cardBg: cardBg,
                    border: border,
                    titleClr: titleClr,
                    textClr: textClr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.sp8),
            Text(
              'Salmos feitos para o seu momento',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: titleClr,
                letterSpacing: -0.42,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Ansiedade, gratidão, cansaço ou esperança — cada emoção tem seu salmo esperando por você.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 15,
                color: textClr,
                height: 1.6,
              ),
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt500,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.sp4),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Isso é o que preciso',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sp8),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final String emoji;
  final String colecao;
  final String verso;
  final Color cardBg;
  final Color border;
  final Color titleClr;
  final Color textClr;

  const _CollectionCard({
    required this.emoji,
    required this.colecao,
    required this.verso,
    required this.cardBg,
    required this.border,
    required this.titleClr,
    required this.textClr,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.sp5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(31),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppTheme.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  colecao,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    color: AppColors.cobalt500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  verso,
                  style: GoogleFonts.cormorant(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: textClr,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

// ── Page 3: Emotion picker ─────────────────────────────────────────────────────

class _Page3 extends StatelessWidget {
  final EmocaoInicial selected;
  final ValueChanged<EmocaoInicial> onSelect;
  final VoidCallback onComplete;

  const _Page3({
    required this.selected,
    required this.onSelect,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final textClr = isDark ? AppColors.nightText : AppColors.dayText;
    final mutedClr = isDark ? AppColors.nightMuted : AppColors.dayMuted;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.sp10),
            Text(
              'Como você está\nse sentindo hoje?',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: titleClr,
                letterSpacing: -0.42,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Escolha o que mais combina com agora e encontre o salmo que foi escrito pra esse exato momento.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: textClr,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppTheme.sp6),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppTheme.sp3,
              crossAxisSpacing: AppTheme.sp3,
              childAspectRatio: MediaQuery.of(context).size.width < 360 ? 2.0 : 2.4,
              children: EmocaoInicial.values.map((e) {
                final isSelected = e == selected;
                return GestureDetector(
                  onTap: () => onSelect(e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cobalt500.withAlpha(26)
                          : (isDark ? AppColors.nightPlus : AppColors.dayPlus),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.cobalt500
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppTheme.sp2),
                        Flexible(
                          child: Text(
                            e.label,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.cobalt500
                                  : textClr,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Você pode mudar isso a qualquer hora.',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: mutedClr,
              ),
            ),
            const SizedBox(height: AppTheme.sp6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt500,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.sp4),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Encontrar meu salmo',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sp8),
          ],
        ),
      ),
    );
  }
}

// ── Bookmark (mesma forma da splash screen) ────────────────────────────────────

class _BookmarkPainter extends CustomPainter {
  const _BookmarkPainter();

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
