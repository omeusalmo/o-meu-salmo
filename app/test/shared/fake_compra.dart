import 'package:salmos_app/core/apoio/compra_service.dart';
import 'package:salmos_app/core/apoio/loja_apoio.dart';

/// Loja falsa. O `in_app_purchase` real não sobe sob `flutter test` (sem plugin
/// nativo), e mesmo com plugin dependeria dos produtos existirem na Play
/// Console — que é justamente o que ainda não existe.
///
/// Os preços vêm daqui do mesmo jeito que viriam de
/// `ProductDetails.formattedPrice`: como texto pronto da loja. Se algum dia
/// alguém escrever "R$ 10" dentro de um widget, o teste que compara o rótulo do
/// botão com este texto quebra.
class FakeCompraApoio implements CompraApoio {
  FakeCompraApoio({
    this.lista = const [
      ProdutoApoio(id: 'apoio_5', precoFormatado: 'R\$ 5,00', precoBruto: 5),
      ProdutoApoio(id: 'apoio_10', precoFormatado: 'R\$ 10,00', precoBruto: 10),
      ProdutoApoio(id: 'apoio_25', precoFormatado: 'R\$ 25,00', precoBruto: 25),
    ],
    this.resultado = const ResultadoCompra(ResultadoApoio.concluido),
  });

  /// Vazia simula produtos não publicados / Play indisponível.
  final List<ProdutoApoio> lista;
  final ResultadoCompra resultado;

  final List<String> comprados = [];
  bool descartada = false;

  @override
  Future<List<ProdutoApoio>> produtos() async => lista;

  @override
  Future<ResultadoCompra> comprar(ProdutoApoio produto) async {
    comprados.add(produto.id);
    return resultado;
  }

  @override
  void dispose() => descartada = true;
}

/// Liga a loja falsa no [LojaApoio.instance] — é o que faz as entradas de apoio
/// aparecerem em teste.
///
/// Sem isto a consulta cai no Google Play real, que não sobe sob `flutter test`,
/// e todas as entradas de apoio ficam escondidas. Isso NÃO é bug do teste: é o
/// comportamento de produção enquanto os produtos não estiverem ativos na Play
/// Console. Todo teste que espera ver card, linha de Ajustes ou sheet chama isto
/// primeiro.
///
/// Instância nova a cada chamada porque [LojaApoio] guarda a resposta em cache
/// por processo, e o cache de um teste não pode vazar para o seguinte.
void ligarLojaFalsa({List<ProdutoApoio>? produtos}) {
  LojaApoio.instance = LojaApoio(
    criar: () => produtos == null
        ? FakeCompraApoio()
        : FakeCompraApoio(lista: produtos),
  );
}

/// Loja que não responde: produtos vazios. Toda entrada de apoio some.
void ligarLojaVazia() => ligarLojaFalsa(produtos: const []);

/// Volta ao Play real (indisponível em teste). Usar em tearDown.
void desligarLojaFalsa() => LojaApoio.instance = LojaApoio();
