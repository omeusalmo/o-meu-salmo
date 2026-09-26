import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_service.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/constants/copy_apoio.dart';
import 'package:salmos_app/features/home/home_screen.dart';
import 'package:salmos_app/shared/widgets/apoio_card.dart';

import '../../a11y/text_scale_harness.dart';
import '../../shared/fake_compra.dart';

/// O card de apoio na Home aparece só quando há produto para vender.
///
/// Sem isto o Jeff não poderia publicar nenhuma atualização antes de os produtos
/// apoio_5/10/25 estarem ativos na Play Console: o card apareceria e todo toque
/// terminaria no estado de erro.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  setUp(() {
    // Estado em que o card É devido: passou do sétimo dia, nunca apoiou, nunca
    // dispensou. O único motivo para não aparecer é a loja.
    SharedPreferences.setMockInitialValues({
      AppConstants.prefPrimeiraAberturaMs:
          DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      AppConstants.prefLeiturasCompletas: 20,
      AppConstants.prefReviewSessionCount: 9,
      AppConstants.prefUserSeed: 20260816,
      AppConstants.prefNotificationEnabled: false,
    });
    ApoioService.instance = ApoioService();
  });

  tearDown(desligarLojaFalsa);

  testWidgets('loja sem produto: o card não aparece', (tester) async {
    ligarLojaVazia();
    await _home(tester);

    expect(find.byType(ApoioCardHome), findsNothing);
    expect(find.text(CopyApoio.cardTitulo), findsNothing);
  });

  testWidgets('loja com produto: o card aparece', (tester) async {
    ligarLojaFalsa();
    await _home(tester);

    expect(find.byType(ApoioCardHome), findsOneWidget);
    expect(find.text(CopyApoio.cardTitulo), findsOneWidget);
  });
}

/// Home alta o bastante para o card, que é sempre o último item, caber sem
/// rolar.
Future<void> _home(WidgetTester tester) => renderizar(
      tester,
      const HomeScreen(),
      nome: 'home card apoio',
      escala: 1.0,
      tamanho: const Size(360, 1600),
    );
