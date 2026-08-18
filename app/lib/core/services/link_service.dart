import 'package:url_launcher/url_launcher.dart';

/// Abertura de links externos (e-mail, política de privacidade).
///
/// Existe como serviço, e não como chamada solta dentro da tela, por dois
/// motivos: as telas não precisam conhecer o url_launcher, e o teste consegue
/// trocar [instance] para verificar que o toque realmente tenta abrir algo.
/// Sem essa costura, "tocar no botão" e "o botão está morto" são
/// indistinguíveis para a suíte.
class LinkService {
  LinkService();

  /// Trocável em teste. Em produção nunca é reatribuído.
  static LinkService instance = LinkService();

  /// Devolve `false` quando nenhum app do aparelho sabe abrir a URI.
  Future<bool> abrir(Uri uri, {bool externo = false}) async {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(
      uri,
      mode: externo ? LaunchMode.externalApplication : LaunchMode.platformDefault,
    );
  }
}
