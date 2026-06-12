import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Entrada com fade + subida e atraso indexado — equivalente ao `.rv dN`
/// da LP V2. Envolva cada bloco de conteúdo e passe o índice de ordem.
///
/// Com MediaQuery.disableAnimations o conteúdo aparece imediatamente.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;
  final Duration duration;
  final double offsetY;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 80),
    this.duration = AppTheme.durSlow,
    this.offsetY = 26,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final CurvedAnimation _anim = CurvedAnimation(
    parent: _ctrl,
    curve: AppTheme.ease,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.value = 1;
      return;
    }
    Future.delayed(widget.step * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _anim.value) * widget.offsetY),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
