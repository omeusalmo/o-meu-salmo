import 'compra_service.dart';

/// A loja tem produto de apoio para vender?
///
/// Existe por um motivo de publicação: os produtos `apoio_5/10/25` só ficam
/// ativos na Play Console num momento que não é o do build. Enquanto não
/// estiverem, toda entrada de apoio terminaria no estado de erro — e o Jeff não
/// poderia publicar nenhuma atualização sem levar alguém a um beco.
///
/// Com isto, as entradas simplesmente não aparecem: o card da Home, a linha
/// "Apoiar o app" em Ajustes e o sheet do gatilho. "Avaliar na Play Store" não
/// passa por aqui — não depende de produto.
///
/// ⚠️ A consulta é assíncrona e o padrão é ESCONDER. Estado desconhecido conta
/// como indisponível, senão a entrada apareceria e piscaria fora da tela meio
/// segundo depois.
class LojaApoio {
  LojaApoio({CompraApoio Function()? criar})
      : _criar = criar ?? CompraApoioPlay.new;

  final CompraApoio Function() _criar;

  /// Trocável em teste (mesmo padrão de ApoioService/ReviewService).
  static LojaApoio instance = LojaApoio();

  /// Uma consulta por processo, compartilhada por todos os que perguntarem
  /// junto. A resposta não muda no meio de uma sessão: produto publicado no
  /// meio do uso aparece na próxima abertura, o que é bom o bastante.
  Future<bool>? _consulta;

  Future<bool> disponivel() => _consulta ??= _consultar();

  Future<bool> _consultar() async {
    final loja = _criar();
    try {
      return (await loja.produtos()).isNotEmpty;
    } catch (_) {
      // Sem plugin nativo, sem Play Services, sem rede: indisponível.
      return false;
    } finally {
      // Hoje isto só solta uma compra em curso (que nunca há aqui): a assinatura
      // do `purchaseStream` mora em `ApoioBilling`, um por processo, e não no
      // objeto que este método cria e joga fora. Antes não era assim — este
      // `dispose()` cancelava a assinatura global, e podia derrubar a drenagem
      // de abertura no meio, junto com qualquer compra que estivesse chegando.
      loja.dispose();
    }
  }

  /// Só para teste — descarta a resposta em cache.
  void esquecer() => _consulta = null;
}
