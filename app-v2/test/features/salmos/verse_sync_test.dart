import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/features/salmos/verse_sync.dart';

void main() {
  group('activeVerseIndex', () {
    const versiculos = [
      'O Senhor é o meu pastor; nada me faltará.', // 42 chars
      'Ele me faz repousar em pastos verdejantes.', // 42 chars
      'Refrigera a minha alma.', // 23 chars
    ];

    test('posição zero retorna o primeiro versículo', () {
      expect(
        activeVerseIndex(
          position: Duration.zero,
          duration: const Duration(seconds: 30),
          versiculos: versiculos,
        ),
        0,
      );
    });

    test('posição no fim retorna o último versículo', () {
      expect(
        activeVerseIndex(
          position: const Duration(seconds: 30),
          duration: const Duration(seconds: 30),
          versiculos: versiculos,
        ),
        versiculos.length - 1,
      );
    });

    test('posição além da duração satura no último versículo', () {
      expect(
        activeVerseIndex(
          position: const Duration(seconds: 45),
          duration: const Duration(seconds: 30),
          versiculos: versiculos,
        ),
        versiculos.length - 1,
      );
    });

    test('ponderação por comprimento: metade do tempo cai no segundo', () {
      // total 107 chars; 50% → alvo 53.5 → dentro do segundo (42..84)
      expect(
        activeVerseIndex(
          position: const Duration(seconds: 15),
          duration: const Duration(seconds: 30),
          versiculos: versiculos,
        ),
        1,
      );
    });

    test('duração zero retorna 0 sem dividir por zero', () {
      expect(
        activeVerseIndex(
          position: const Duration(seconds: 5),
          duration: Duration.zero,
          versiculos: versiculos,
        ),
        0,
      );
    });

    test('lista vazia retorna 0', () {
      expect(
        activeVerseIndex(
          position: const Duration(seconds: 5),
          duration: const Duration(seconds: 30),
          versiculos: const [],
        ),
        0,
      );
    });
  });
}
