# Play Store — Assets

Pasta raiz de todos os assets de loja do O meu Salmo.

> **Pasta de upload:** `export/` é o bundle final pronto para o Google Play Console.
> Tudo que sobe pra ficha do app está lá. O resto são fontes / arquivos de trabalho.

---

## Estrutura

```
play-store/
├── README.md                          ← este arquivo
├── export/                            ★ BUNDLE DE UPLOAD (subir tudo daqui)
│   ├── icon-512.png                   ← ícone hi-res 512×512, sem alpha
│   ├── feature-graphic.png            ← 1024×500
│   ├── s1-colecoes.png                ← screenshots finais 1080×1920
│   ├── s2-home.png
│   ├── s3-leitura.png
│   ├── s4-reflexao.png
│   ├── s5-colecao.png
│   ├── s6-favoritos.png
│   └── s7-respirar.png
├── listing/
│   ├── aso-copy.md                    ★ textos da loja (título, descrições, tags)
│   └── estrategia-screenshots.md      ← copy de cada tela (agente marketing)
├── feature-graphic/
│   └── feature-graphic.html           ← fonte HTML do feature graphic
└── screenshots/
    ├── raw/                           ← capturas diretas do app (trabalho)
    ├── raw-cropped/                   ← raw sem status bar (1080×2310)
    └── final/                         ← frames HTML → fonte das PNGs em export/
        ├── template-screenshot.html   ← template base
        └── s1…s7-*.html
```

**Bundle de upload** = tudo em `export/` + textos em `listing/aso-copy.md`  
**Fontes** = HTML em `final/` e `feature-graphic/` (geram as PNGs de `export/`)  
**Trabalho** = PNGs em `raw/`, template base, este README

> Ícone fonte: `o-meu-salmo-design/assets/app-icon-512.png` (com alpha).
> `export/icon-512.png` é a versão achatada (fundo cobalt sólido) que o Play exige.

---

## Ordem de upload dos screenshots (jornada emocional)

Play destaca as 2-3 primeiras. Subir nesta ordem:

`s2-home` → `s7-respirar` → `s1-colecoes` → `s5-colecao` → `s3-leitura` → `s4-reflexao` → `s6-favoritos`

---

## Como gerar um frame final

### 1. Criar o arquivo HTML do frame

Duplique `screenshots/final/template-screenshot.html` e renomeie:

```
cp template-screenshot.html 01-home-frame.html
```

Edite no novo arquivo:

| Campo | Onde editar |
|---|---|
| Screenshot | `<img src="../raw/01-home.png">` |
| Eyebrow label | `<span class="eyebrow">` — texto depois do `accent-dot` |
| Headline | `<h1 class="headline">` |
| Subheadline | `<p class="subheadline">` |
| Posição do texto | classe `layout-top` ou `layout-bottom` no `.text-block` |

O copy de cada tela está em `listing/estrategia-screenshots.md`.

### 2. Tirar o screenshot final (1080×1920 px)

**Opção A — Chrome DevTools:**
1. Abra o HTML no Chrome
2. DevTools → `Ctrl+Shift+P` → "Capture screenshot"
3. Ou: Device Toolbar → 1080×1920 → "Capture full size screenshot"

**Opção B — pageres (Node CLI):**
```bash
npx pageres 01-home-frame.html 1080x1920 --filename="01-home-final"
```

**Opção C — Puppeteer (script):**
```js
await page.setViewport({ width: 1080, height: 1920 });
await page.screenshot({ path: '01-home-final.png', fullPage: false });
```

### 3. Nomear o arquivo final

Padrão: `NN-nome-final.png` (ex: `01-home-final.png`)  
Upload direto no Google Play Console → Ficha do app → Gráficos.

---

## Feature Graphic

Arquivo: `feature-graphic/feature-graphic.html`  
Dimensão: **1024×500 px**

Screenshot via Chrome DevTools ou:
```bash
npx pageres feature-graphic/feature-graphic.html 1024x500 --filename="feature-graphic-final"
```

---

## Tokens de design usados

Fonte da verdade: `o-meu-salmo-design/design-system.html`

| Token | Valor |
|---|---|
| night-base (fundo) | `#080B1C` |
| night-plus (superfície) | `#10142C` |
| cobalt-500 (acento) | `#2A47DD` |
| cobalt-400 (acento escuro) | `#5567EA` |
| night-cream (título) | `#EEF0FC` |
| night-text (subtítulo) | `#8C97D4` |
| night-muted (eyebrow) | `#7080C8` |
| Fonte display | Playfair Display |
| Fonte UI/eyebrow | Instrument Sans |

---

## Referências

- Copy de cada tela → `listing/estrategia-screenshots.md` (agente marketing)
- Design System → `o-meu-salmo-design/design-system.html`
- Briefing de marca → `assets/meu-salmo-brand-briefing.md`
