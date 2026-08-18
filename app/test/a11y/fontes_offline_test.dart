import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'text_scale_harness.dart';

/// O app é vendido como offline: a ficha da Play Store e o site dizem que
/// funciona sem internet depois de instalado. A tipografia faz parte dessa
/// promessa — se as fontes forem baixadas na primeira abertura, quem instala
/// sem rede vê o app inteiro com a fonte do sistema, logo na primeira
/// impressão.
///
/// Estes testes travam as três pontas que garantem isso: os arquivos existem,
/// estão declarados no pubspec, e a busca em runtime está desligada.
void main() {
  test('a busca de fonte em runtime está desligada no start do app', () {
    final main = File('lib/main.dart').readAsStringSync();

    expect(
      main.contains('GoogleFonts.config.allowRuntimeFetching = false'),
      isTrue,
      reason: 'Sem isto o google_fonts baixa a fonte que faltar, escondendo em '
          'desenvolvimento um bug que só aparece para quem instala sem rede.',
    );
  });

  test('as fontes estão declaradas como assets no pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      RegExp(r'^\s*-\s*assets/fonts/\s*$', multiLine: true).hasMatch(pubspec),
      isTrue,
      reason: 'assets/fonts/ precisa estar na lista de assets. O google_fonts '
          'não lê o bloco `fonts:` — ele varre o AssetManifest.',
    );
  });

  test('todo peso que o app usa tem arquivo em assets/fonts', () {
    // O google_fonts casa pelo FIM do nome do arquivo com "Familia-Variante"
    // (findFamilyWithVariantAssetPath). Renomear um arquivo aqui não dá erro
    // de compilação: a família simplesmente volta a ser buscada na rede.
    const esperados = [
      'PlayfairDisplay-Regular.ttf',
      'PlayfairDisplay-Italic.ttf',
      'PlayfairDisplay-MediumItalic.ttf',
      'PlayfairDisplay-Bold.ttf',
      'Cormorant-Italic.ttf',
      'InstrumentSans-Regular.ttf',
      'InstrumentSans-Italic.ttf',
      'InstrumentSans-Medium.ttf',
    ];

    final presentes = Directory('assets/fonts')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();

    final faltando =
        esperados.where((e) => !presentes.contains(e)).toList();

    expect(faltando, isEmpty,
        reason: 'Sem estes arquivos o peso correspondente cai para a fonte do '
            'sistema em quem estiver sem rede: $faltando');
  });

  test('as licenças OFL acompanham as fontes', () {
    // Não é burocracia: redistribuir fonte SIL OFL dentro do APK exige o texto
    // da licença junto. Antes as fontes só existiam no teste; agora vão no
    // aparelho do usuário.
    for (final familia in ['playfairdisplay', 'cormorant', 'instrumentsans']) {
      expect(File('assets/fonts/OFL-$familia.txt').existsSync(), isTrue,
          reason: 'Falta a licença OFL de $familia.');
    }
  });

  testWidgets('toda variante usada pelo app resolve sem rede', (tester) async {
    // A prova de verdade: com a busca em runtime desligada, disparar todas as
    // combinações que o app pede e esperar. Se qualquer uma não estiver nos
    // assets, o google_fonts lança e este teste falha dizendo qual.
    GoogleFonts.config.allowRuntimeFetching = false;

    for (final estilo in kEstilosUsadosPeloApp) {
      estilo();
    }

    // Com timeout: se uma fonte faltar, o pendingFonts pode não resolver
    // nunca, e sem o limite este teste penduraria o job de CI em vez de
    // reprovar. O teste irmão (arquivos presentes) é quem aponta o culpado.
    await expectLater(
      GoogleFonts.pendingFonts().timeout(const Duration(seconds: 20)),
      completes,
    );
  });
}
