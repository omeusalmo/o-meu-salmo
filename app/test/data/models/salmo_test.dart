import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/data/models/salmo.dart';

void main() {
  group('Salmo.fromJson', () {
    test('parseia um registro válido', () {
      final s = Salmo.fromJson({
        'numero': 23,
        'titulo': 'O Senhor é o Meu Pastor',
        'traducao': 'Almeida',
        'versiculos': ['O Senhor é o meu pastor.'],
        'temas': ['conforto', 'confianca'],
        'reflexao': 'Uma reflexão.',
        'reflexao_pergunta': 'Uma pergunta?',
        'audio': 'audios/salmo_023.mp3',
        'favorito': true,
      });
      expect(s.numero, 23);
      expect(s.temas, ['conforto', 'confianca']);
      expect(s.reflexao, 'Uma reflexão.');
      expect(s.reflexaoPergunta, 'Uma pergunta?');
      expect(s.favorito, isTrue);
    });

    test('campos opcionais têm defaults seguros', () {
      final s = Salmo.fromJson({
        'numero': 1,
        'titulo': 'T',
        'traducao': 'X',
        'versiculos': <String>[],
        'temas': <String>[],
      });
      expect(s.audio, '');
      expect(s.favorito, isFalse);
      expect(s.reflexao, isNull);
      expect(s.reflexaoPergunta, isNull);
    });

    test('reflexao vazia vira null', () {
      final s = Salmo.fromJson({
        'numero': 1,
        'titulo': 'T',
        'traducao': 'X',
        'versiculos': <String>[],
        'temas': <String>[],
        'reflexao': '',
      });
      expect(s.reflexao, isNull);
    });

    test('registro malformado lança — garante o try/skip do repositório', () {
      // 'numero' ausente: o cast falha. O repositório pula entradas assim
      // sem derrubar as demais (parse resiliente por item).
      expect(() => Salmo.fromJson({'titulo': 'sem numero'}), throwsA(anything));
    });
  });
}
