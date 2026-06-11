import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.wb_sunny_outlined),
      selectedIcon: Icon(Icons.wb_sunny),
      label: 'Início',
    ),
    NavigationDestination(
      icon: Icon(Icons.collections_bookmark_outlined),
      selectedIcon: Icon(Icons.collections_bookmark),
      label: 'Coleções',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Salmos',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite),
      label: 'Favoritos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg     = context.colorBg;
    final border = context.colorBorder;

    return Scaffold(
      backgroundColor: bg,
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 0.5, thickness: 0.5, color: border),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: _destinations,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            animationDuration: AppTheme.dur,
          ),
        ],
      ),
    );
  }
}
