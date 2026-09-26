import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salmos_app/core/apoio/apoio_prefs.dart';
import 'package:salmos_app/core/apoio/elegibilidade.dart';
import 'package:salmos_app/core/constants/app_constants.dart';

/// A regra de quando pedir avaliação e quando pedir apoio.
///
/// Existe porque a versão anterior não tinha regra nenhuma para auditar: o
/// pedido de avaliação era um `Future.delayed(10s)` dentro da tela de leitura e
/// aparecia no meio do Salmo, inclusive na coleção de Luto. Cada bloqueio abaixo
/// é um caso em que o app NÃO pode pedir nada, e cada um é testado sozinho —
/// senão um bloqueio quebrado fica escondido atrás de outro.
void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // Avaliação
  // ───────────────────────────────────────────────────────────────────────────

  group('avaliação', () {
    /// Estado em que a avaliação É devida. Cada teste piora UMA coisa.
    EstadoApoio ok() => const EstadoApoio(
          leiturasCompletas: 3,
          sessoes: 4,
          diasDeUso: 3,
        );

    ContextoGatilho evento() => const ContextoGatilho(leituraConcluida: true);

    test('3 leituras e 3 dias bastam', () {
      expect(Elegibilidade.decidir(estado: ok(), contexto: evento()),
          Gatilho.review);
    });

    test('a narração concluída também vale como evento', () {
      expect(
        Elegibilidade.decidir(
          estado: ok(),
          contexto: const ContextoGatilho(audioConcluido: true),
        ),
        Gatilho.review,
      );
    });

    test('sem leitura nem áudio concluído não pede nada', () {
      // O caso que o Future.delayed antigo ignorava: abrir e sair não é leitura.
      expect(
        Elegibilidade.decidir(estado: ok(), contexto: const ContextoGatilho()),
        Gatilho.nenhum,
      );
    });

    test('2 leituras ainda não', () {
      expect(
        Elegibilidade.decidir(
          estado: const EstadoApoio(leiturasCompletas: 2, diasDeUso: 30),
          contexto: evento(),
        ),
        Gatilho.nenhum,
      );
    });

    test('2 dias de uso ainda não', () {
      expect(
        Elegibilidade.decidir(
          estado: const EstadoApoio(leiturasCompletas: 30, diasDeUso: 2),
          contexto: evento(),
        ),
        Gatilho.nenhum,
      );
    });

    test('119 dias depois do último pedido, não; 120, sim', () {
      bool pede(int dias) => Elegibilidade.podeReview(
            estado: const EstadoApoio(
              leiturasCompletas: 10,
              diasDeUso: 200,
            ).comReview(dias),
            contexto: evento(),
          );
      expect(pede(119), isFalse);
      expect(pede(120), isTrue);
    });

    test('Luto, Ansiedade e Sono bloqueiam', () {
      expect(
        Elegibilidade.decidir(
          estado: ok(),
          contexto: const ContextoGatilho(
            leituraConcluida: true,
            contextoSensivel: true,
          ),
        ),
        Gatilho.nenhum,
      );
    });

    test('primeira sessão bloqueia', () {
      expect(
        Elegibilidade.decidir(
          estado: ok(),
          contexto: const ContextoGatilho(
            leituraConcluida: true,
            primeiraSessao: true,
          ),
        ),
        Gatilho.nenhum,
      );
    });

    test('sessão aberta pela notificação bloqueia', () {
      expect(
        Elegibilidade.decidir(
          estado: ok(),
          contexto: const ContextoGatilho(
            leituraConcluida: true,
            porNotificacao: true,
          ),
        ),
        Gatilho.nenhum,
      );
    });

    test('sheet de apoio na mesma sessão bloqueia', () {
      expect(
        Elegibilidade.decidir(
          estado: ok(),
          contexto: const ContextoGatilho(
            leituraConcluida: true,
            apoioNestaSessao: true,
          ),
        ),
        Gatilho.nenhum,
      );
    });

    test('13 dias depois do sheet, não; 14, sim', () {
      bool pede(int dias) => Elegibilidade.podeReview(
            estado: EstadoApoio(
              leiturasCompletas: 10,
              diasDeUso: 200,
              diasDesdeApoio: dias,
            ),
            contexto: evento(),
          );
      expect(pede(13), isFalse);
      expect(pede(14), isTrue);
    });

    test('quem apoiou continua podendo avaliar', () {
      // Apoiar cala o pedido de apoio, não o de avaliação: são coisas
      // diferentes, e quem apoiou é justamente quem tenderia a avaliar bem.
      expect(
        Elegibilidade.podeReview(
          estado: const EstadoApoio(
            leiturasCompletas: 10,
            diasDeUso: 60,
            apoiou: true,
            naoPerguntarMais: true,
          ),
          contexto: evento(),
        ),
        isTrue,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Sheet de apoio
  // ───────────────────────────────────────────────────────────────────────────

  group('sheet de apoio', () {
    /// Estado em que o sheet É devido, e a avaliação NÃO — senão a avaliação
    /// ganha por prioridade e o teste mediria a coisa errada.
    EstadoApoio ok() => const EstadoApoio(
          leiturasCompletas: 10,
          sessoes: 12,
          diasDeUso: 7,
          diasDesdeReview: 20,
        );

    ContextoGatilho evento() => const ContextoGatilho(leituraConcluida: true);

    test('7 dias e 10 leituras bastam', () {
      expect(Elegibilidade.decidir(estado: ok(), contexto: evento()),
          Gatilho.apoio);
    });

    test('a avaliação tem prioridade quando as duas se qualificam', () {
      expect(
        Elegibilidade.decidir(
          estado: const EstadoApoio(leiturasCompletas: 10, diasDeUso: 30),
          contexto: evento(),
        ),
        Gatilho.review,
      );
    });

    test('só a narração concluída não abre o sheet', () {
      // Ouvir com o telefone no bolso não é sinal de que a pessoa está com o app
      // na mão para decidir sobre dinheiro.
      expect(
        Elegibilidade.podeApoio(
          estado: ok(),
          contexto: const ContextoGatilho(audioConcluido: true),
        ),
        isFalse,
      );
    });

    test('9 leituras ainda não', () {
      expect(
        Elegibilidade.podeApoio(
          estado: const EstadoApoio(
            leiturasCompletas: 9,
            diasDeUso: 60,
            diasDesdeReview: 20,
          ),
          contexto: evento(),
        ),
        isFalse,
      );
    });

    test('6 dias de uso ainda não', () {
      expect(
        Elegibilidade.podeApoio(
          estado: const EstadoApoio(
            leiturasCompletas: 50,
            diasDeUso: 6,
            diasDesdeReview: 20,
          ),
          contexto: evento(),
        ),
        isFalse,
      );
    });

    test('a terceira exposição é a última da vida', () {
      bool pede(int exposicoes) => Elegibilidade.podeApoio(
            estado: EstadoApoio(
              leiturasCompletas: 50,
              diasDeUso: 400,
              diasDesdeReview: 20,
              exposicoesApoio: exposicoes,
              diasDesdeApoio: exposicoes == 0 ? null : 200,
            ),
            contexto: evento(),
          );
      expect(pede(2), isTrue);
      expect(pede(3), isFalse);
    });

    test('89 dias depois da última exibição, não; 90, sim', () {
      bool pede(int dias) => Elegibilidade.podeApoio(
            estado: EstadoApoio(
              leiturasCompletas: 50,
              diasDeUso: 400,
              diasDesdeReview: 20,
              exposicoesApoio: 1,
              diasDesdeApoio: dias,
            ),
            contexto: evento(),
          );
      expect(pede(89), isFalse);
      expect(pede(90), isTrue);
    });

    test('"Nem tanto" cala o sheet por 90 dias', () {
      bool pede(int dias) => Elegibilidade.podeApoio(
            estado: EstadoApoio(
              leiturasCompletas: 50,
              diasDeUso: 400,
              diasDesdeReview: 20,
              diasDesdeFeedback: dias,
            ),
            contexto: evento(),
          );
      expect(pede(89), isFalse);
      expect(pede(90), isTrue);
    });

    test('quem apoiou nunca mais vê o sheet', () {
      expect(
        Elegibilidade.podeApoio(
          estado: const EstadoApoio(
            leiturasCompletas: 999,
            diasDeUso: 9999,
            diasDesdeReview: 9999,
            apoiou: true,
          ),
          contexto: evento(),
        ),
        isFalse,
      );
    });

    test('"não perguntar de novo" é definitivo', () {
      expect(
        Elegibilidade.podeApoio(
          estado: const EstadoApoio(
            leiturasCompletas: 999,
            diasDeUso: 9999,
            diasDesdeReview: 9999,
            naoPerguntarMais: true,
          ),
          contexto: evento(),
        ),
        isFalse,
      );
    });

    test('coleção sensível, primeira sessão e notificação bloqueiam', () {
      for (final contexto in [
        const ContextoGatilho(leituraConcluida: true, contextoSensivel: true),
        const ContextoGatilho(leituraConcluida: true, primeiraSessao: true),
        const ContextoGatilho(leituraConcluida: true, porNotificacao: true),
      ]) {
        expect(
          Elegibilidade.podeApoio(estado: ok(), contexto: contexto),
          isFalse,
        );
      }
    });

    test('avaliação na mesma sessão bloqueia', () {
      expect(
        Elegibilidade.podeApoio(
          estado: ok(),
          contexto: const ContextoGatilho(
            leituraConcluida: true,
            reviewNestaSessao: true,
          ),
        ),
        isFalse,
      );
    });

    test('13 dias depois da avaliação, não; 14, sim', () {
      bool pede(int dias) => Elegibilidade.podeApoio(
            estado: EstadoApoio(
              leiturasCompletas: 50,
              diasDeUso: 400,
              diasDesdeReview: dias,
            ),
            contexto: evento(),
          );
      expect(pede(13), isFalse);
      expect(pede(14), isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Card da Home
  // ───────────────────────────────────────────────────────────────────────────

  group('card da Home', () {
    test('aparece no sétimo dia, não no sexto', () {
      expect(
        Elegibilidade.mostrarCard(const EstadoApoio(diasDeUso: 6)),
        isFalse,
      );
      expect(
        Elegibilidade.mostrarCard(const EstadoApoio(diasDeUso: 7)),
        isTrue,
      );
    });

    test('o X esconde por 90 dias', () {
      expect(
        Elegibilidade.mostrarCard(
          const EstadoApoio(diasDeUso: 100, diasDesdeDispensaCard: 89),
        ),
        isFalse,
      );
      expect(
        Elegibilidade.mostrarCard(
          const EstadoApoio(diasDeUso: 100, diasDesdeDispensaCard: 90),
        ),
        isTrue,
      );
    });

    test('quem apoiou ou pediu para não perguntar nunca mais vê', () {
      expect(
        Elegibilidade.mostrarCard(
            const EstadoApoio(diasDeUso: 999, apoiou: true)),
        isFalse,
      );
      expect(
        Elegibilidade.mostrarCard(
            const EstadoApoio(diasDeUso: 999, naoPerguntarMais: true)),
        isFalse,
      );
    });

    test('"Nem tanto" também cala o card', () {
      // O silêncio vale para as duas superfícies: reencontrar o pedido no dia
      // seguinte em outro formato é a mesma insistência com outra roupa.
      expect(
        Elegibilidade.mostrarCard(
          const EstadoApoio(diasDeUso: 100, diasDesdeFeedback: 10),
        ),
        isFalse,
      );
    });

    test('o card não depende de leitura nem de sessão', () {
      // Ele não interrompe nada: fica parado abaixo do conteúdo.
      expect(
        Elegibilidade.mostrarCard(const EstadoApoio(diasDeUso: 7, sessoes: 1)),
        isTrue,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // A ponte com o disco
  // ───────────────────────────────────────────────────────────────────────────

  group('ApoioPrefs', () {
    test('prefs vazias: nada é devido e nada estoura', () async {
      SharedPreferences.setMockInitialValues({});
      final estado = await ApoioPrefs.ler();

      expect(estado.leiturasCompletas, 0);
      expect(estado.diasDeUso, 0);
      expect(estado.diasDesdeReview, isNull);
      expect(estado.exposicoesApoio, 0);
      expect(estado.apoiou, isFalse);
      expect(Elegibilidade.mostrarCard(estado), isFalse);
      expect(
        Elegibilidade.decidir(
          estado: estado,
          contexto: const ContextoGatilho(leituraConcluida: true),
        ),
        Gatilho.nenhum,
      );
    });

    test('a primeira sessão é a de número 1 e grava a data de instalação',
        () async {
      SharedPreferences.setMockInitialValues({});
      expect(await ApoioPrefs.registrarSessao(), 1);
      expect(await ApoioPrefs.registrarSessao(), 2);

      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefPrimeiraAberturaMs), isNotNull);
    });

    test('a data de instalação não é reescrita na segunda abertura', () async {
      // Se fosse, diasDeUso voltaria a zero toda vez e nem o card nem o sheet
      // apareceriam nunca.
      final ontem = DateTime.now()
          .subtract(const Duration(days: 8))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: ontem,
      });
      await ApoioPrefs.registrarSessao();

      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefPrimeiraAberturaMs), ontem);
      expect((await ApoioPrefs.ler()).diasDeUso, 8);
    });

    test('o contador de leituras soma e chega na regra', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(4),
      });
      for (var i = 0; i < 3; i++) {
        await ApoioPrefs.somarLeitura();
      }

      final estado = await ApoioPrefs.ler();
      expect(estado.leiturasCompletas, 3);
      expect(
        Elegibilidade.decidir(
          estado: estado,
          contexto: const ContextoGatilho(leituraConcluida: true),
        ),
        Gatilho.review,
      );
    });

    test('MIGRAÇÃO: quem já viu o prompt antigo espera os 120 dias', () async {
      // O gate antigo era um booleano sem data. Lido como "pediu agora", a
      // atualização do app não vira um segundo pedido no mesmo dia.
      SharedPreferences.setMockInitialValues({
        AppConstants.prefReviewRequested: true,
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(60),
        AppConstants.prefLeiturasCompletas: 30,
      });

      final estado = await ApoioPrefs.ler();
      expect(estado.diasDesdeReview, 0);
      expect(
        Elegibilidade.podeReview(
          estado: estado,
          contexto: const ContextoGatilho(leituraConcluida: true),
        ),
        isFalse,
      );

      // E a data gravada persiste, senão a migração se repetiria para sempre.
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(AppConstants.prefReviewPedidoMs), isNotNull);
    });

    test('relógio do aparelho para trás não vira trava dobrada', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefReviewPedidoMs:
            DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
      });
      expect((await ApoioPrefs.ler()).diasDesdeReview, 0);
    });

    test('três exposições do sheet esgotam a cota', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(400),
        AppConstants.prefLeiturasCompletas: 50,
      });
      expect(await ApoioPrefs.marcarApoioMostrado(), 1);
      expect(await ApoioPrefs.marcarApoioMostrado(), 2);
      expect(await ApoioPrefs.marcarApoioMostrado(), 3);

      final estado = await ApoioPrefs.ler();
      expect(estado.exposicoesApoio, 3);
      expect(
        Elegibilidade.podeApoio(
          estado: estado,
          contexto: const ContextoGatilho(leituraConcluida: true),
        ),
        isFalse,
      );
    });

    test('apoiar e dispensar o card ficam gravados', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefPrimeiraAberturaMs: _diasAtras(30),
      });
      expect(Elegibilidade.mostrarCard(await ApoioPrefs.ler()), isTrue);

      await ApoioPrefs.marcarCardDispensado();
      expect(Elegibilidade.mostrarCard(await ApoioPrefs.ler()), isFalse);

      await ApoioPrefs.marcarApoiou();
      expect((await ApoioPrefs.ler()).apoiou, isTrue);
    });
  });
}

int _diasAtras(int dias) =>
    DateTime.now().subtract(Duration(days: dias)).millisecondsSinceEpoch;

extension on EstadoApoio {
  /// Cópia com outro `diasDesdeReview`. Só para deixar os testes legíveis.
  EstadoApoio comReview(int dias) => EstadoApoio(
        leiturasCompletas: leiturasCompletas,
        sessoes: sessoes,
        diasDeUso: diasDeUso,
        diasDesdeReview: dias,
        exposicoesApoio: exposicoesApoio,
        diasDesdeApoio: diasDesdeApoio,
        diasDesdeFeedback: diasDesdeFeedback,
        diasDesdeDispensaCard: diasDesdeDispensaCard,
        apoiou: apoiou,
        naoPerguntarMais: naoPerguntarMais,
      );
}
