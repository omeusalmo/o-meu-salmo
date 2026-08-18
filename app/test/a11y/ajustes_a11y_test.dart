import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/extensions/build_context_extensions.dart';
import 'package:salmos_app/core/theme/app_theme.dart';
import 'package:salmos_app/features/ajustes/ajustes_screen.dart';

import 'text_scale_harness.dart';

/// Regressões da revisão de Ajustes (S1 a S15).
///
/// Três contratos que a tela tinha quebrado em produção e não podem voltar:
/// alvo de toque grande o bastante, rótulo de tema que não corta em nenhuma
/// escala, e acento com contraste que passa AA no tema escuro.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefNotificationEnabled: true,
      AppConstants.prefNotificationHour: 7,
      AppConstants.prefNotificationMinute: 0,
      AppConstants.prefUsageDataEnabled: true,
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // S1 — o rótulo do seletor de tema
  // ───────────────────────────────────────────────────────────────────────────

  group('seletor de tema', () {
    testWidgets('"Sistema" não corta em nenhuma escala', (tester) async {
      // O SegmentedButton antigo dava ao segmento selecionado ~1/3 do card
      // menos o espaço do check, e "Sistema" já não cabia em 1.0x.
      for (final escala in kEscalas) {
        final r = await renderizar(
          tester,
          const AjustesScreen(),
          nome: 'Ajustes tema',
          escala: escala,
        );

        final cortados = r.achados
            .where((a) => a.chave.endsWith(':Sistema') ||
                a.chave.endsWith(':Escuro') ||
                a.chave.endsWith(':Claro'))
            .toList();

        expect(cortados, isEmpty,
            reason: 'Em ${escala}x um rótulo de tema foi cortado: $cortados');
      }
    });

    testWidgets('as três opções existem e a selecionada tem marca própria',
        (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes tema',
        escala: 1.0,
      );

      for (final label in ['Sistema', 'Claro', 'Escuro']) {
        expect(find.text(label), findsOneWidget);
      }

      // O estado selecionado não pode depender só de cor: precisa do check.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('cada opção se anuncia como escolha exclusiva no TalkBack',
        (tester) async {
      final handle = tester.ensureSemantics();
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes tema',
        escala: 1.0,
      );

      for (final label in ['Sistema', 'Claro', 'Escuro']) {
        expect(
          tester.getSemantics(find.text(label)),
          matchesSemantics(
            label: label,
            isButton: true,
            hasTapAction: true,
            hasSelectedState: true,
            isSelected: label == 'Sistema',
            isInMutuallyExclusiveGroup: true,
            isFocusable: true,
            hasFocusAction: true,
          ),
          reason: 'A opção "$label" perdeu o papel de escolha exclusiva; '
              'sem ele o TalkBack não anuncia "1 de 3".',
        );
      }
      handle.dispose();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // S2 e S6 — alvos de toque
  // ───────────────────────────────────────────────────────────────────────────

  group('alvos de toque', () {
    // Viewport alto de propósito: a tela toda cabe sem rolar, então dá para
    // medir todos os alvos numa passada só. O objetivo aqui é o tamanho do
    // alvo, não o comportamento de rolagem.
    const telaInteira = Size(360, 2400);

    testWidgets('linhas e botões da tela têm pelo menos 48dp de altura',
        (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes alvos',
        escala: 1.0,
        tamanho: telaInteira,
      );

      // 'Política de privacidade' tinha 22dp e era o pior da tela.
      for (final rotulo in [
        'Sistema',
        'Claro',
        'Escuro',
        'Enviar sugestão',
        'Política de privacidade',
        'Apoiar o app',
      ]) {
        final altura = _alturaDoAlvo(tester, rotulo);
        expect(altura, greaterThanOrEqualTo(48.0),
            reason: '"$rotulo" tem alvo de toque de ${altura}dp.');
      }
    });

    testWidgets('botão voltar tem 44dp', (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes voltar',
        escala: 1.0,
      );

      final tamanho = tester.getSize(
        find.ancestor(
          of: find.byIcon(Icons.arrow_back_ios_new_rounded),
          matching: find.byType(Container),
        ).first,
      );
      expect(tamanho.height, greaterThanOrEqualTo(44.0));
      expect(tamanho.width, greaterThanOrEqualTo(44.0));
    });

    testWidgets('botão Copiar do Pix tem 48dp', (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes Pix',
        escala: 1.0,
        tamanho: telaInteira,
        depoisDeRenderizar: (t) async {
          await t.tap(find.text('Apoiar o app'));
          await t.pump();
          await t.pump(const Duration(milliseconds: 400));
        },
      );

      expect(find.text('Copiar'), findsOneWidget);
      expect(_alturaDoAlvo(tester, 'Copiar'), greaterThanOrEqualTo(48.0));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // S3 — contraste do acento
  // ───────────────────────────────────────────────────────────────────────────

  group('contraste do acento', () {
    testWidgets('texto de acento passa AA sobre a superfície nos dois temas',
        (tester) async {
      for (final modo in [ThemeMode.dark, ThemeMode.light]) {
        late Color acentoTexto;
        late Color superficie;
        late Color fundo;

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modo,
          home: Builder(builder: (context) {
            acentoTexto = context.colorAccentText;
            superficie = context.colorSurface;
            fundo = context.colorBg;
            return const SizedBox.shrink();
          }),
        ));

        final sobreSuperficie = _contraste(acentoTexto, superficie);
        final sobreFundo = _contraste(acentoTexto, fundo);

        expect(sobreSuperficie, greaterThanOrEqualTo(4.5),
            reason: 'Acento de texto em $modo dá '
                '${sobreSuperficie.toStringAsFixed(2)}:1 sobre a superfície. '
                'AA pede 4.5:1.');
        expect(sobreFundo, greaterThanOrEqualTo(4.5),
            reason: 'Acento de texto em $modo dá '
                '${sobreFundo.toStringAsFixed(2)}:1 sobre o fundo.');
      }
    });

    testWidgets('o acento de preenchimento continua reprovando para texto',
        (tester) async {
      // Guarda de intenção: se algum dia cobalt400 passar a 4.5:1, a separação
      // entre acento de preenchimento e acento de texto deixa de fazer sentido
      // e este teste avisa para simplificar em vez de manter dois tokens.
      late Color preenchimento;
      late Color superficie;

      await tester.pumpWidget(MaterialApp(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Builder(builder: (context) {
          preenchimento = context.colorAccent;
          superficie = context.colorSurface;
          return const SizedBox.shrink();
        }),
      ));

      expect(_contraste(preenchimento, superficie), lessThan(4.5));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // S4 — o card de notificação precisa dizer o que faz
  // ───────────────────────────────────────────────────────────────────────────

  group('card de notificação', () {
    testWidgets('desligado, informa o que a notificação faz e a que horas',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefNotificationEnabled: false,
        AppConstants.prefNotificationHour: 7,
        AppConstants.prefNotificationMinute: 0,
      });

      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes notificação desligada',
        escala: 1.0,
      );

      // O achado de campo: o card mudo não dizia nem o que era nem o horário.
      expect(find.text('Um Salmo por dia, às 07:00'), findsOneWidget);
    });

    testWidgets('ligado, mostra o horário escolhido', (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes notificação ligada',
        escala: 1.0,
      );

      expect(find.text('Todo dia às'), findsOneWidget);
      expect(find.text('07:00'), findsOneWidget);
    });

    testWidgets('o card inteiro é tocável, não só o switch', (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes notificação tocável',
        escala: 1.0,
      );

      final linha = find.ancestor(
        of: find.text('Todo dia às'),
        matching: find.byType(InkWell),
      );
      expect(linha, findsWidgets,
          reason: 'A área do horário deixou de ser tocável.');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // S12 — piso de tamanho de fonte
  // ───────────────────────────────────────────────────────────────────────────

  group('piso de tamanho de fonte', () {
    /// Cabeçalhos de seção: única exceção ao piso, em 12px por decisão de
    /// design (eyebrow denso). São rótulos de navegação em caixa alta, não
    /// conteúdo que a pessoa lê para decidir.
    const cabecalhos = {
      'APARÊNCIA',
      'NOTIFICAÇÕES',
      'PRIVACIDADE',
      'SOBRE',
      'SUGESTÕES',
      'APOIE O APP',
    };

    testWidgets('nenhum texto de conteúdo fica abaixo de 13px',
        (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes piso de fonte',
        escala: 1.0,
        tamanho: const Size(360, 2400),
      );

      final pequenos = <String>[];
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        if (cabecalhos.contains(t.data)) continue;
        final tamanho = t.style?.fontSize;
        if (tamanho != null && tamanho < 13) {
          pequenos.add('"${t.data}" com ${tamanho}px');
        }
      }

      expect(pequenos, isEmpty,
          reason: 'Texto abaixo do piso de 13px: $pequenos. O público tem '
              '60 a 75 anos; 10 e 12px não entram nesta tela.');
    });

    testWidgets('o eyebrow de seção é o denso de 12px', (tester) async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'Ajustes eyebrow',
        escala: 1.0,
        tamanho: const Size(360, 2400),
      );

      final estilo =
          tester.widget<Text>(find.text('APARÊNCIA')).style!;
      expect(estilo.fontSize, 12.0);
      // 0.18em: o token geral usa 0.34em, que separava demais as letras.
      expect(estilo.letterSpacing, closeTo(12 * 0.18, 0.01));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────

/// Altura do alvo tocável que contém [rotulo].
double _alturaDoAlvo(WidgetTester tester, String rotulo) {
  final alvo = find
      .ancestor(of: find.text(rotulo), matching: find.byType(InkWell))
      .first;
  return tester.getSize(alvo).height;
}

/// Razão de contraste do WCAG entre duas cores opacas.
double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final claro = la > lb ? la : lb;
  final escuro = la > lb ? lb : la;
  return (claro + 0.05) / (escuro + 0.05);
}
