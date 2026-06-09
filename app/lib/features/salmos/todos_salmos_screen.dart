import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/psalm_card.dart';

class TodosSalmosScreen extends ConsumerStatefulWidget {
  const TodosSalmosScreen({super.key});

  @override
  ConsumerState<TodosSalmosScreen> createState() => _TodosSalmosScreenState();
}

class _TodosSalmosScreenState extends ConsumerState<TodosSalmosScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtra por número exato, título ou trecho de versículo.
  // Com 150 salmos em memória, a operação é instantânea.
  List<Salmo> _filter(List<Salmo> salmos) {
    if (_query.isEmpty) return salmos;
    final q = _query.toLowerCase().trim();
    final result = salmos.where((s) {
      if (s.numero.toString() == q) return true;
      if (s.titulo.toLowerCase().contains(q)) return true;
      return s.versiculos.any((v) => v.toLowerCase().contains(q));
    }).toList();
    AnalyticsService.instance.logSearch(q, result.isNotEmpty);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final asyncSalmos = ref.watch(salmosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.nightBase : AppColors.dayBase;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border = isDark ? AppColors.nightLine : AppColors.dayLine;
    final muted  = isDark ? AppColors.nightText  : AppColors.dayText;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () => context.push('/ajustes'),
            child: Padding(
              padding: const EdgeInsets.only(right: AppTheme.sp4),
              child: Icon(Icons.settings_outlined, size: 20, color: muted),
            ),
          ),
        ],
        title: Text(
          'Todos os Salmos',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: titleClr,
            letterSpacing: -0.42,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: border),
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (q) => setState(() => _query = q),
          ),
          Expanded(
            child: asyncSalmos.when(
              loading: () => const _LoadingState(),
              error: (_, __) => const _ErrorState(),
              data: (salmos) {
                final filtered = _filter(salmos);
                if (filtered.isEmpty) return _EmptyState(query: _query);
                return _SalmosList(
                  salmos: filtered,
                  onTap: (n) => context.push('/salmos/$n'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Barra de busca
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.nightPlus  : AppColors.dayPlus;
    final border  = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final textClr = isDark ? AppColors.nightText  : AppColors.dayText;
    final muted   = isDark ? AppColors.nightText  : AppColors.dayText;
    final accent  = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.sp5, AppTheme.sp4, AppTheme.sp5, AppTheme.sp3,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp4,
          vertical: AppTheme.sp2 + 2,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: muted),
            const SizedBox(width: AppTheme.sp2 + 2),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: GoogleFonts.instrumentSans(
                  fontSize: 15,
                  color: textClr,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar um salmo…',
                  hintStyle: GoogleFonts.instrumentSans(
                    fontSize: 15,
                    color: isDark ? AppColors.nightText : AppColors.dayText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                cursorColor: accent,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
              ),
            ),
            // ValueListenableBuilder garante rebuild quando o texto muda
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => value.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.clear();
                        onChanged('');
                      },
                      child: Icon(Icons.close_rounded, size: 16, color: muted),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista
// ─────────────────────────────────────────────────────────────────────────────

class _SalmosList extends StatelessWidget {
  final List<Salmo> salmos;
  final ValueChanged<int> onTap;

  const _SalmosList({
    super.key,
    required this.salmos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp5,
        vertical: AppTheme.sp3,
      ),
      itemCount: salmos.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sp3),
      itemBuilder: (_, i) {
        final s = salmos[i];
        return PsalmCard(
          numero: s.numero,
          titulo: s.titulo,
          snippet: s.versiculos.isNotEmpty ? s.versiculos.first : '',
          onTap: () => onTap(s.numero),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estados
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppColors.cobalt400
        : AppColors.cobalt500;
    return Center(
      child: CircularProgressIndicator(color: accent, strokeWidth: 1.5),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        'Não consegui carregar os Salmos.\nTente novamente.',
        textAlign: TextAlign.center,
        style: GoogleFonts.instrumentSans(
          fontSize: 15,
          color: isDark ? AppColors.nightText : AppColors.dayText,
          height: 1.6,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text  = isDark ? AppColors.nightText  : AppColors.dayText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Não encontrei nada assim.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 15,
                color: text,
              ),
            ),
            const SizedBox(height: AppTheme.sp2),
            Text(
              'Tente uma emoção?',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.nightText : AppColors.dayText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
