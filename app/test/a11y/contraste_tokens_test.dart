import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salmos_app/core/extensions/build_context_extensions.dart';
import 'package:salmos_app/core/theme/app_theme.dart';

/// Contraste dos tokens do DS v1.2, medido no app e não no papel.
///
/// As superfícies mudaram (night-plus, night-line, day-plus, day-line) e o
/// acento virou dois papéis. Isto atinge o app inteiro, então a checagem é dos
/// tokens, não de uma tela: qualquer texto que use estas cores herda o
/// resultado daqui.
void main() {
  group('tema escuro', () {
    testWidgets('texto de conteúdo passa AA sobre fundo e superfície',
        (tester) async {
      final t = await _tokens(tester, ThemeMode.dark);

      _exigeAA(t, 'texto', t.text);
      _exigeAA(t, 'título', t.title);
      _exigeAA(t, 'acento de texto', t.accentText);
      _exigeAA(t, 'versículo', t.verse);
      // muted é rótulo de metadado, nunca corpo — mas o DS v1.2 subiu o valor
      // justamente para ele também passar AA.
      _exigeAA(t, 'muted', t.muted);
    });

    testWidgets('cards e bordas se distinguem do fundo', (tester) async {
      final t = await _tokens(tester, ThemeMode.dark);

      expect(_cr(t.surface, t.bg), greaterThanOrEqualTo(1.14),
          reason: 'Card contra fundo: os cards sumiam a 1.08:1.');
      expect(_cr(t.border, t.surface), greaterThanOrEqualTo(1.55),
          reason: 'Borda contra card: era 1.17:1 e a borda não existia.');
    });
  });

  group('tema claro', () {
    testWidgets('texto de conteúdo passa AA sobre fundo e superfície',
        (tester) async {
      final t = await _tokens(tester, ThemeMode.light);

      _exigeAA(t, 'texto', t.text);
      _exigeAA(t, 'título', t.title);
      _exigeAA(t, 'acento de texto', t.accentText);
      _exigeAA(t, 'versículo', t.verse);
      _exigeAA(t, 'muted', t.muted);
    });

    testWidgets('cards e bordas se distinguem do fundo', (tester) async {
      final t = await _tokens(tester, ThemeMode.light);

      expect(_cr(t.surface, t.bg), greaterThanOrEqualTo(1.14));
      expect(_cr(t.border, t.surface), greaterThanOrEqualTo(1.55));
    });
  });

  group('os dois papéis do acento', () {
    testWidgets('preenchimento sólido carrega o creme com AA', (tester) async {
      for (final modo in [ThemeMode.dark, ThemeMode.light]) {
        final t = await _tokens(tester, modo);
        final razao = _cr(AppColors.nightCream, t.accentFill);

        expect(razao, greaterThanOrEqualTo(4.5),
            reason: 'Creme sobre o preenchimento em $modo dá '
                '${razao.toStringAsFixed(2)}:1.');
      }
    });

    testWidgets('acento de texto seria péssimo como preenchimento',
        (tester) async {
      // Guarda de intenção: é este número (2.72:1) que justifica existirem dois
      // tokens de acento em vez de um. Se ele mudar, a separação precisa ser
      // reavaliada em vez de mantida por inércia.
      final t = await _tokens(tester, ThemeMode.dark);

      expect(_cr(AppColors.nightCream, t.accentText), lessThan(4.5));
      expect(_cr(AppColors.nightCream, t.accentFill), greaterThan(4.5));
    });

    testWidgets('texto de acento passa AA sobre os tintes usados no app',
        (tester) async {
      // O app pinta faixas e chips com o acento em alpha baixo e escreve por
      // cima. Um tinte escurece pouco o fundo, então o texto quase não ganha
      // contraste — foi assim que seis lugares ficaram reprovando AA no escuro.
      // Alphas realmente usados no código ONDE o texto por cima é de acento:
      // chips de tema (18), botão de copiar o Pix (20), botão de revelar a
      // reflexão (22), linha selecionada e grid emocional (26).
      // O indicador da barra de navegação usa 38, mas o rótulo dele é texto de
      // corpo, não de acento — está coberto pelo teste logo abaixo.
      const alphas = [18, 20, 22, 26];

      for (final modo in [ThemeMode.dark, ThemeMode.light]) {
        final t = await _tokens(tester, modo);

        for (final base in [t.bg, t.surface]) {
          for (final alpha in alphas) {
            final tinte = Color.alphaBlend(t.accentText.withAlpha(alpha), base);
            final razao = _cr(t.accentText, tinte);

            expect(razao, greaterThanOrEqualTo(4.5),
                reason: 'Acento de texto sobre tinte de $alpha em $modo dá '
                    '${razao.toStringAsFixed(2)}:1.');
          }
        }
      }
    });

    testWidgets('indicador da barra de navegação carrega o rótulo com AA',
        (tester) async {
      // app_theme.dart pinta o indicador com o acento a 38 e o rótulo herda a
      // cor de corpo (onSurface), não a de acento.
      for (final modo in [ThemeMode.dark, ThemeMode.light]) {
        final t = await _tokens(tester, modo);
        final indicador = Color.alphaBlend(t.accent.withAlpha(38), t.bg);
        final razao = _cr(t.text, indicador);

        expect(razao, greaterThanOrEqualTo(4.5),
            reason: 'Rótulo da aba selecionada em $modo dá '
                '${razao.toStringAsFixed(2)}:1.');
      }
    });

    testWidgets('acento de borda cumpre o mínimo de elemento não textual',
        (tester) async {
      // colorAccent não serve para texto, mas precisa dos 3:1 de elemento
      // gráfico (WCAG 1.4.11) sobre a superfície.
      final t = await _tokens(tester, ThemeMode.dark);

      expect(_cr(t.accent, t.surface), greaterThanOrEqualTo(3.0));
      expect(_cr(t.accent, t.surface), lessThan(4.5),
          reason: 'Se passar de 4.5:1, colorAccent e colorAccentText podem '
              'virar um token só.');
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class _Tokens {
  final Color bg, surface, border, text, title, muted, accent, accentText;
  final Color accentFill, verse;

  const _Tokens({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.title,
    required this.muted,
    required this.accent,
    required this.accentText,
    required this.accentFill,
    required this.verse,
  });
}

/// Lê os tokens pelo mesmo caminho que as telas usam (as extensões de
/// BuildContext), para o teste cobrir também a fiação, não só as constantes.
Future<_Tokens> _tokens(WidgetTester tester, ThemeMode modo) async {
  late _Tokens t;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: modo,
    home: Builder(builder: (context) {
      t = _Tokens(
        bg: context.colorBg,
        surface: context.colorSurface,
        border: context.colorBorder,
        text: context.colorText,
        title: context.colorTitle,
        muted: context.colorMuted,
        accent: context.colorAccent,
        accentText: context.colorAccentText,
        accentFill: context.colorAccentFill,
        verse: context.colorVerse,
      );
      return const SizedBox.shrink();
    }),
  ));
  return t;
}

void _exigeAA(_Tokens t, String nome, Color cor) {
  final sobreFundo = _cr(cor, t.bg);
  final sobreSuperficie = _cr(cor, t.surface);

  expect(sobreFundo, greaterThanOrEqualTo(4.5),
      reason: '$nome sobre o fundo: ${sobreFundo.toStringAsFixed(2)}:1');
  expect(sobreSuperficie, greaterThanOrEqualTo(4.5),
      reason: '$nome sobre o card: ${sobreSuperficie.toStringAsFixed(2)}:1');
}

/// Razão de contraste do WCAG entre duas cores opacas.
double _cr(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
}
