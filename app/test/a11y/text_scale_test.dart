import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/constants/app_constants.dart';
import 'package:salmos_app/features/ajustes/ajustes_screen.dart';
import 'package:salmos_app/features/colecoes/colecoes_screen.dart';
import 'package:salmos_app/features/colecoes/detalhe_colecao_screen.dart';
import 'package:salmos_app/features/favoritos/favoritos_screen.dart';
import 'package:salmos_app/features/home/home_screen.dart';
import 'package:salmos_app/features/onboarding/onboarding_screen.dart';
import 'package:salmos_app/features/salmos/leitura_salmo_screen.dart';
import 'package:salmos_app/features/salmos/todos_salmos_screen.dart';
import 'package:salmos_app/shared/widgets/psalm_card.dart';
import 'package:salmos_app/shared/widgets/verse_line.dart';

import 'text_scale_harness.dart';

/// Auditoria de acessibilidade: como cada tela se comporta quando o usuário
/// aumenta a fonte no Android.
///
/// Hoje `main.dart:88` limita a ampliação a 1.3x. O público do app tem 60–75
/// anos e costuma pedir 1.5x ou 2.0x no sistema — a Samsung chega a "Enorme".
/// Esta suíte renderiza as telas SEM esse teto para responder duas perguntas:
/// o teto ainda é necessário, e o que custaria removê-lo?
///
/// O relatório impresso no output do `flutter test` é o entregável. Os `expect`
/// abaixo apenas travam o que já está garantido, para não regredir.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await carregarFontesReais();
    await SalmosFixture.aquecer();
  });

  setUp(() {
    // Seed e dia de instalação fixos: sem isso o Salmo do Dia é sorteado a cada
    // execução e o relatório muda de um dia para o outro.
    final hoje = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    SharedPreferences.setMockInitialValues({
      AppConstants.prefFavoritosKey: ['1', '23', '105'],
      AppConstants.prefUnlockedPsalms: ['23'],
      AppConstants.prefNotificationEnabled: true,
      AppConstants.prefNotificationHour: 8,
      AppConstants.prefNotificationMinute: 0,
      AppConstants.prefUserSeed: 20260816,
      AppConstants.prefInstallDay: hoje,
    });
  });

  test('pré-requisito: fonte proporcional real carregada', () {
    expect(
      fontesReais,
      isTrue,
      reason: 'Sem fonte real as larguras saem infladas e o relatório mente. '
          'Verifique material_fonts/Roboto-Regular.ttf no cache do Flutter.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Telas sem rolagem — onde o aumento de fonte realmente estoura layout
  // ───────────────────────────────────────────────────────────────────────────

  // Telas 1 e 2 não rolam e não aguentariam 2.0x sozinhas; elas se protegem
  // com MediaQuery.withClampedTextScaling(1.3) dentro do próprio onboarding.
  // O teste renderiza a tela inteira, então mede essa proteção funcionando.
  _auditar(
    'Onboarding 1 — boas-vindas',
    (_) => const OnboardingScreen(),
    tetoSemOverflow: 2.0,
  );

  _auditar(
    'Onboarding 2 — como funciona',
    (_) => const OnboardingScreen(),
    depois: (t) => _irParaPagina(t, 1),
    tetoSemOverflow: 2.0,
  );

  _auditar(
    'Onboarding 3 — grid emocional',
    (_) => const OnboardingScreen(),
    depois: (t) => _irParaPagina(t, 2),
    tetoSemOverflow: 2.0,
  );

  _auditar(
    'Onboarding 4 — consentimento',
    (_) => const OnboardingScreen(),
    depois: (t) => _irParaPagina(t, 3),
    tetoSemOverflow: 2.0,
  );

  // ───────────────────────────────────────────────────────────────────────────
  // Telas de conteúdo
  // ───────────────────────────────────────────────────────────────────────────

  _auditar('Home — Salmo do Dia', (_) => const HomeScreen(),
      tetoSemOverflow: 2.0);

  _auditar('Coleções — lista', (_) => const ColecoesScreen(),
      tetoSemOverflow: 2.0);

  // "luto" tem o subtítulo mais longo das 8 coleções.
  _auditar(
    'Detalhe da coleção — Luto',
    (_) => const DetalheColecaoScreen(colecaoId: 'luto'),
    tetoSemOverflow: 2.0,
  );

  // Salmo 105: título mais longo do acervo (43 caracteres) e número de 3 dígitos.
  _auditar(
    'Leitura — Salmo 105',
    (_) => const LeituraSalmoScreen(numero: 105),
    tetoSemOverflow: 2.0,
  );

  _auditar('Leitura — Salmo 23', (_) => const LeituraSalmoScreen(numero: 23),
      tetoSemOverflow: 2.0);

  _auditar('Todos os Salmos — busca', (_) => const TodosSalmosScreen(),
      tetoSemOverflow: 2.0);

  _auditar('Favoritos', (_) => const FavoritosScreen(), tetoSemOverflow: 2.0);

  _auditar('Ajustes', (_) => const AjustesScreen(), tetoSemOverflow: 2.0);

  // ───────────────────────────────────────────────────────────────────────────
  // Tela pequena — 320dp ainda existe na base Android brasileira e é onde a
  // fonte grande aperta primeiro.
  // ───────────────────────────────────────────────────────────────────────────

  _auditar(
    'Home em tela pequena (320dp)',
    (_) => const HomeScreen(),
    tamanho: kTelaPequena,
    tetoSemOverflow: 2.0,
  );

  _auditar(
    'Onboarding 1 em tela pequena (320dp)',
    (_) => const OnboardingScreen(),
    tamanho: kTelaPequena,
    tetoSemOverflow: 2.0,
  );

  // ───────────────────────────────────────────────────────────────────────────
  // Componentes com largura travada em pixels
  //
  // A caixa não cresce com a fonte, então a partir de certa escala o texto é
  // cortado sem nenhum aviso: o usuário vê "10" onde deveria ler "105".
  // ───────────────────────────────────────────────────────────────────────────

  // ───────────────────────────────────────────────────────────────────────────
  // Cromo de navegação: barra inferior e AppBar têm altura fixa por
  // especificação do Material, e é onde o texto grande costuma sumir.
  // ───────────────────────────────────────────────────────────────────────────

  group('cromo de navegação', () {
    testWidgets('barra inferior (NavigationBar de MainShell)', (tester) async {
      final resultados = <Resultado>[];
      for (final escala in kEscalas) {
        resultados.add(await renderizar(
          tester,
          Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.wb_sunny_outlined), label: 'Início'),
                NavigationDestination(
                    icon: Icon(Icons.collections_bookmark_outlined),
                    label: 'Coleções'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined), label: 'Salmos'),
                NavigationDestination(
                    icon: Icon(Icons.favorite_border), label: 'Favoritos'),
              ],
            ),
          ),
          nome: 'NavigationBar',
          escala: escala,
        ));
      }
      relatar('Barra de navegação inferior', resultados);

      expect(
        escalaDoPrimeiroOverflow(resultados),
        isNull,
        reason: 'A barra inferior aparece em 4 das 5 telas principais; '
            'se ela estourar, o app parece quebrado em todo lugar.',
      );
    });

    testWidgets('AppBar de Coleções cabe no toolbarHeight de 64',
        (tester) async {
      // colecoes_screen.dart:29 fixa toolbarHeight em 64 com título Playfair 24.
      final alturas = <double, double>{};
      for (final escala in kEscalas) {
        await renderizar(
          tester,
          const ColecoesScreen(),
          nome: 'AppBar Coleções',
          escala: escala,
        );
        alturas[escala] = tester
            .renderObject<RenderBox>(find.descendant(
              of: find.byType(AppBar),
              matching: find.text('Coleções'),
            ))
            .size
            .height;
      }
      debugPrint('\n┌── AppBar Coleções (toolbarHeight fixo em 64px)\n'
          '${alturas.entries.map((e) => '│ ${e.key}x  título com '
              '${e.value.toStringAsFixed(1)}px de altura').join('\n')}\n└──');

      // Prova que o textScaler do harness chega até aqui: se não chegasse,
      // todas as alturas seriam iguais e o teste abaixo passaria à toa.
      expect(alturas[2.0]!, greaterThan(alturas[1.0]!),
          reason: 'O aumento de fonte não está sendo aplicado à AppBar.');

      for (final e in alturas.entries) {
        expect(e.value, lessThanOrEqualTo(64.0),
            reason: 'Em ${e.key}x o título "Coleções" ocupa '
                '${e.value.toStringAsFixed(1)}px numa barra de 64px.');
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Regressão: calhas de número e de rótulo
  //
  // Estas três caixas já tiveram largura travada em pixels e cortavam texto a
  // partir de 1.3x, ou seja, em produção. Se alguém reintroduzir um
  // SizedBox(width: ...) no lugar da reserva que acompanha a fonte, estes
  // testes falham.
  // ───────────────────────────────────────────────────────────────────────────

  group('calhas que precisam acompanhar a fonte', () {
    testWidgets('PsalmCard nunca corta número de 3 dígitos', (tester) async {
      // 51 dos 150 Salmos têm número >= 100. O 105 ainda tem o título mais
      // longo do acervo, então é o pior caso do card inteiro.
      final quebra = await _menorEscalaComCorte(
        tester,
        nome: 'PsalmCard 105',
        tela: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PsalmCard(
            numero: 105,
            titulo: 'As Maravilhas de Deus na História de Israel',
            snippet: 'Dai graças ao Senhor; invocai o seu nome.',
            onTap: () {},
          ),
        ),
        textoAlvo: '105',
      );

      expect(quebra, isNull,
          reason: 'O número do Salmo voltou a ser cortado em ${quebra}x. '
              'A calha de psalm_card.dart precisa de largura MÍNIMA que '
              'acompanhe a fonte, não largura fixa.');
    });

    testWidgets('VerseLine nunca corta versículo de 3 dígitos',
        (tester) async {
      // O Salmo 119 vai até o versículo 176 — único do acervo acima de 100.
      final quebra = await _menorEscalaComCorte(
        tester,
        nome: 'VerseLine 176',
        tela: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: VerseLine(
            numero: 176,
            texto: 'Desgarrei-me como a ovelha perdida; busca o teu servo, '
                'pois não me esqueci dos teus mandamentos.',
          ),
        ),
        textoAlvo: '176',
      );

      expect(quebra, isNull,
          reason: 'O número do versículo voltou a ser cortado em ${quebra}x. '
              'Ver verse_line.dart.');
    });

    testWidgets('PsalmCard mantém os títulos alinhados entre 1, 2 e 3 dígitos',
        (tester) async {
      // A largura fixa antiga existia para isto: numa lista com Salmos de 1, 2
      // e 3 dígitos, os títulos precisam começar todos na mesma coluna, senão a
      // lista fica torta. A reserva mínima que acompanha a fonte tem de manter
      // essa propriedade em qualquer escala.
      for (final escala in kEscalas) {
        await renderizar(
          tester,
          const _TresCards(),
          nome: 'PsalmCard alinhamento',
          escala: escala,
        );

        final xs = ['Um', 'Vinte e três', 'Cento e cinco']
            .map((t) => tester.getTopLeft(find.text(t)).dx)
            .toSet();

        expect(xs, hasLength(1),
            reason: 'Em ${escala}x os títulos começam em colunas diferentes '
                '($xs). A calha do número deixou de ser uniforme.');
      }
    });

    testWidgets('Ajustes nunca corta o rótulo "Tradução"', (tester) async {
      final resultados = <Resultado>[];
      for (final escala in kEscalas) {
        resultados.add(await renderizar(
          tester,
          const AjustesScreen(),
          nome: 'Ajustes — rótulos de Sobre',
          escala: escala,
        ));
      }

      final cortados = resultados
          .where((r) => r.doTipo(TipoAchado.corteHorizontal).any(
              (a) => a.chave == 'corte:Tradução' || a.chave == 'corte:Versão'))
          .map((r) => r.escala)
          .toList();

      expect(cortados, isEmpty,
          reason: 'Rótulo cortado em $cortados. A coluna de _InfoRow em '
              'ajustes_screen.dart precisa de largura mínima que acompanhe a '
              'fonte, não largura fixa.');
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────

/// Roda a mesma tela nas quatro escalas, imprime o relatório e trava o contrato.
///
/// [tetoSemOverflow] é a maior escala em que a tela HOJE não estoura layout.
/// O teste falha se a tela piorar (regressão) — e também se melhorar sem que
/// alguém atualize este número, o que mantém o relatório honesto.
void _auditar(
  String nome,
  Widget Function(WidgetTester) construir, {
  Future<void> Function(WidgetTester)? depois,
  Size tamanho = kTelaTipica,
  required double tetoSemOverflow,
}) {
  testWidgets(nome, (tester) async {
    final resultados = <Resultado>[];
    for (final escala in kEscalas) {
      resultados.add(await renderizar(
        tester,
        construir(tester),
        nome: nome,
        escala: escala,
        tamanho: tamanho,
        depoisDeRenderizar: depois,
      ));
    }
    relatar(nome, resultados);

    final quebrou = escalaDoPrimeiroOverflow(resultados);
    final observado = quebrou == null
        ? kEscalas.last
        : kEscalas[kEscalas.indexOf(quebrou) - 1];

    expect(
      observado,
      tetoSemOverflow,
      reason: 'A tela "$nome" aguenta hoje até ${observado}x sem estourar '
          'layout, mas o teste esperava ${tetoSemOverflow}x. '
          'Veja o relatório impresso acima.',
    );

    // O teto que o app aplica hoje (1.3x) tem de estar sempre coberto —
    // isto protege o que já está publicado na Play Store.
    expect(
      observado,
      greaterThanOrEqualTo(kTetoAtual),
      reason: 'Regressão dentro do teto vigente de ${kTetoAtual}x em "$nome".',
    );
  });
}

/// Três cards de Salmo com 1, 2 e 3 dígitos, como aparecem numa lista real.
class _TresCards extends StatelessWidget {
  const _TresCards();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PsalmCard(
                numero: 1, titulo: 'Um', snippet: 'a', onTap: () {}),
            PsalmCard(
                numero: 23, titulo: 'Vinte e três', snippet: 'b', onTap: () {}),
            PsalmCard(
                numero: 105,
                titulo: 'Cento e cinco',
                snippet: 'c',
                onTap: () {}),
          ],
        ),
      );
}

/// Menor escala em que [textoAlvo] passa a ser cortado na horizontal dentro de
/// [tela]. Devolve `null` se aguentar todas as escalas testadas.
Future<double?> _menorEscalaComCorte(
  WidgetTester tester, {
  required String nome,
  required Widget tela,
  required String textoAlvo,
}) async {
  final resultados = <Resultado>[];
  for (final escala in kEscalas) {
    resultados.add(await renderizar(
      tester,
      Scaffold(body: Center(child: tela)),
      nome: nome,
      escala: escala,
    ));
  }
  relatar(nome, resultados);

  for (final r in resultados) {
    final cortou = r
        .doTipo(TipoAchado.corteHorizontal)
        .any((a) => a.chave == 'corte:$textoAlvo');
    if (cortou) return r.escala;
  }
  return null;
}

/// Salta o PageView do onboarding direto para [pagina].
///
/// Tocar no botão não serve: em 2.0x o botão da primeira tela é empurrado para
/// fora da área visível e o toque não chega nele — que, aliás, é justamente um
/// dos achados. Saltar pelo controller isola a medição desse efeito.
Future<void> _irParaPagina(WidgetTester tester, int pagina) async {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  pageView.controller!.jumpToPage(pagina);
  await tester.pump();
}
