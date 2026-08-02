import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/shared/widgets/tema_chip.dart';

void main() {
  group('temaLabel', () {
    test('mapeia temas conhecidos para PT com acento', () {
      expect(temaLabel('protecao'), 'Proteção');
      expect(temaLabel('gratidao'), 'Gratidão');
      expect(temaLabel('fe'), 'Fé');
      expect(temaLabel('ansiedade'), 'Ansiedade');
    });

    test('fallback capitaliza tema desconhecido', () {
      expect(temaLabel('novotema'), 'Novotema');
    });

    test('string vazia retorna vazia', () {
      expect(temaLabel(''), '');
    });

    test('todos os labels do mapa são não-vazios e capitalizados', () {
      for (final entry in kTemaLabels.entries) {
        expect(entry.value.isNotEmpty, isTrue, reason: entry.key);
        expect(entry.value[0], entry.value[0].toUpperCase(), reason: entry.key);
      }
    });
  });
}
