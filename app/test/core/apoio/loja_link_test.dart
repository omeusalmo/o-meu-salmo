import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/core/review/review_service.dart';
import 'package:salmos_app/core/services/link_service.dart';

/// O link da ficha da loja.
///
/// Duas coisas que só quebram em produção, e caladas: o applicationId divergir
/// da constante (o link abre a ficha de um app que não existe) e o plano B da
/// URL https não existir (em aparelho sem Play Services o `market://` não
/// resolve e o toque morre em silêncio).
void main() {
  test('androidPackageId bate com o applicationId do Gradle', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final achado = RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradle);

    expect(achado, isNotNull, reason: 'applicationId não encontrado no Gradle.');
    expect(
      achado!.group(1),
      AppConstants.androidPackageId,
      reason: 'O applicationId mudou e a constante ficou para trás. O link de '
          '"Avaliar na Play Store" abriria a ficha de outro app.',
    );
  });

  test('as duas URLs da loja apontam para o mesmo pacote', () {
    expect(AppConstants.uriLojaNativa, contains(AppConstants.androidPackageId));
    expect(AppConstants.urlLojaWeb, contains(AppConstants.androidPackageId));
    expect(Uri.parse(AppConstants.uriLojaNativa).scheme, 'market');
    expect(Uri.parse(AppConstants.urlLojaWeb).host, 'play.google.com');
  });

  group('abrirFichaDaLoja', () {
    tearDown(() => LinkService.instance = LinkService());

    test('tenta o app da Play Store primeiro', () async {
      final link = _LinkFalso(abre: true);
      LinkService.instance = link;

      expect(await ReviewService().abrirFichaDaLoja(), isTrue);
      expect(link.abertas, hasLength(1));
      expect(link.abertas.single.scheme, 'market');
    });

    test('cai para o navegador quando market:// não resolve', () async {
      // Aparelho sem Play Services (Huawei, ROM alternativa): sem este plano B
      // o item de Ajustes não faria nada e ninguém saberia por quê.
      final link = _LinkFalso(abre: false, abreSegunda: true);
      LinkService.instance = link;

      expect(await ReviewService().abrirFichaDaLoja(), isTrue);
      expect(link.abertas, hasLength(2));
      expect(link.abertas.last.host, 'play.google.com');
    });

    test('devolve false quando nenhum dos dois abre', () async {
      final link = _LinkFalso(abre: false);
      LinkService.instance = link;

      expect(await ReviewService().abrirFichaDaLoja(), isFalse);
    });
  });
}

class _LinkFalso extends LinkService {
  _LinkFalso({required this.abre, this.abreSegunda = false});

  final bool abre;
  final bool abreSegunda;
  final List<Uri> abertas = [];

  @override
  Future<bool> abrir(Uri uri, {bool externo = false}) async {
    abertas.add(uri);
    if (abertas.length == 1) return abre;
    return abreSegunda;
  }
}
