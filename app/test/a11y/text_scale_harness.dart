import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salmos_app/core/theme/app_theme.dart';
import 'package:salmos_app/data/providers/audio_provider.dart';
import 'package:salmos_app/data/providers/salmos_providers.dart';
import 'package:salmos_app/data/repositories/salmos_repository.dart';

/// Escalas de fonte testadas.
///
/// 1.0 = padrão; 1.3 = teto que o app aplica hoje (main.dart:88);
/// 1.5 e 2.0 = passos "Grande"/"Enorme" que o Android e a One UI oferecem e que
/// as diretrizes de acessibilidade do Android esperam que o app suporte.
const List<double> kEscalas = [1.0, 1.3, 1.5, 2.0];

/// Teto de ampliação que o app aplica hoje em `main.dart`.
const double kTetoAtual = 1.3;

/// Aparelho de referência do público-alvo: 360×800 dp (Galaxy A / Moto G).
const Size kTelaTipica = Size(360, 800);

/// Aparelho pequeno ainda comum na base Android brasileira.
const Size kTelaPequena = Size(320, 640);

// ─────────────────────────────────────────────────────────────────────────────
// Dependências falsas
// ─────────────────────────────────────────────────────────────────────────────

/// Falso player de áudio: o just_audio real não sobe em teste (sem plugin
/// nativo). Renderiza a barra no estado mais denso — play + dois timecodes +
/// trilha —, que é o pior caso de largura da tela de leitura.
class FakeAudioNotifier extends AudioPlayerNotifier {
  @override
  AudioState build() => const AudioState(
        isAvailable: true,
        duration: Duration(minutes: 3, seconds: 42),
        position: Duration(minutes: 1, seconds: 5),
      );

  @override
  Future<void> load(String audioPath) async {}
}

/// Repositório real, com o `assets/salmos.json` de produção já aquecido.
/// Conteúdo real importa: o que quebra layout é o título comprido de verdade,
/// não um texto de exemplo curto.
class SalmosFixture {
  static final SalmosRepository repo = SalmosRepository();

  static Future<void> aquecer() async {
    await repo.getSalmos();
    await repo.getColecoes();
  }
}

