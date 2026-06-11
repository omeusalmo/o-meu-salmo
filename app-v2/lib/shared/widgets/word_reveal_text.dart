import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Texto revelado palavra a palavra — o versículo "acende" em sequência,
/// como na LP V2. Um único AnimationController; cada palavra ocupa um
/// Interval escalonado da timeline.
///
/// O TalkBack lê o texto completo de uma vez (Semantics).
/// Com MediaQuery.disableAnimations o texto aparece pleno imediatamente.
class WordRevealText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final Duration wordStep;
  final Duration wordFade;

  const WordRevealText({
    super.key,
    required this.text,
    required this.style,
    this.delay = Duration.zero,
    this.wordStep = const Duration(milliseconds: 70),
    this.wordFade = const Duration(milliseconds: 450),
  });

  @override
  State<WordRevealText> createState() => _WordRevealTextState();
}

class _WordRevealTextState extends State<WordRevealText>
    with SingleTickerProviderStateMixin {
  late final List<String> _words =
      widget.text.split(' ').where((w) => w.isNotEmpty).toList();

  late final Duration _total = widget.delay +
      widget.wordStep * (_words.length - 1).clamp(0, 1 << 30) +
      widget.wordFade;

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: _total,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.of(context).disableAnimations || _words.isEmpty) {
      _ctrl.value = 1;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Progresso 0..1 da palavra [i] dentro da timeline total.
  double _wordProgress(int i) {
    final startMs =
        widget.delay.inMilliseconds + widget.wordStep.inMilliseconds * i;
    final start = startMs / _total.inMilliseconds;
    final end =
        (startMs + widget.wordFade.inMilliseconds) / _total.inMilliseconds;
    final v = _ctrl.value;
    if (v <= start) return 0;
    if (v >= end) return 1;
    return AppTheme.ease.transform((v - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.style.color ?? Colors.white;

    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < _words.length; i++)
                TextSpan(
                  text: i == _words.length - 1 ? _words[i] : '${_words[i]} ',
                  style: widget.style.copyWith(
                    color: baseColor.withAlpha(
                      (255 * _wordProgress(i)).round().clamp(0, 255),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
