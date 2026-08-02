import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salmos_app/shared/widgets/error_state_view.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('mostra título/mensagem e dispara a ação de retry', (tester) async {
    var toques = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ErrorStateView(
          titulo: 'Não consegui carregar',
          mensagem: 'Tente de novo.',
          acaoLabel: 'Tentar de novo',
          onAcao: () => toques++,
        ),
      ),
    ));

    expect(find.text('Não consegui carregar'), findsOneWidget);
    expect(find.text('Tente de novo.'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();
    expect(toques, 1);
  });

  testWidgets('sem ação, não renderiza botão', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ErrorStateView(titulo: 'Só título')),
    ));

    expect(find.text('Só título'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
