/// Camada de acesso a funcionalidades — stub preparado para monetização futura.
///
/// Quando implementar o plano premium, substitua canAccess() pela verificação
/// real de compra (ex.: pacote in_app_purchase) sem alterar os call sites:
/// todos os lugares que já chamam Entitlements.instance.canAccess() passam
/// a respeitar o paywall automaticamente.
enum AppFeature {
  audioPlayback,
  imageCompositor,
  extraCollections,
  offlineDownload,
}

class Entitlements {
  const Entitlements._();

  static const Entitlements instance = Entitlements._();

  /// Sempre true enquanto o paywall não está ativo.
  bool canAccess(AppFeature feature) => true;
}
