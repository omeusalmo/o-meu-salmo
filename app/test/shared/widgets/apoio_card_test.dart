import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_service.dart';
import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/constants/copy_apoio.dart';
import 'package:salmos_app/core/theme/app_theme.dart';
import 'package:salmos_app/shared/widgets/apoio_card.dart';
import 'package:salmos_app/shared/widgets/apoio_sheet.dart';

import '../fake_compra.dart';

/// O card discreto de apoio na Home.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApoioService.instance = ApoioService();
  });

  testWidgets('mostra a copy aprovada e não promete nada em troca',
      (tester) async {
    await _montar(tester);

    expect(find.text(CopyApoio.cardTitulo), findsOneWidget);
    expect(find.text(CopyApoio.cardCorpo), findsOneWidget);
    expect(find.text(CopyApoio.cardCta), findsOneWidget);
    // Eyebrow em caixa alta na tela, texto original no TalkBack.
    expect(find.text(CopyApoio.cardEyebrow.toUpperCase()), findsOneWidget);
  });

  testWidgets('o X tem 48dp e rótulo de acessibilidade', (tester) async {
    final handle = tester.ensureSemantics();
    await _montar(tester);

    final x = find.ancestor(
      of: find.byIcon(Icons.close_rounded),
      matching: find.byType(InkWell),
    );
    final tamanho = tester.getSize(x.first);
    expect(tamanho.height, greaterThanOrEqualTo(48.0));
    expect(tamanho.width, greaterThanOrEqualTo(48.0));

    // Sem isto o TalkBack anuncia só "botão", sem dizer o que ele faz.
    expect(
      tester.getSemantics(find.byIcon(Icons.close_rounded)),
      matchesSemantics(
        label: CopyApoio.cardDispensar,
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('o X avisa a Home e grava a dispensa', (tester) async {
    var dispensou = false;
    await _montar(tester, onDispensar: () => dispensou = true);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(dispensou, isTrue, reason: 'A Home não foi avisada de tirar o card.');
    final p = await SharedPreferences.getInstance();
    expect(p.getInt(AppConstants.prefApoioCardDispensadoMs), isNotNull,
        reason: 'Sem a data gravada, o card voltaria na próxima abertura.');
  });

  testWidgets('"Apoiar o app" abre o sheet direto no valor, sem a pergunta',
      (tester) async {
    // Quem toca num card que já diz "apoie o app" não precisa ser perguntado se
    // o app faz companhia a ele.
    await _montar(tester);

    await tester.tap(find.text(CopyApoio.cardCta));
    await tester.pumpAndSettle();

    expect(find.byType(ApoioSheet), findsOneWidget);
    expect(find.text(CopyApoio.perguntaTitulo), findsNothing);
    expect(find.text('Apoiar com R\$ 10,00'), findsOneWidget);
  });

  testWidgets('o botão do card não ocupa a linha inteira', (tester) async {
    // O botão de largura total é do Salmo do dia. Este card é discreto: contorno,
    // sem preenchimento, e um botão do tamanho do rótulo.
    await _montar(tester);

    final botao = tester.getSize(
      find.ancestor(of: find.text(CopyApoio.cardCta), matching: find.byType(InkWell)).first,
    );
    expect(botao.width, lessThan(320 - 40));
  });
}

Future<void> _montar(
  WidgetTester tester, {
  VoidCallback? onDispensar,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(360, 800);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.sp5),
        child: ApoioCardHome(
          onDispensar: onDispensar ?? () {},
          criarCompra: FakeCompraApoio.new,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}
