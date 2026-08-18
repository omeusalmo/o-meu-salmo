import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Análise estática: o acento de PREENCHIMENTO não pode pintar TEXTO.
///
/// `context.colorAccent` é cobalt-400 no escuro e dá 3.64:1 sobre a superfície.
/// Passa como elemento gráfico (3:1) e reprova como texto (4.5:1). Para texto
/// existe `context.colorAccentText`.
///
/// Teste de render não pega isto: a cor está certa em algum tema, o layout não
/// quebra, e nada estoura. O defeito só aparece medindo contraste — e o padrão
/// que o esconde é `final accent = context.colorAccent` no topo do build com o
/// uso trinta linhas abaixo, dentro de um TextStyle.
///
/// Exceção declarada: a regra de display do DS permite o acento de
/// preenchimento em texto quando as QUATRO condições valem juntas (≥28px,
/// Playfair Display, peso ≥400 e ≥3.5:1). Para usar a exceção, escreva
/// "regra de display" num comentário logo acima da linha do `color:`. A
/// exceção mora ao lado do código, não numa lista longe dele.
void main() {
  test('o acento de preenchimento não pinta texto em lib/', () {
    final achados = <String>[];

    for (final arquivo in _arquivosDart(Directory('lib'))) {
      achados.addAll(_analisar(arquivo));
    }

    expect(
      achados,
      isEmpty,
      reason: 'Acento de preenchimento usado como cor de texto:\n'
          '${achados.join('\n')}\n\n'
          'Troque por context.colorAccentText. Se for numeral de display que '
          'cumpre as quatro condições do DS, escreva "regra de display" num '
          'comentário logo acima da linha do color:.',
    );
  });

  test('o próprio detector funciona', () {
    // Sem isto, um erro no regex faria o teste passar sempre e a suíte daria
    // uma garantia que não existe.
    const ruim = '''
      Widget build(BuildContext context) {
        final accent = context.colorAccent;
        return Text('oi', style: GoogleFonts.instrumentSans(
          fontSize: 13,
          color: accent,
        ));
      }
    ''';
    const bom = '''
      Widget build(BuildContext context) {
        final accent = context.colorAccent;
        return Text('1', style: GoogleFonts.playfairDisplay(
          fontSize: 32,
          // regra de display
          color: accent,
        ));
      }
    ''';
    const seguro = '''
      Widget build(BuildContext context) {
        final accent = context.colorAccentText;
        return Text('oi', style: GoogleFonts.instrumentSans(color: accent));
      }
    ''';

    expect(_analisarFonte('teste.dart', ruim), hasLength(1));
    expect(_analisarFonte('teste.dart', bom), isEmpty);
    expect(_analisarFonte('teste.dart', seguro), isEmpty);
  });
}

// ─────────────────────────────────────────────────────────────────────────────

const _marcadorDeExcecao = 'regra de display';

/// Variáveis que recebem o acento de preenchimento.
/// O negative lookahead evita casar colorAccentText e colorAccentFill.
final _atribuicao =
    RegExp(r'(?:final|var)\s+(\w+)\s*=\s*context\.colorAccent(?![A-Za-z])');

/// Início de um bloco de estilo de texto.
///
/// Inclui as fábricas do AppTheme (`AppTheme.emphasis14(cor)` e irmãs): a cor
/// entra como argumento posicional, sem `color:`, e por isso escapava da
/// versão anterior deste detector — foi assim que "Explorar coleções" ficou a
/// 4.2:1 em produção.
final _inicioDeEstilo = RegExp(
  r'(?:TextStyle|GoogleFonts\.\w+|AppTheme\.(?:caption14|eyebrowLabel|body15'
  r'|buttonLabel|emphasis14|bodyRelaxed15|emphasisTracked15|sectionHeadline))'
  r'\s*\(',
);

/// Fábrica do AppTheme: a cor é o primeiro argumento posicional.
final _fabricaDeEstilo = RegExp(
  r'AppTheme\.(?:caption14|eyebrowLabel|body15|buttonLabel|emphasis14'
  r'|bodyRelaxed15|emphasisTracked15|sectionHeadline)\s*\(',
);

/// `foregroundColor:` de botão: o rótulo herda essa cor, então é texto.
final _corDeFrente = RegExp(r'foregroundColor:\s*([\w.]+)');

Iterable<File> _arquivosDart(Directory dir) sync* {
  for (final e in dir.listSync(recursive: true)) {
    if (e is File && e.path.endsWith('.dart')) yield e;
  }
}

List<String> _analisar(File arquivo) =>
    _analisarFonte(arquivo.path, arquivo.readAsStringSync());

