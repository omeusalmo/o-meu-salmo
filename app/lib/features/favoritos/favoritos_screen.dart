import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/favoritos_provider.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/psalm_card.dart';

enum _FavSortOrder { byNumber, byRecent }

class FavoritosScreen extends ConsumerStatefulWidget {
  const FavoritosScreen({super.key});

  @override
  ConsumerState<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends ConsumerState<FavoritosScreen> {
  _FavSortOrder _sortOrder = _FavSortOrder.byNumber;

  @override
  Widget build(BuildContext context) {
    final favoritosAsync  = ref.watch(favoritosProvider);
    final salmosAsync     = ref.watch(salmosProvider);
    final timestampsAsync = ref.watch(favTimestampsProvider);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.nightBase  : AppColors.dayBase;
    final titleClr  = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border    = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted     = isDark ? AppColors.nightText  : AppColors.dayText;
    final accent    = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

    Widget body;

    if (favoritosAsync.isLoading || salmosAsync.isLoading) {
      body = Center(
        child: CircularProgressIndicator(
          color: accent,
          strokeWidth: 1.5,
        ),
      );
    } else if (favoritosAsync.hasError || salmosAsync.hasError) {
      body = Center(
        child: Text(
          'Não consegui carregar seus favoritos.',
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            color: muted,
          ),
        ),
      );
    } else {
      final numeros    = favoritosAsync.value ?? {};
      final todos      = salmosAsync.value ?? [];
      final timestamps = timestampsAsync.value ?? {};

      if (numeros.isEmpty) {
        body = _EmptyState(isDark: isDark);
      } else {
        final favoritos = todos.where((s) => numeros.contains(s.numero)).toList();
        if (_sortOrder == _FavSortOrder.byRecent) {
          favoritos.sort((a, b) {
            final ta = timestamps[a.numero] ?? 0;
            final tb = timestamps[b.numero] ?? 0;
            return tb.compareTo(ta); // mais recente primeiro
          });
        } else {
          favoritos.sort((a, b) => a.numero.compareTo(b.numero));
        }
        body = _FavoritosList(salmos: favoritos);
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<_FavSortOrder>(
            icon: Icon(Icons.sort_rounded, size: 20, color: muted),
            color: isDark ? AppColors.nightBase : AppColors.dayBase,
            elevation: 4,
            onSelected: (v) => setState(() => _sortOrder = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _FavSortOrder.byNumber,
                child: Row(
                  children: [
                    if (_sortOrder == _FavSortOrder.byNumber)
                      Icon(Icons.check, size: 14, color: accent)
                    else
                      const SizedBox(width: 14),
                    const SizedBox(width: 8),
                    Text(
                      'Por número',
                      style: GoogleFonts.instrumentSans(fontSize: 14, color: titleClr),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _FavSortOrder.byRecent,
                child: Row(
                  children: [
                    if (_sortOrder == _FavSortOrder.byRecent)
                      Icon(Icons.check, size: 14, color: accent)
                    else
                      const SizedBox(width: 14),
                    const SizedBox(width: 8),
                    Text(
                      'Mais recentes',
                      style: GoogleFonts.instrumentSans(fontSize: 14, color: titleClr),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Semantics(
            label: 'Configurações',
            button: true,
            child: GestureDetector(
              onTap: () => context.push('/ajustes'),
              child: Padding(
                padding: const EdgeInsets.only(right: AppTheme.sp4),
                child: Icon(Icons.settings_outlined, size: 20, color: muted),
              ),
            ),
          ),
        ],
        title: Text(
          'Favoritos',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
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
      body: body,
    );
  }
}

class _FavoritosList extends StatelessWidget {
  final List<Salmo> salmos;
  const _FavoritosList({required this.salmos});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp5,
        vertical: AppTheme.sp4,
      ),
      itemCount: salmos.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.sp3),
      itemBuilder: (_, i) {
        final s = salmos[i];
        return PsalmCard(
          numero: s.numero,
          titulo: s.titulo,
          snippet: s.versiculos.isNotEmpty ? s.versiculos.first : '',
          onTap: () => context.push('/salmos/${s.numero}'),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? AppColors.nightText : AppColors.dayText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 40,
              color: text,
            ),
            const SizedBox(height: AppTheme.sp4),
            Text(
              'Nenhum Salmo guardado ainda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 15,
                color: text,
              ),
            ),
            const SizedBox(height: AppTheme.sp2),
            Text(
              'Toque no coração ao ler um Salmo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: text,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
