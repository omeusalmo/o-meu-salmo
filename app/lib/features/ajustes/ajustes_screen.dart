import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/link_service.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/salmos_providers.dart';
import '../../data/providers/settings_provider.dart';
import '../../shared/widgets/circle_icon_button.dart';

/// Altura mínima de qualquer coisa tocável nesta tela.
/// Material e WCAG 2.2 (2.5.8) pedem 44–48dp; o público do app tem 60–75 anos,
/// então o piso é o maior dos dois.
const double _alvoMinimo = 48;

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = context.colorBg;
    final titleClr = context.colorTitle;
    final border = context.colorBorder;
    final muted = context.colorText;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          // Sem `size`: o padrão do CircleIconButton já é 44dp. O 36 anterior
          // deixava o alvo de toque abaixo do mínimo.
          child: CircleIconButton(
            onTap: () => context.popOrGo('/'),
            semanticsLabel: 'Voltar',
            child:
                Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: muted),
          ),
        ),
        title: Text(
          'Ajustes',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: titleClr,
            letterSpacing: -0.33,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: border),
        ),
      ),
      // Ordem: o que a pessoa mexe (aparência, notificação), o que ela precisa
      // saber (privacidade, sobre), e só então o pedido de apoio. Doação por
      // último é decisão de produto: pedir dinheiro não abre a tela.
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp5,
          vertical: AppTheme.sp4,
        ),
        children: const [
          _SectionHeader('Aparência'),
          _AparenciaSection(),
          SizedBox(height: AppTheme.sp5),

          _SectionHeader('Notificações'),
          _NotificationCard(),
          SizedBox(height: AppTheme.sp5),

          _SectionHeader('Privacidade'),
          _PrivacidadeSection(),
          SizedBox(height: AppTheme.sp5),

          _SectionHeader('Sobre'),
          _SobreSection(),
          SizedBox(height: AppTheme.sp5),

          _SectionHeader('Sugestões'),
          _SugestoesSection(),
          SizedBox(height: AppTheme.sp5),

          _SectionHeader('Apoie o app'),
          _ApoieSection(),
          SizedBox(height: AppTheme.sp10),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Aparência — lista de escolha de tema
//
// Antes era um SegmentedButton. O Material divide o card em três partes iguais
// e o segmento selecionado ainda gasta ~26dp com o check, então "Sistema" era
// cortado já em 1.0x. Em lista, cada opção tem a largura inteira do card e o
// rótulo cabe em qualquer escala de fonte.
// ─────────────────────────────────────────────────────────────────────────────

class _AparenciaSection extends ConsumerWidget {
  const _AparenciaSection();

  static const _opcoes = <(ThemeMode, String)>[
    (ThemeMode.system, 'Sistema'),
    (ThemeMode.light, 'Claro'),
    (ThemeMode.dark, 'Escuro'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = ref.watch(themeModeProvider);

    return Semantics(
      container: true,
      // O rótulo visual "Tema" saiu (era sinônimo do cabeçalho "APARÊNCIA"),
      // mas o TalkBack continua anunciando o nome do grupo por aqui.
      label: 'Tema',
      child: _Card(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp2),
        child: Column(
          children: [
            for (var i = 0; i < _opcoes.length; i++) ...[
              if (i > 0) const _DivisorInterno(),
              _TemaRow(
                label: _opcoes[i].$2,
                selecionado: atual == _opcoes[i].$1,
                onTap: () =>
                    ref.read(themeModeProvider.notifier).set(_opcoes[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TemaRow extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _TemaRow({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentText = context.colorAccentText;
    // Tinte do acento a 10% no escuro / 8% no claro. É preenchimento, mas leva
    // texto de acento por cima, não creme: no escuro compõe #20264C e o
    // cobalt350 sobre ele dá 4.72:1, passa AA.
    final fundoSelecionado = accentText.withAlpha(context.isDark ? 26 : 20);

    return MergeSemantics(
      child: Semantics(
        // Sem isto o TalkBack perde o "1 de 3" que o SegmentedButton dava de
        // graça, e a pessoa não sabe quantas opções existem.
        inMutuallyExclusiveGroup: true,
        selected: selecionado,
        button: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp2),
          child: Material(
            color: selecionado ? fundoSelecionado : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sp2,
                  vertical: AppTheme.sp3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          fontWeight:
                              selecionado ? FontWeight.w500 : FontWeight.w400,
                          color:
                              selecionado ? accentText : context.colorTitle,
                        ),
                      ),
                    ),
                    // Marca de seleção: o estado não pode depender só de cor.
                    if (selecionado)
                      Icon(Icons.check_rounded, size: 20, color: accentText),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notificações
//
// Achado de campo (Ana Lúcia, G1): desligado, o card só dizia "Salmo do dia" ao
// lado de um switch cinza. Não contava o que a notificação faz nem a que horas,
// e tocar no rótulo não fazia nada. Agora a linha descreve o comportamento nos
// dois estados e o card inteiro é o alvo de toque.
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(notificationSettingsProvider);
    final horario = _formatarHora(notif.hour, notif.minute);

    return Semantics(
      container: true,
      label: 'Salmo do dia',
      child: _Card(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            onTap: () => notif.enabled
                ? _pickTime(context, ref, notif.hour, notif.minute)
                : _ligarEEscolherHorario(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.sp4),
              child: Row(
                // start, e não center: com fonte grande a coluna da esquerda
                // vira 2–3 linhas e o switch descolava do texto, flutuando no
                // meio do card.
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: notif.enabled
                        ? _HorarioAtual(horario: horario)
                        : _ItemLabel('Um Salmo por dia, às $horario'),
                  ),
                  const SizedBox(width: AppTheme.sp3),
                  Switch(
                    value: notif.enabled,
                    onChanged: (v) => v
                        ? _ligarEEscolherHorario(context, ref)
                        : _toggleNotification(context, ref, false,
                            notif.hour, notif.minute),
                    activeThumbColor: context.colorAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _ligarEEscolherHorario(
      BuildContext context, WidgetRef ref) async {
    final notif = ref.read(notificationSettingsProvider);
    await _toggleNotification(context, ref, true, notif.hour, notif.minute);
    if (!context.mounted) return;
    if (!ref.read(notificationSettingsProvider).enabled) return;
    await _pickTime(
      context,
      ref,
      ref.read(notificationSettingsProvider).hour,
      ref.read(notificationSettingsProvider).minute,
    );
  }

  Future<void> _toggleNotification(
    BuildContext context,
    WidgetRef ref,
    bool enable,
    int hour,
    int minute,
  ) async {
    if (enable) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return;
      await NotificationService.instance.scheduleDailySalmo(
        hour, minute,
        totalSalmos: _totalSalmos(ref),
      );
    } else {
      await NotificationService.instance.cancelDailySalmo();
    }
    await ref.read(notificationSettingsProvider.notifier).setEnabled(enable);
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      helpText: 'Horário do Salmo do dia',
    );
    if (picked == null) return;
    await ref
        .read(notificationSettingsProvider.notifier)
        .setTime(picked.hour, picked.minute);
    await NotificationService.instance.scheduleDailySalmo(
      picked.hour, picked.minute,
      totalSalmos: _totalSalmos(ref),
    );
  }

  // Fallback 150 só cobre o instante raríssimo em que salmosProvider ainda
  // não carregou quando o usuário liga a notificação.
  int _totalSalmos(WidgetRef ref) =>
      ref.read(salmosProvider).value?.length ?? 150;

  static String _formatarHora(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class _HorarioAtual extends StatelessWidget {
  final String horario;
  const _HorarioAtual({required this.horario});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ItemSupport('Todo dia às'),
        const SizedBox(height: 2),
        // O lápis mora na mesma Row do horário: antes ficava centralizado
        // contra a coluna inteira e flutuava longe da linha que ele edita.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                horario,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: context.colorTitle,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.sp2),
            Icon(Icons.edit_outlined, size: 18, color: context.colorAccentText),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Privacidade
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacidadeSection extends ConsumerWidget {
  const _PrivacidadeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Consentimento de dados de uso (Analytics/Crashlytics) — LGPD.
          // Padrão desligado; ligado só se o usuário confirmar aqui ou
          // no consentimento do onboarding.
          Padding(
            padding: const EdgeInsets.all(AppTheme.sp4),
            child: _ConsentimentoLgpd(
              ligado: ref.watch(usageDataProvider),
              onChanged: (v) => ref.read(usageDataProvider.notifier).set(v),
            ),
          ),
          const _DivisorInterno(),
          // Alvo de toque de 48dp: era 22dp de altura, o pior da tela e
          // justamente o item de maior exigência legal.
          _LinhaAcao(
            label: 'Política de privacidade',
            onTap: _abrirPrivacidade,
          ),
        ],
      ),
    );
  }

  Future<void> _abrirPrivacidade() async {
    final uri = Uri.parse('https://omeusalmo.com.br/privacy_policy.html');
    await LinkService.instance.abrir(uri, externo: true);
  }
}

/// Consentimento de dados de uso (Analytics/Crashlytics) — LGPD.
/// Padrão desligado; ligado só se o usuário confirmar aqui ou no
/// consentimento do onboarding.
class _ConsentimentoLgpd extends StatelessWidget {
  final bool ligado;
  final ValueChanged<bool> onChanged;

  const _ConsentimentoLgpd({required this.ligado, required this.onChanged});

  /// A partir daqui o switch desce para baixo do texto.
  ///
  /// O switch do Material tem largura fixa: ele não cresce com a fonte, mas
  /// continua roubando os mesmos ~60dp. Em 320dp a 2.0x sobravam 175dp para o
  /// rótulo, e só a palavra "Compartilhar" já pedia 190dp — o texto era
  /// cortado no meio. Empilhando, o rótulo recebe a largura inteira do card.
  static const double _escalaQueEmpilha = 1.5;

  @override
  Widget build(BuildContext context) {
    const texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ItemLabel('Compartilhar dados de uso'),
        SizedBox(height: 4),
        // 14px, não 13: é texto de decisão, a pessoa lê isto para escolher
        // se autoriza.
        _ItemBody('Ajuda a melhorar o app (uso e falhas, sem identificar '
            'você). Você pode desligar quando quiser.'),
      ],
    );

    final chave = Switch(
      value: ligado,
      onChanged: onChanged,
      activeThumbColor: context.colorAccent,
    );

    if (MediaQuery.textScalerOf(context).scale(1) >= _escalaQueEmpilha) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          texto,
          const SizedBox(height: AppTheme.sp2),
          chave,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: texto),
        const SizedBox(width: AppTheme.sp3),
        chave,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sobre
// ─────────────────────────────────────────────────────────────────────────────

class _SobreSection extends StatelessWidget {
  const _SobreSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoRow('Versão', AppConstants.appVersion),
          Divider(
              height: AppTheme.sp5, thickness: 0.5, color: context.colorBorder),
          const _InfoRow(
            'Tradução',
            'João Ferreira de Almeida\ned. 1911, domínio público',
          ),
          Divider(
              height: AppTheme.sp5, thickness: 0.5, color: context.colorBorder),
          Text(
            'O meu Salmo',
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: context.colorAccentText,
            ),
          ),
          const SizedBox(height: 2),
          const _ItemSupport('Uma pausa que devolve a você mesmo.'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sugestões
// ─────────────────────────────────────────────────────────────────────────────

class _SugestoesSection extends StatelessWidget {
  const _SugestoesSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: _LinhaAcao(
        label: 'Enviar sugestão',
        apoio: 'Abre o seu e-mail',
        onTap: _enviarSugestao,
      ),
    );
  }

  Future<void> _enviarSugestao() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'omeusalmo@gmail.com',
      queryParameters: {
        'subject': 'Sugestão — O meu Salmo',
        'body': 'Olá,\n\nMinha sugestão:\n\n',
      },
    );
    await LinkService.instance.abrir(uri);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apoie o app
//
// Último da tela e sem peso visual: sem sombra (era o único elemento com
// sombra na tela inteira) e com botão de contorno em vez de bloco sólido de
// largura total. Pedir dinheiro não pode ser o que mais salta aos olhos.
// ─────────────────────────────────────────────────────────────────────────────

class _ApoieSection extends StatelessWidget {
  const _ApoieSection();

  @override
  Widget build(BuildContext context) {
    final accentText = context.colorAccentText;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 26, color: accentText),
          const SizedBox(height: AppTheme.sp2),
          Text(
            'Você usa. Gosta.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: context.colorTitle,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppTheme.sp1 + 2),
          const _ItemBody('Gratuito e sem anúncios. Se faz parte do seu dia, '
              'considere apoiar.'),
          const SizedBox(height: AppTheme.sp4),
          OutlinedButton(
            onPressed: () => _showApoieSheet(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentText,
              side: BorderSide(color: accentText, width: 1),
              shape: const StadiumBorder(),
              minimumSize: const Size(0, _alvoMinimo),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp6),
            ),
            child: Text(
              'Apoiar o app',
              style: GoogleFonts.instrumentSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApoieSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _ApoieSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet do Pix
// ─────────────────────────────────────────────────────────────────────────────

class _ApoieSheet extends StatelessWidget {
  const _ApoieSheet();

  static const _chavePix = 'omeusalmo@gmail.com';

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final text = context.colorText;
    final accentText = context.colorAccentText;
    final border = context.colorBorder;

    // Rola: com fonte em 2.0x o conteúdo passa da altura do sheet.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.sp5, AppTheme.sp6, AppTheme.sp5, AppTheme.sp8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sp6),
            Text(
              'Apoie o app',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: titleClr,
                letterSpacing: -0.42,
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            Text(
              'O meu Salmo é gratuito e sem anúncios. Se ele faz parte do seu '
              'dia, considere apoiar com uma contribuição única.',
              style: AppTheme.bodyRelaxed15(text),
            ),
            const SizedBox(height: AppTheme.sp6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.sp4),
              decoration: BoxDecoration(
                color: context.colorBg,
                border: Border.all(color: border, width: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHAVE PIX',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 13 * 0.18,
                      color: accentText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp2),
                  // Corpo maior: quem apoia digita esta chave no app do banco,
                  // olhando para a tela. Era 14px.
                  SelectableText(
                    _chavePix,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: titleClr,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sp3),
                  const _CopyPixButton(chave: _chavePix),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.sp3),
            const _ItemBody('Abra seu banco, escolha Pix, Pagar, e cole a chave.'),
          ],
        ),
      ),
    );
  }
}

class _CopyPixButton extends StatefulWidget {
  final String chave;
  const _CopyPixButton({required this.chave});

  @override
  State<_CopyPixButton> createState() => _CopyPixButtonState();
}

class _CopyPixButtonState extends State<_CopyPixButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.chave));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final accentText = context.colorAccentText;
    const ok = AppColors.emoPazDot;

    return Semantics(
      label: _copied ? 'Chave Pix copiada' : 'Copiar chave Pix',
      button: true,
      excludeSemantics: true,
      child: Material(
        color: _copied ? ok.withAlpha(30) : accentText.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: InkWell(
          onTap: _copied ? null : _copy,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: _alvoMinimo),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp5),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone, e não o glifo "✓" dentro do texto: como glifo ele
                // entrava na medida da linha e o botão mudava de largura no
                // meio da animação de confirmação.
                if (_copied) ...[
                  const Icon(Icons.check_rounded, size: 18, color: ok),
                  const SizedBox(width: AppTheme.sp1),
                ],
                Text(
                  _copied ? 'Copiado' : 'Copiar',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _copied ? ok : accentText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internos
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: AppTheme.sp1, bottom: AppTheme.sp2),
        child: Semantics(
          // Sem isto o TalkBack soletra a versão em caixa alta.
          label: title,
          excludeSemantics: true,
          header: true,
          child: Text(
            title.toUpperCase(),
            // Variante densa do eyebrow, só desta tela: 12px/0.18em no lugar de
            // 11px/0.34em. O tracking largo do token geral separava demais as
            // letras num rótulo já pequeno.
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 12 * 0.18,
              color: context.colorText,
            ),
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.sp4),
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: context.colorBorder, width: 0.5),
        ),
        child: child,
      );
}

/// Divisor entre itens de um mesmo card. Não é tocável: fica fora do InkWell
/// das linhas, senão come parte do alvo de toque do item de baixo.
class _DivisorInterno extends StatelessWidget {
  const _DivisorInterno();

  @override
  Widget build(BuildContext context) => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: AppTheme.sp4,
        color: context.colorBorder,
      );
}

/// Linha tocável de card: rótulo, apoio opcional e seta. Piso de 48dp.
class _LinhaAcao extends StatelessWidget {
  final String label;
  final String? apoio;
  final VoidCallback onTap;

  const _LinhaAcao({required this.label, this.apoio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: _alvoMinimo),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp4,
                vertical: AppTheme.sp3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ItemLabel(label),
                        if (apoio != null) ...[
                          const SizedBox(height: 2),
                          _ItemSupport(apoio!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.sp3),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: context.colorText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rótulo de item dentro de um card: o nome do que a pessoa está mexendo.
class _ItemLabel extends StatelessWidget {
  final String text;
  const _ItemLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: context.colorTitle,
        ),
      );
}

/// Apoio secundário: complementa o rótulo, não decide nada sozinho.
class _ItemSupport extends StatelessWidget {
  final String text;
  const _ItemSupport(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 13,
          color: context.colorText,
          height: 1.4,
        ),
      );
}

/// Texto que a pessoa precisa ler para decidir (LGPD, instrução do Pix).
/// Piso de 14px, um degrau acima do apoio decorativo.
class _ItemBody extends StatelessWidget {
  final String text;
  const _ItemBody(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          color: context.colorText,
          height: 1.5,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calha do rótulo: reserva 80px de texto para alinhar os valores, mas
          // com teto de 120px. Sem o teto, em 2.0x a calha comia 160 dos 287dp
          // da linha e quebrava o nome da tradução em sete linhas.
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth:
                  math.min(MediaQuery.textScalerOf(context).scale(80), 120),
            ),
            child: Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: context.colorText,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp2),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: context.colorTitle,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
