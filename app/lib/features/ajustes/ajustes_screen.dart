import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/settings_provider.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark    = context.isDark;
    final bg        = context.colorBg;
    final titleClr  = context.colorTitle;
    final border    = context.colorBorder;
    final muted     = context.colorText;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Semantics(
          label: 'Voltar',
          button: true,
          child: GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/'),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 0.5),
                ),
                child: Center(
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: muted),
                ),
              ),
            ),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp5,
          vertical: AppTheme.sp4,
        ),
        children: [
          // ── Aparência ─────────────────────────────────────────────────
          _SectionHeader('Aparência', isDark: isDark),
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Tema', isDark: isDark),
                const SizedBox(height: AppTheme.sp3),
                SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: isDark
                        ? AppColors.cobalt400.withAlpha(38)
                        : AppColors.cobalt500.withAlpha(26),
                    selectedForegroundColor:
                        context.colorAccent,
                    foregroundColor:
                        context.colorText,
                    side: BorderSide(color: border, width: 0.5),
                    textStyle: GoogleFonts.instrumentSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                    ButtonSegment(value: ThemeMode.light,  label: Text('Claro')),
                    ButtonSegment(value: ThemeMode.dark,   label: Text('Escuro')),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) =>
                      ref.read(themeModeProvider.notifier).set(modes.first),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.sp5),

          // ── Notificações ──────────────────────────────────────────────
          _SectionHeader('Notificações', isDark: isDark),
          _NotificationCard(isDark: isDark),

          const SizedBox(height: AppTheme.sp5),

          // ── Apoie ─────────────────────────────────────────────────────
          _SectionHeader('Apoie o app', isDark: isDark),
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  size: 26,
                  color: context.colorAccent,
                ),
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
                Text(
                  'Gratuito e sem anúncios. Se o app faz parte do seu dia, considere apoiar com uma contribuição única.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: context.colorText,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: AppTheme.sp4),
                GestureDetector(
                  onTap: () => _showApoieSheet(context, isDark),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.sp3),
                    decoration: BoxDecoration(
                      color: context.colorAccent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cobalt600.withAlpha(77),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Apoiar o app',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.nightCream,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.sp5),

          // ── Sobre ─────────────────────────────────────────────────────
          _SectionHeader('Sobre', isDark: isDark),
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Versão', '1.0.1', isDark: isDark),
                Divider(
                  height: AppTheme.sp5,
                  thickness: 0.5,
                  color: context.colorBorder,
                ),
                _InfoRow(
                  'Tradução',
                  'João Ferreira de Almeida\ned. 1911 — domínio público',
                  isDark: isDark,
                ),
                Divider(
                  height: AppTheme.sp5,
                  thickness: 0.5,
                  color: context.colorBorder,
                ),
                Text(
                  'O meu Salmo',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: context.colorAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Uma pausa que devolve a você mesmo.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: context.colorText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.sp5),

          // ── Sugestões ─────────────────────────────────────────────────
          _SectionHeader('Sugestões', isDark: isDark),
          _Card(
            isDark: isDark,
            child: GestureDetector(
              onTap: () => _enviarSugestao(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enviar sugestão',
                          style: AppTheme.caption14(context.colorText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Abre o seu e-mail',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 12,
                            color: context.colorText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: context.colorText,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.sp5),

          // ── Privacidade ───────────────────────────────────────────────
          _SectionHeader('Privacidade', isDark: isDark),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                // Consentimento de dados de uso (Analytics/Crashlytics) — LGPD.
                // Padrão desligado; ligado só se o usuário confirmar aqui ou
                // no consentimento do onboarding.
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Compartilhar dados de uso', isDark: isDark),
                          const SizedBox(height: 2),
                          Text(
                            'Ajuda a melhorar o app (uso e falhas, sem identificar você). Você pode desligar quando quiser.',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 12,
                              color: muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp3),
                    Switch(
                      value: ref.watch(usageDataProvider),
                      onChanged: (v) =>
                          ref.read(usageDataProvider.notifier).set(v),
                      activeThumbColor:
                          context.colorAccent,
                    ),
                  ],
                ),
                Divider(height: AppTheme.sp5, thickness: 0.5, color: border),
                GestureDetector(
                  onTap: () => _abrirPrivacidade(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Política de privacidade',
                          style: AppTheme.caption14(context.colorText),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: context.colorText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.sp10),
        ],
      ),
    );
  }

  Future<void> _abrirPrivacidade() async {
    final uri = Uri.parse(
      'https://omeusalmo.com.br/privacy_policy.html',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showApoieSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _ApoieSheet(isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de Notificações
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends ConsumerWidget {
  final bool isDark;
  const _NotificationCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif  = ref.watch(notificationSettingsProvider);
    final accent = context.colorAccent;

    final timeLabel = '${notif.hour.toString().padLeft(2, '0')}:'
        '${notif.minute.toString().padLeft(2, '0')}';

    return _Card(
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Salmo diário', isDark: isDark),
                if (notif.enabled) ...[
                  const SizedBox(height: AppTheme.sp2),
                  GestureDetector(
                    onTap: () => _pickTime(context, ref, notif.hour, notif.minute),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TODO DIA ÀS',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: context.colorText,
                                letterSpacing: 10 * 0.034,
                              ),
                            ),
                            Text(
                              timeLabel,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: context.colorTitle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppTheme.sp2),
                        Icon(Icons.edit_outlined, size: 14, color: accent),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: notif.enabled,
            onChanged: (v) async {
              await _toggleNotification(context, ref, v, notif.hour, notif.minute);
              if (!context.mounted) return;
              if (v && ref.read(notificationSettingsProvider).enabled) {
                await _pickTime(
                  context,
                  ref,
                  ref.read(notificationSettingsProvider).hour,
                  ref.read(notificationSettingsProvider).minute,
                );
              }
            },
            activeThumbColor: accent,
          ),
        ],
      ),
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
      await NotificationService.instance.scheduleDailySalmo(hour, minute);
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
      helpText: 'Horário do Salmo diário',
    );
    if (picked == null) return;
    await ref.read(notificationSettingsProvider.notifier).setTime(picked.hour, picked.minute);
    await NotificationService.instance.scheduleDailySalmo(picked.hour, picked.minute);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ApoieSheet extends StatelessWidget {
  final bool isDark;
  const _ApoieSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleClr = context.colorTitle;
    final text     = context.colorText;
    final accent   = context.colorAccent;
    final border   = context.colorBorder;

    return Padding(
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
            'O meu Salmo é gratuito e sem anúncios. Se ele faz parte do seu dia, considere apoiar com uma contribuição única.',
            style: AppTheme.bodyRelaxed15(text),
          ),
          const SizedBox(height: AppTheme.sp6),
          // Chave Pix
          Container(
            padding: const EdgeInsets.all(AppTheme.sp4),
            decoration: BoxDecoration(
              color: context.colorBg,
              border: Border.all(color: border, width: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHAVE PIX',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 3.0,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'omeusalmo@gmail.com',
                        style: AppTheme.emphasis14(titleClr),
                      ),
                    ],
                  ),
                ),
                _CopyPixButton(isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp3),
          Text(
            'Abra seu banco → Pix → Pagar → Cole a chave.',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              color: context.colorText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botão copiar chave Pix
// ─────────────────────────────────────────────────────────────────────────────

class _CopyPixButton extends StatefulWidget {
  final bool isDark;
  const _CopyPixButton({required this.isDark});

  @override
  State<_CopyPixButton> createState() => _CopyPixButtonState();
}

class _CopyPixButtonState extends State<_CopyPixButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(const ClipboardData(text: 'omeusalmo@gmail.com'));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colorAccent;
    return GestureDetector(
      onTap: _copied ? null : _copy,
      child: AnimatedContainer(
        duration: AppTheme.durFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp3,
          vertical: AppTheme.sp2,
        ),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.emoPazDot.withAlpha(30)
              : accent.withAlpha(20),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Text(
          _copied ? 'Copiado ✓' : 'Copiar',
          style: GoogleFonts.instrumentSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _copied ? AppColors.emoPazDot : accent,
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
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: AppTheme.sp1, bottom: AppTheme.sp2),
        child: Text(
          title.toUpperCase(),
          style: AppTheme.eyebrowLabel(context.colorText),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.sp4),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: context.colorBorder,
            width: 0.5,
          ),
        ),
        child: child,
      );
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: context.colorText,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow(this.label, this.value, {required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: context.colorText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: context.colorText,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
