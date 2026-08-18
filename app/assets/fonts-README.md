# Fontes empacotadas

Estas fontes vão **dentro do APK**. Não são material de teste.

## Por que empacotadas

O app é vendido como offline: a ficha da Play Store e o site dizem que funciona
sem internet depois de instalado. Antes disso, o `google_fonts` baixava
Playfair Display, Cormorant e Instrument Sans na primeira abertura. Quem
instalasse sem rede via o app inteiro na fonte do sistema, logo na primeira
impressão. O conteúdo funcionava; a identidade visual, não.

Com as fontes em `assets/fonts/` e `GoogleFonts.config.allowRuntimeFetching =
false` no `main.dart`, nada é buscado em rede.

## Como o google_fonts acha estes arquivos

Ele **não** lê o bloco `fonts:` do pubspec. Ele varre o `AssetManifest` e casa
pelo FIM do nome do arquivo com `Familia-Variante`
(`findFamilyWithVariantAssetPath`, google_fonts 8.1.0).

Consequência: **renomear qualquer arquivo aqui não dá erro de compilação** — a
família simplesmente volta a ser buscada na rede. É por isso que
`test/a11y/fontes_offline_test.dart` confere os nomes um a um.

## Variantes e por que cada uma existe

| Arquivo | Onde é usada |
|---|---|
| `PlayfairDisplay-Regular.ttf` | números de Salmo, títulos |
| `PlayfairDisplay-Italic.ttf` | horário do Salmo do dia, "O meu Salmo" |
| `PlayfairDisplay-MediumItalic.ttf` | compositor de imagem para compartilhar |
| `PlayfairDisplay-Bold.ttf` | título da primeira tela do onboarding |
| `Cormorant-Italic.ttf` | versículos |
| `InstrumentSans-Regular.ttf` | corpo de UI |
| `InstrumentSans-Italic.ttf` | "Narração em breve" na barra de áudio |
| `InstrumentSans-Medium.ttf` | rótulos e botões |

A lista veio de varrer as chamadas `GoogleFonts.*` de `lib/`. Peso novo no
código exige arquivo novo aqui, senão ele cai para a fonte do sistema.

## Licença

As três famílias são SIL Open Font License 1.1, que permite redistribuição
desde que o texto da licença acompanhe os arquivos. Como agora eles vão no
aparelho do usuário, os `OFL-*.txt` em `assets/fonts/` são **obrigatórios**,
não cortesia. O teste confere que os três estão lá.

## Por que este README está fora de `assets/fonts/`

Tudo que está dentro da pasta entra no APK. Documentação não precisa viajar
junto; as licenças, sim.
