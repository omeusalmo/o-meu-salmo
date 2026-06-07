import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/notifications/notification_service.dart';
import '../../data/providers/settings_provider.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.nightBase  : AppColors.dayBase;
    final titleClr  = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border    = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted     = isDark ? AppColors.nightText  : AppColors.dayText;

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
                        isDark ? AppColors.cobalt400 : AppColors.cobalt500,
                    foregroundColor:
                        isDark ? AppColors.nightText  : AppColors.dayText,
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
                Text(
                  'Você usa. Gosta.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.nightCream : AppColors.dayTitle,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppTheme.sp1 + 2),
                Text(
                  'Gratuito e sem anúncios. Se o app faz parte do seu dia, considere apoiar com uma contribuição única.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: isDark ? AppColors.nightText : AppColors.dayText,
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
                      color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
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
                _InfoRow('Versão', '1.0.0', isDark: isDark),
                Divider(
                  height: AppTheme.sp5,
                  thickness: 0.5,
                  color: isDark ? AppColors.nightLine : AppColors.dayLine,
                ),
                _InfoRow(
                  'Tradução',
                  'João Ferreira de Almeida\ned. 1911 — domínio público',
                  isDark: isDark,
                ),
                Divider(
                  height: AppTheme.sp5,
                  thickness: 0.5,
                  color: isDark ? AppColors.nightLine : AppColors.dayLine,
                ),
                Text(
                  'O meu Salmo',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Uma pausa que devolve a você mesmo.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: isDark ? AppColors.nightText  : AppColors.dayText,
                    height: 1.5,
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

  void _showApoieSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.nightPlus : AppColors.dayPlus,
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
  const _NotificationCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif  = ref.watch(notificationSettingsProvider);
    final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
    final muted  = isDark ? AppColors.nightText  : AppColors.dayText;

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
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: notif.enabled
                      ? () => _pickTime(context, ref, notif.hour, notif.minute)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notif.enabled ? 'Todo dia às $timeLabel' : 'Desativado',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 12,
                          color: notif.enabled ? accent : muted,
                        ),
                      ),
                      if (notif.enabled) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 12, color: accent),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: notif.enabled,
            onChanged: (v) => _toggleNotification(context, ref, v, notif.hour, notif.minute),
            activeColor: accent,
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
  const _ApoieSheet({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final text     = isDark ? AppColors.nightText  : AppColors.dayText;
    final muted    = isDark ? AppColors.nightText  : AppColors.dayText;
    final accent   = isDark ? AppColors.cobalt400  : AppColors.cobalt500;
    final border   = isDark ? AppColors.nightLine  : AppColors.dayLine;

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
            style: GoogleFonts.instrumentSans(
              fontSize: 15,
              color: text,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppTheme.sp6),
          // Chave Pix
          Container(
            padding: const EdgeInsets.all(AppTheme.sp4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.nightBase : AppColors.dayBase,
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
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleClr,
                        ),
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
              color: isDark ? AppColors.nightText : AppColors.dayText,
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
  const _CopyPixButton({super.key, required this.isDark});

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
    final accent = widget.isDark ? AppColors.cobalt400 : AppColors.cobalt500;
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
  const _SectionHeader(this.title, {super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: AppTheme.sp1, bottom: AppTheme.sp2),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.instrumentSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.nightText  : AppColors.dayText,
            letterSpacing: 3.74,
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightPlus : AppColors.dayPlus,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.nightLine : AppColors.dayLine,
            width: 0.5,
          ),
        ),
        child: child,
      );
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, {super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.instrumentSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.nightText : AppColors.dayText,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow(this.label, this.value, {super.key, required this.isDark});

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
                color: isDark ? AppColors.nightText  : AppColors.dayText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.instrumentSans(
                fontSize: 13,
                color: isDark ? AppColors.nightText : AppColors.dayText,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
