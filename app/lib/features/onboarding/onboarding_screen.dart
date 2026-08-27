import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/notifications/agendador.dart';
import '../../data/providers/salmos_providers.dart';
import '../../data/providers/onboarding_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../shared/widgets/bookmark_painter.dart';

/// Teto de ampliação de fonte das telas de onboarding que ainda não rolam.
/// Some quando elas virarem SingleChildScrollView, como as telas 3 e 4.
const double _tetoTelasSemRolagem = 1.3;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  EmocaoInicial _selectedEmocao = EmocaoInicial.paz;
  bool _querNotificacao = false;

  /// Passos vistos até aqui.
  ///
  /// A coleta de dados nasce desligada (LGPD) e só é ligada na última página,
  /// então evento disparado antes disso é descartado pelo SDK, não enfileirado.
  /// Guardar aqui e despejar em _complete é o que faz o funil do primeiro
  /// minuto existir de fato.
  final _passosVistos = <int>{1};
  int? _puloNoPasso;

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
    // Quem pula nunca chega à página de consentimento, então a coleta segue
    // desligada e não há o que registrar. Fica guardado só para o caso de o
    // fluxo mudar no futuro.
    _puloNoPasso = _currentPage + 1;
    await ref.read(onboardingProvider.notifier).markDone();
    if (mounted) context.go('/home');
  }

  Future<void> _complete(bool allowUsageData) async {
    await ref.read(usageDataProvider.notifier).set(allowUsageData);
    await ref.read(emocaoInicialProvider.notifier).set(_selectedEmocao);

    // A permissão foi concedida na tela anterior; aqui a preferência é gravada
    // e a primeira janela de avisos entra na agenda.
    // Só agora a coleta pode estar ligada. Despeja o que foi acumulado antes.
    if (allowUsageData) {
      for (final passo in _passosVistos.toList()..sort()) {
        AnalyticsService.instance.logOnboardingStep(passo);
      }
      if (_puloNoPasso != null) {
        AnalyticsService.instance.logOnboardingSkipped(_puloNoPasso!);
      }
      AnalyticsService.instance.logNotifPermission(
        concedida: _querNotificacao,
        origem: 'onboarding',
      );
    }

    AnalyticsService.instance.logOnboardingDone(
      emocao: _selectedEmocao.name,
      dadosDeUso: allowUsageData,
      notificacao: _querNotificacao,
    );
    AnalyticsService.instance.setEmocaoInicial(_selectedEmocao.name);
    AnalyticsService.instance.setNotifEnabled(_querNotificacao);

    if (_querNotificacao) {
      await ref.read(notificationSettingsProvider.notifier).setEnabled(true);
      try {
        final salmos = await ref.read(salmosProvider.future);
        await AgendadorSalmoDiario.reagendar(salmos);
      } catch (e) {
        debugPrint('[Notif] agendamento no onboarding falhou: $e');
      }
    }

    await ref.read(onboardingProvider.notifier).markDone();
    if (!mounted) return;
    // Sempre a Home. Antes ia direto para a coleção da emoção escolhida, o que
    // pulava o Salmo do Dia e deixava a pessoa numa lista sem nunca ter visto
    // a tela principal. A escolha não se perde: a coleção fica marcada com a
    // tag "sua escolha" na lista de coleções.
    context.go('/home');
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
            : (context.colorBg),
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _passosVistos.add(i + 1);
              },
              children: [
                // Telas 1 e 2 são Column com Spacer e sem rolagem: em 2.0x o
                // conteúdo estoura e o botão sai da área visível, deixando o
                // usuário preso no onboarding. Até elas virarem roláveis, o
                // teto local segura só estas duas.
                //
                // As telas 3 (grid emocional) e 4 (consentimento) ficam de fora
                // de propósito: ambas rolam e aguentam 2.0x. A 4 é o texto de
                // LGPD, que precisa ser legível no tamanho que a pessoa pediu.
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: _tetoTelasSemRolagem,
                  child: _Page1(onNext: _nextPage),
                ),
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: _tetoTelasSemRolagem,
                  child: _Page2(onNext: _nextPage),
                ),
                _Page3(
                  selected: _selectedEmocao,
                  onSelect: (e) => setState(() => _selectedEmocao = e),
                  onNext: _nextPage,
                ),
                _PageNotificacao(
                  onEscolher: (quer) async {
                    // Só dispara o diálogo do sistema para quem disse que
                    // quer. No Android 13+ duas recusas deixam a permissão
                    // negada em definitivo, então perguntar a frio queima a
                    // única chance que o app tem.
                    if (quer) {
                      _querNotificacao =
                          await NotificationService.instance.requestPermission();
                    } else {
                      _querNotificacao = false;
                    }
                    _nextPage();
                  },
                ),
                _Page4(onComplete: _complete),
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
                        color: context.colorText,
                      ),
                    ),
                  ),
                ),
              ),
            // Skip button — hidden on the consent page (last): a escolha ali
            // precisa ser explícita via um dos dois botões, não um atalho.
            if (_currentPage < 4)
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
                        style: AppTheme.caption14(_currentPage == 0
                              ? Colors.white.withAlpha(153)
                              : context.colorText),
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
                      5,
                      (i) => _ProgressDot(
                        active: i == _currentPage,
                        onCobalt: _currentPage == 0,
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

  const _ProgressDot({
    required this.active,
    required this.onCobalt,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        onCobalt ? Colors.white : AppColors.cobalt500;
    final Color inactiveColor = onCobalt
        ? Colors.white.withAlpha(77)
        : (context.colorMuted);

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
                child: CustomPaint(painter: BookmarkPainter()),
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
                  style: AppTheme.buttonLabel(Colors.white),
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
    final cardBg = context.colorSurface;
    final titleClr = context.colorTitle;
    final textClr = context.colorText;
    final border = context.colorBorder;

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
              style: AppTheme.sectionHeadline(titleClr),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Ansiedade, gratidão, cansaço ou esperança — cada emoção tem seu salmo esperando por você.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyRelaxed15(textClr),
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
                  style: AppTheme.buttonLabel(),
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
                    // Era cobalt500 fixo nos dois temas: 2.46:1 no escuro.
                    color: context.colorAccentText,
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
  final VoidCallback onNext;

  const _Page3({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final textClr = context.colorText;
    final mutedClr = context.colorMuted;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.sp10),
            Text(
              'Como você está\nse sentindo hoje?',
              textAlign: TextAlign.center,
              style: AppTheme.sectionHeadline(titleClr),
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
              // Célula acompanha a fonte: quanto maior o texto, mais baixa a
              // razão (mais alta a célula) — evita corte do label emocional.
              childAspectRatio:
                  (MediaQuery.of(context).size.width < 360 ? 2.0 : 2.4) /
                      MediaQuery.textScalerOf(context).scale(1),
              children: EmocaoInicial.values.map((e) {
                final isSelected = e == selected;
                return GestureDetector(
                  onTap: () => onSelect(e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      // Tinte e borda eram cobalt500 fixo nos dois temas: no
                      // escuro o rótulo selecionado dava 2.29:1, o pior
                      // contraste do app. Agora acompanham o tema.
                      color: isSelected
                          ? AppColors.cobalt500.withAlpha(26)
                          : (context.colorSurface),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? context.colorAccent
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
                                  ? context.colorAccentText
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
                  'Continuar',
                  style: AppTheme.buttonLabel(),
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

// ── Page 4: Consentimento de dados de uso (LGPD, opt-in explícito) ─────────────

/// Pré-permissão de notificação.
///
/// O pedido do sistema só aparece para quem tocou em "Quero receber". No
/// Android 13+ duas recusas do diálogo nativo deixam a permissão negada para
/// sempre, sem caminho de volta dentro do app; perguntar antes, em português e
/// com o valor explicado, preserva essa chance.
///
/// Vem logo depois da escolha do sentimento de propósito: é o momento em que a
/// promessa "um salmo para como você está hoje" está fresca.
class _PageNotificacao extends StatelessWidget {
  final ValueChanged<bool> onEscolher;

  const _PageNotificacao({required this.onEscolher});

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final textClr = context.colorText;
    final mutedClr = context.colorMuted;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.sp10),
            Text(
              'Um Salmo por dia',
              textAlign: TextAlign.center,
              style: AppTheme.sectionHeadline(titleClr),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Todo dia, no horário que você escolher, um Salmo novo chega pra você. Sem correria e sem cobrança.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: textClr,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Dá pra desligar ou mudar a hora quando quiser, em Ajustes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: mutedClr,
              ),
            ),
            const SizedBox(height: AppTheme.sp6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onEscolher(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt500,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.sp4),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text('Quero receber', style: AppTheme.buttonLabel()),
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => onEscolher(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.sp4),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Agora não',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textClr,
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

class _Page4 extends StatelessWidget {
  final ValueChanged<bool> onComplete;

  const _Page4({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final textClr = context.colorText;
    final mutedClr = context.colorMuted;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.sp10),
            Text(
              'Antes de continuar',
              textAlign: TextAlign.center,
              style: AppTheme.sectionHeadline(titleClr),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Usamos dados de uso, de forma anônima, pra entender o que ajuda e corrigir o que não funciona. Nunca vendemos nem compartilhamos nada.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: textClr,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'Você pode mudar isso a qualquer hora em Ajustes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: mutedClr,
              ),
            ),
            const SizedBox(height: AppTheme.sp6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onComplete(true),
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
                  'Permitir dados anônimos',
                  style: AppTheme.buttonLabel(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => onComplete(false),
                style: TextButton.styleFrom(
                  foregroundColor: textClr,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.sp4),
                ),
                child: Text(
                  'Prefiro não',
                  style: AppTheme.buttonLabel(),
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
