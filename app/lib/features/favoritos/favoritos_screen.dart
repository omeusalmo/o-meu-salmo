import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/salmo.dart';
import '../../data/providers/favoritos_provider.dart';
import '../../data/providers/salmos_providers.dart';
import '../../shared/widgets/psalm_card.dart';

class FavoritosScreen extends ConsumerWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritosAsync = ref.watch(favoritosProvider);
    final salmosAsync    = ref.watch(salmosProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.nightBase  : AppColors.dayBase;
    final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
    final border   = isDark ? AppColors.nightLine  : AppColors.dayLine;
    final muted    = isDark ? AppColors.nightText  : AppColors.dayText;

    Widget body;

    if (favoritosAsync.isLoading || salmosAsync.isLoading) {
      body = Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.cobalt400 : AppColors.cobalt500,
          strokeWidth: 1.5,
        ),
      );
    } else if (favoritosAsync.hasError || salmosAsync.hasError) {
      body = Center(
        child: Text(
          'Não consegui carregar seus favoritos.',
          style: GoogleFonts.instrumentSans(
            fontSize: 15,
            color: isDark ? AppColors.nightText : AppColors.dayText,
          ),
        ),
      );
    } else {
      final numeros = favoritosAsync.value ?? {};
      final todos   = salmosAsync.value ?? [];

      if (numeros.isEmpty) {
        body = _EmptyState(isDark: isDark);
      } else {
        final favoritos = todos.where((s) => numeros.contains(s.numero)).toList()
          ..sort((a, b) => a.numero.compareTo(b.numero));
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
  const _FavoritosList({super.key, required this.salmos});

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
  const _EmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text  = isDark ? AppColors.nightText  : AppColors.dayText;
    final muted = isDark ? AppColors.nightText  : AppColors.dayText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 40,
              color: isDark ? AppColors.nightText : AppColors.dayText,
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
                color: isDark ? AppColors.nightText : AppColors.dayText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