List<String> _analisarFonte(String caminho, String fonte) {
  final suspeitos = <String>{
    for (final m in _atribuicao.allMatches(fonte)) m.group(1)!,
  };
  // Uso direto, sem passar por variável.
  final alvos = <String>{...suspeitos, r'context\.colorAccent'};

  final alternativas = alvos
      .map((a) => a.startsWith('context') ? a : RegExp.escape(a))
      .join('|');
  // Cor de texto por argumento nomeado.
  final corComSuspeito =
      RegExp('color:\\s*($alternativas)(?![A-Za-z])');
  // Cor de texto por argumento posicional das fábricas do AppTheme.
  final posicionalComSuspeito =
      RegExp('^\\s*($alternativas)(?![A-Za-z])');
  // Uso direto do acento cru, sem passar pelo tema: não acompanha dark/light.
  final acentoCru = RegExp(r'AppColors\.cobalt(?:400|500|600)(?![A-Za-z])');

  final achados = <String>[];
  void anotar(int posicao, String oQue) =>
      achados.add('  $caminho:${_linhaDe(fonte, posicao)} — $oQue');

  for (final bloco in _blocosDeEstilo(fonte)) {
    final isento = bloco.texto.contains(_marcadorDeExcecao) ||
        _comentarioAcimaTemMarcador(fonte, bloco.inicio);
    if (isento) continue;

    final ehFabrica = _fabricaDeEstilo
        .matchAsPrefix(fonte, _inicioDaChamada(fonte, bloco.inicio)) != null;

    for (final m in corComSuspeito.allMatches(bloco.texto)) {
      anotar(bloco.inicio + m.start, 'color: ${m.group(1)}');
    }
    if (ehFabrica) {
      final m = posicionalComSuspeito.firstMatch(bloco.texto);
      if (m != null) anotar(bloco.inicio + m.start, 'AppTheme.…(${m.group(1)})');
    }
    for (final m in acentoCru.allMatches(bloco.texto)) {
      anotar(bloco.inicio + m.start, 'acento cru ${m.group(0)} em texto');
    }
  }

  // foregroundColor de botão vive fora de bloco de estilo, mas o rótulo herda.
  for (final m in _corDeFrente.allMatches(fonte)) {
    final valor = m.group(1)!;
    final suspeito = suspeitos.contains(valor) ||
        valor == 'context.colorAccent' ||
        RegExp(r'^AppColors\.cobalt(400|500|600)$').hasMatch(valor);
    if (!suspeito) continue;
    if (_comentarioAcimaTemMarcador(fonte, m.start)) continue;
    anotar(m.start, 'foregroundColor: $valor');
  }

  return achados;
}

/// Volta do `(` até o começo do identificador da chamada.
int _inicioDaChamada(String fonte, int depoisDoParenteses) {
  var i = depoisDoParenteses - 1;
  while (i > 0 && RegExp(r'[\w.]').hasMatch(fonte[i - 1])) {
    i--;
  }
  return i;
}

class _Bloco {
  final int inicio;
  final String texto;
  const _Bloco(this.inicio, this.texto);
}

/// Recorta cada `TextStyle(...)` / `GoogleFonts.x(...)` equilibrando parênteses,
/// para não confundir o `color:` de um Container com o de um estilo de texto.
List<_Bloco> _blocosDeEstilo(String fonte) {
  final blocos = <_Bloco>[];
  for (final m in _inicioDeEstilo.allMatches(fonte)) {
    var profundidade = 0;
    for (var i = m.end - 1; i < fonte.length; i++) {
      final c = fonte[i];
      if (c == '(') profundidade++;
      if (c == ')') {
        profundidade--;
        if (profundidade == 0) {
          blocos.add(_Bloco(m.end, fonte.substring(m.end, i)));
          break;
        }
      }
    }
  }
  return blocos;
}

/// Procura o marcador no bloco de comentário contíguo logo acima do estilo.
///
/// Aceita o comentário acima do `style:` e não só o colado no `color:`, que é
/// onde as pessoas escrevem de verdade.
bool _comentarioAcimaTemMarcador(String fonte, int inicioDoBloco) {
  final antes = fonte.substring(0, inicioDoBloco).split('\n');
  // A última entrada é a própria linha do estilo, ainda incompleta.
  for (var i = antes.length - 2; i >= 0 && i >= antes.length - 10; i--) {
    final linha = antes[i].trim();
    if (linha.isEmpty) continue;
    if (!linha.startsWith('//')) return false;
    if (linha.contains(_marcadorDeExcecao)) return true;
  }
  return false;
}

int _linhaDe(String fonte, int posicao) =>
    '\n'.allMatches(fonte.substring(0, posicao)).length + 1;
