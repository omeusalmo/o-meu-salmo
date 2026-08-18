import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/features/ajustes/ajustes_screen.dart';

import 'text_scale_harness.dart';

/// Renderiza Ajustes nos dois temas e nas escalas 1.0 e 2.0, e COMPARA com os
/// PNG versionados em test/a11y/goldens/.
///
/// Regravar depois de mudança visual proposital:
///
///     flutter test --update-goldens test/a11y/ajustes_render_test.dart
///
/// A comparação passou a funcionar quando as fontes viraram assets do app: até
/// então o google_fonts lançava de forma assíncrona por não achar as famílias,
/// o erro caía fora do corpo do teste e derrubava justamente a comparação de
/// imagem, que é E/S longa. Hoje as fontes resolvem local e o portão é real.
///
/// O viewport é alto o bastante para a tela inteira caber numa imagem só: a
/// imagem também serve para ser lida por gente, não só comparada.
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

  for (final (modo, nomeModo) in [
    (ThemeMode.dark, 'escuro'),
    (ThemeMode.light, 'claro'),
  ]) {
    for (final escala in [1.0, 2.0]) {
      final rotuloEscala = escala == 1.0 ? '1x' : '2x';

      testWidgets('Ajustes $nomeModo $rotuloEscala', (tester) async {
        await _semRuidoDeFonte(() async {
          await renderizar(
            tester,
            const AjustesScreen(),
            nome: 'render $nomeModo $rotuloEscala',
            escala: escala,
            modo: modo,
            // Alto o suficiente para a tela toda caber sem rolar.
            tamanho: Size(360, escala == 1.0 ? 1500 : 2600),
          );

          await expectLater(
            find.byType(AjustesScreen),
            matchesGoldenFile('goldens/ajustes_${nomeModo}_$rotuloEscala.png'),
          );
        });
      });
    }
  }

  testWidgets('Sheet do Pix escuro 1x', (tester) async {
    await _semRuidoDeFonte(() async {
      await renderizar(
        tester,
        const AjustesScreen(),
        nome: 'render sheet pix',
        escala: 1.0,
        modo: ThemeMode.dark,
        tamanho: const Size(360, 1500),
        depoisDeRenderizar: (t) async {
          await t.tap(find.text('Apoiar o app'));
          await t.pump();
          await t.pump(const Duration(milliseconds: 400));
        },
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ajustes_sheet_pix_escuro.png'),
      );
    });
  });
}

/// Silencia UM erro específico do google_fonts durante o render.
///
/// Agora que as fontes vêm dos assets, este filtro quase nunca dispara. Ele
/// segue aqui só para a mensagem de família não encontrada, e nada além dela:
/// a versão anterior engolia qualquer erro que contivesse "google_fonts", o
/// que passou a ser perigoso — esconderia justamente a falha que queremos ver
/// se alguém quebrar o empacotamento das fontes.
Future<void> _semRuidoDeFonte(Future<void> Function() corpo) async {
  final anterior = FlutterError.onError;
  FlutterError.onError = (detalhes) {
    final texto = detalhes.exception.toString();
    final ehFamiliaNaoEncontrada =
        texto.contains('was not found in the application assets');
    if (ehFamiliaNaoEncontrada) return;
    anterior?.call(detalhes);
  };
  try {
    await corpo();
  } finally {
    FlutterError.onError = anterior;
  }
}
