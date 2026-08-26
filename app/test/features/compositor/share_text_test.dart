import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/constants/app_constants.dart';

void main() {
  group('URL de compartilhamento', () {
    test('aponta para a página pública do salmo', () {
      expect(AppConstants.urlDoSalmo(91), 'https://omeusalmo.com.br/salmos/91');
    });

    test('bate exatamente com o App Link do AndroidManifest', () {
      // O manifest declara autoVerify para https://omeusalmo.com.br/salmos/:numero.
      // Barra final ou .html a mais faria o link abrir no navegador em vez do app.
      final url = AppConstants.urlDoSalmo(23);
      expect(url, isNot(endsWith('/')));
      expect(url, isNot(contains('.html')));
      expect(Uri.parse(url).host, 'omeusalmo.com.br');
      expect(Uri.parse(url).pathSegments, ['salmos', '23']);
    });

    test('privacidade usa o domínio próprio, não o github.io antigo', () {
      expect(AppConstants.urlPrivacidade, startsWith(AppConstants.siteBaseUrl));
      expect(AppConstants.urlPrivacidade, isNot(contains('github.io')));
    });
  });
}
