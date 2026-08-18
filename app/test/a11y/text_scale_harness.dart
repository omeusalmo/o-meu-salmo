import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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

/// Teto de ampliação que o app aplica em `main.dart`.
/// Subiu de 1.3 para 2.0 quando o onboarding passou a se proteger sozinho.
const double kTetoAtual = 2.0;

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

/// `true` quando as fontes do produto foram carregadas.
///
/// Sem fonte real o `flutter test` usa a fonte sintética, em que cada glifo
/// ocupa 1 em, quase o dobro de uma fonte de interface. Toda medida de largura
/// sairia inflada e o relatório apontaria corte onde não há.
bool fontesReais = false;

/// `true` quando as fontes vieram dos assets do app, e não de um substituto.
/// Medida de largura só é fiel a produção quando isto é `true`.
bool fontesDoProduto = false;

/// Cada combinação de família, peso e estilo que o app pede de fato.
///
/// Levantada varrendo as chamadas `GoogleFonts.*` de `lib/`. É a lista que
/// define quais arquivos precisam existir em `assets/fonts/`: o google_fonts
/// resolve pelo nome do arquivo, e um peso que falte volta a ser buscado na
/// rede (ou estoura, com `allowRuntimeFetching` desligado).
final List<TextStyle Function()> kEstilosUsadosPeloApp = [
  () => GoogleFonts.playfairDisplay(fontWeight: FontWeight.w400),
  () => GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
  () => GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
  () => GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
  () => GoogleFonts.cormorant(
      fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
  () => GoogleFonts.instrumentSans(fontWeight: FontWeight.w400),
  () => GoogleFonts.instrumentSans(
      fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
  () => GoogleFonts.instrumentSans(fontWeight: FontWeight.w500),
];

/// Carrega as fontes do jeito que o app carrega: dos assets, sem rede.
///
/// Desde que as fontes passaram a ser empacotadas no pubspec, o teste não
/// precisa mais registrar nada à mão — o próprio google_fonts acha os arquivos
/// no AssetManifest. O que ainda falta é esperar: os carregamentos são
/// assíncronos e, sem o await, o primeiro quadro sairia com a fonte de reserva.
Future<void> carregarFontesReais() async {
  await _carregarIconesDoMaterial();

  GoogleFonts.config.allowRuntimeFetching = false;
  for (final estilo in kEstilosUsadosPeloApp) {
    estilo();
  }
  await GoogleFonts.pendingFonts();

  fontesReais = true;
  fontesDoProduto = true;
}

/// Sem isto os ícones saem como quadrado vazio nos renders, e não dá para
/// conferir coisas como a marca de seleção do tema.
Future<void> _carregarIconesDoMaterial() async {
  final arquivo = _acharArtefato('MaterialIcons-Regular.otf');
  if (arquivo == null) return;
  final bytes = ByteData.sublistView(await arquivo.readAsBytes());
  await (FontLoader('MaterialIcons')..addFont(Future.value(bytes))).load();
}

/// Procura um arquivo em material_fonts, dentro do cache do Flutter SDK.
File? _acharArtefato(String nome) {
  final candidatos = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final raiz?)
      '$raiz/bin/cache/artifacts/material_fonts/$nome',
    'build/unit_test_assets/fonts/$nome',
  ];

  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    candidatos.add('${dir.path}/material_fonts/$nome');
    candidatos.add('${dir.path}/artifacts/material_fonts/$nome');
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
      // maxLines entra na chave para a exceção poder ser declarada por
      // política ("corte de uma linha é design nesta tela") e não texto a
      // texto, que mudaria a cada Salmo novo no acervo.
      achados.add(Achado(
        TipoAchado.reticencias,
        'reticencias:maxLines=${ro.maxLines}:$amostra',
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
double? escalaDoPrimeiroOverflow(
  List<Resultado> resultados, {
  Set<String> truncamentoAceito = const {},
}) {
  final base = resultados.firstWhere((r) => r.escala == 1.0);
  for (final r in resultados.where((r) => r.escala != 1.0)) {
    final novos = r.novosSobre(base);
    final quebrou = novos.any((a) {
      switch (a.tipo) {
        // Estouro de layout: sempre reprova.
        case TipoAchado.overflow:
          return true;
        // Texto cortado também reprova. Antes só o overflow contava, e uma
        // mudança que picotasse "Enviar sugestão" ao meio passaria batida.
        // A exceção é declarada por tela, para o caso do corte ser decisão de
        // design (título de card com maxLines: 1, por exemplo).
        case TipoAchado.reticencias:
        case TipoAchado.corteHorizontal:
          return !truncamentoAceito.any(a.chave.contains);
      }
    });
    if (quebrou) return r.escala;
  }
  return null;
}