List<Override> overridesPadrao() => [
      salmosRepositoryProvider.overrideWithValue(SalmosFixture.repo),
      audioPlayerProvider.overrideWith(FakeAudioNotifier.new),
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Fontes
// ─────────────────────────────────────────────────────────────────────────────

/// `true` quando a suíte conseguiu carregar uma fonte proporcional real.
///
/// Sem isso o `flutter test` usa a fonte sintética de teste, em que cada glifo
/// ocupa exatamente 1 em — cerca do dobro de uma fonte de interface real. Toda
/// medida de largura sairia inflada e o relatório apontaria corte onde não há.
bool fontesReais = false;

/// Registra uma fonte real sob os nomes de família que o `google_fonts` gera.
///
/// O app baixa Playfair/Cormorant/Instrument Sans em tempo de execução, o que
/// não acontece em teste. Roboto (a fonte de sistema do Android) entra no lugar
/// das três: as métricas não são idênticas às de produção, mas são de uma fonte
/// proporcional de verdade — que é o que importa para medir se o texto cabe.
Future<void> carregarFontesReais() async {
  final arquivo = _acharRoboto();
  if (arquivo == null) return;

  final bytes = ByteData.sublistView(await arquivo.readAsBytes());

  // Nome de família do google_fonts = "Familia_variante"
  // (GoogleFontsFamilyWithVariant.toString).
  const familias = ['InstrumentSans', 'PlayfairDisplay', 'Cormorant'];
  const variantes = [
    'regular', 'italic',
    '300', '300italic',
    '500', '500italic',
    '600', '600italic',
    '700', '700italic',
  ];

  for (final familia in familias) {
    for (final variante in variantes) {
      await (FontLoader('${familia}_$variante')..addFont(Future.value(bytes)))
          .load();
    }
  }
  fontesReais = true;
}

File? _acharRoboto() {
  final candidatos = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final raiz?)
      '$raiz/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  ];

  // Em `flutter test` o executável é o flutter_tester, dentro do cache do SDK.
  // Sobe a árvore até achar a pasta de fontes do Material.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    candidatos.add('${dir.path}/material_fonts/Roboto-Regular.ttf');
    candidatos.add('${dir.path}/artifacts/material_fonts/Roboto-Regular.ttf');
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }

  for (final caminho in candidatos) {
    final arquivo = File(caminho);
    if (arquivo.existsSync()) return arquivo;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Achados
// ─────────────────────────────────────────────────────────────────────────────

enum TipoAchado {
  /// Exceção de layout do Flutter: o conteúdo não coube na caixa.
  /// Na tela real: faixa listrada amarela e preta, conteúdo sumindo pela borda.
  overflow,

  /// Texto que passou do número de linhas permitido e foi cortado com "…".
  /// Na tela real: o usuário lê meio título e nunca vê o resto.
  reticencias,

  /// A palavra mais larga não coube na caixa reservada e é cortada sem aviso.
  /// Na tela real: o número do Salmo aparece pela metade ("10" no lugar de 105").
  corteHorizontal,
}

class Achado {
  final TipoAchado tipo;

  /// Identidade estável entre escalas — sem os números, que mudam a cada
  /// escala. É o que permite dizer "isto é novo em 2.0x".
  final String chave;

  /// Texto completo, com as medidas.
  final String detalhe;

  const Achado(this.tipo, this.chave, this.detalhe);

  @override
  String toString() => '[${tipo.name}] $detalhe';
}

/// Resultado de uma renderização.
class Resultado {
  final String tela;
  final double escala;
  final List<Achado> achados;

  const Resultado(this.tela, this.escala, this.achados);

  bool get limpo => achados.isEmpty;

  List<Achado> doTipo(TipoAchado t) =>
      achados.where((a) => a.tipo == t).toList();

  /// Achados que aparecem aqui e não na linha de base — ou seja, causados pelo
  /// aumento de fonte, não pré-existentes.
  List<Achado> novosSobre(Resultado base) {
    final conhecidos = base.achados.map((a) => a.chave).toSet();
    return achados.where((a) => !conhecidos.contains(a.chave)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Renderização + coleta de evidência
// ─────────────────────────────────────────────────────────────────────────────

/// Renderiza [tela] com a fonte do sistema em [escala] e devolve tudo que
/// quebrou.
///
/// Três detectores, do mais duro ao mais sutil:
/// 1. exceções de layout capturadas em [FlutterError.onError] — a mensagem real
///    do Flutter, ex.: "A RenderFlex overflowed by 244 pixels on the bottom";
/// 2. `RenderParagraph.didExceedMaxLines` — texto truncado com reticências;
/// 3. `getMinIntrinsicWidth > size.width` — a maior palavra não cabe na caixa,
///    então é cortada na horizontal sem nenhum aviso visual.
///
/// O clamp de `main.dart` NÃO é aplicado aqui, de propósito: o objetivo é medir
/// o app cru, para saber o que aconteceria se o teto subisse.
Future<Resultado> renderizar(
  WidgetTester tester,
  Widget tela, {
  required String nome,
  required double escala,
  Size tamanho = kTelaTipica,
  ThemeMode modo = ThemeMode.dark,
  List<Override>? overrides,
  Future<void> Function(WidgetTester)? depoisDeRenderizar,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = tamanho;
  addTearDown(tester.view.reset);

  final erros = <FlutterErrorDetails>[];
  final anterior = FlutterError.onError;
  FlutterError.onError = erros.add;

  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides ?? overridesPadrao(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modo,
          debugShowCheckedModeBanner: false,
          home: tela,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(escala),
              // Sem animação: entrada em cascata e starfield ficam estáticos.
              // Elimina ticker infinito e mede o layout final, não o de entrada.
              disableAnimations: true,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await _assentar(tester);
    if (depoisDeRenderizar != null) {
      await depoisDeRenderizar(tester);
      await _assentar(tester);
    }
  } finally {
    FlutterError.onError = anterior;
  }

  final overflows = erros
      .where((e) => e.exception.toString().contains('overflow'))
      .toList();

  // Erro que não seja overflow é bug de setup do teste, não achado de fonte —
  // estoura aqui para não passar despercebido como se fosse resultado.
  final outros = erros
      .where((e) => !e.exception.toString().contains('overflow'))
      .toList();
  if (outros.isNotEmpty) {
    throw StateError(
      'Erro não relacionado a overflow em "$nome" @ ${escala}x:\n'
      '${outros.first.exception}',
    );
  }

  return Resultado(nome, escala, [
    ...overflows.map(_acharOverflow),
    ..._acharTextoCortado(tester),
  ]);
}

/// Pumps curtos para os FutureProvider (assets, SharedPreferences) resolverem,
/// mais um salto longo que descarrega timers agendados pelas telas (a tela de
/// leitura agenda o pedido de avaliação para 10s depois de abrir).
/// Não usa `pumpAndSettle`, que travaria em animações contínuas.
Future<void> _assentar(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
  await tester.pump(const Duration(seconds: 11));
}

Achado _acharOverflow(FlutterErrorDetails e) {
  final linha = e.exception.toString().split('\n').first.trim();
  final lado = RegExp(r'on the (\w+)').firstMatch(linha)?.group(1) ?? '?';
  final contexto = e.context?.toString() ?? '';
  return Achado(
    TipoAchado.overflow,
    'overflow:$lado:$contexto',
    contexto.isEmpty ? linha : '$linha ($contexto)',
  );
}

List<Achado> _acharTextoCortado(WidgetTester tester) {
  final achados = <Achado>[];
  // `allRenderObjects` repete o mesmo RenderParagraph (Text e RichText são dois
  // elementos apontando para ele) — identidade evita achado duplicado.
  final vistos = Set<RenderParagraph>.identity();

  for (final ro in tester.allRenderObjects) {
    if (ro is! RenderParagraph) continue;
    if (!ro.hasSize) continue;
    if (!vistos.add(ro)) continue;

    final texto = ro.text.toPlainText().replaceAll('\n', ' ').trim();
    if (texto.isEmpty) continue;
    final amostra = texto.length > 46 ? '${texto.substring(0, 46)}…' : texto;

    if (ro.didExceedMaxLines) {
      achados.add(Achado(
        TipoAchado.reticencias,
        'reticencias:$amostra',
        '"$amostra" cortado (maxLines: ${ro.maxLines})',
      ));
      continue;
    }

    // Largura da maior palavra indivisível vs. largura que ela recebeu.
    final minima = ro.getMinIntrinsicWidth(double.infinity);
    if (minima > ro.size.width + 0.5) {
      achados.add(Achado(
        TipoAchado.corteHorizontal,
        'corte:$amostra',
        '"$amostra" precisa de ${minima.toStringAsFixed(1)}px '
        'e recebeu ${ro.size.width.toStringAsFixed(1)}px',
      ));
    }
  }
  return achados;
}

// ─────────────────────────────────────────────────────────────────────────────
// Relatório
// ─────────────────────────────────────────────────────────────────────────────

/// Imprime a tabela da tela no output do `flutter test`. É o entregável
/// principal da suíte: ela não existe para dar verde, existe para dizer em que
/// escala cada tela começa a quebrar e com qual mensagem.
///
/// A escala 1.0 vira linha de base: o que já acontece sem aumento de fonte
/// nenhum é ruído conhecido (ex.: reticências de propósito no card de Salmo).
/// Nas demais escalas só entram os achados NOVOS.
void relatar(String tela, List<Resultado> resultados) {
  final base = resultados.firstWhere((r) => r.escala == 1.0);
  final buffer = StringBuffer()
    ..writeln('')
    ..writeln('┌── $tela');

  if (base.limpo) {
    buffer.writeln('│ 1.0x  linha de base limpa');
  } else {
    buffer.writeln('│ 1.0x  linha de base: ${base.achados.length} '
        'ocorrência(s) já presentes sem aumento de fonte');
    for (final a in base.achados) {
      buffer.writeln('│         $a');
    }
  }

  for (final r in resultados.where((r) => r.escala != 1.0)) {
    final novos = r.novosSobre(base);
    // Overflow é o achado grave — aparece sempre, mesmo quando herdado da
    // escala anterior, senão o relatório dá a impressão de que sarou.
    final aindaEstoura = novos.every((a) => a.tipo != TipoAchado.overflow) &&
        r.doTipo(TipoAchado.overflow).isNotEmpty;

    if (novos.isEmpty && !aindaEstoura) {
      buffer.writeln('│ ${r.escala}x  nada novo');
      continue;
    }
    final sufixo = aindaEstoura ? ' (+ overflow que já vinha da escala menor)'
        : '';
    buffer.writeln('│ ${r.escala}x  ${novos.length} achado(s) novo(s)$sufixo');
    for (final a in novos) {
      buffer.writeln('│         $a');
    }
  }

  buffer.writeln('└──');
  debugPrint(buffer.toString());
}

/// Menor escala em que a tela passou a estourar layout (overflow) em relação à
/// linha de base. `null` = aguentou todas as escalas testadas.
double? escalaDoPrimeiroOverflow(List<Resultado> resultados) {
  final base = resultados.firstWhere((r) => r.escala == 1.0);
  for (final r in resultados.where((r) => r.escala != 1.0)) {
    if (r.novosSobre(base).any((a) => a.tipo == TipoAchado.overflow)) {
      return r.escala;
    }
  }
  return null;
}
