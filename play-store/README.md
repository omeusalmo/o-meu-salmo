# Play Store — Assets

Pasta raiz de todos os assets de loja do O meu Salmo.

---

## Estrutura

```
play-store/
├── README.md                          ← este arquivo
├── feature-graphic/
│   └── feature-graphic.html           ★ ENTREGÁVEL — 1024×500px
├── screenshots/
│   ├── raw/                           ← capturas diretas do app (arquivos de trabalho)
│   │   ├── 01-home.png
│   │   ├── 02-colecoes.png
│   │   ├── 03-colecao-detalhe.png
│   │   ├── 04-leitura-salmo.png
│   │   ├── 05-reflexao.png
│   │   ├── 06-todos-salmos.png
│   │   ├── 07-favoritos.png
│   │   └── 08-ajustes.png
│   ├── raw-cropped/                   ← raw sem a status bar (1080×2310)
│   └── final/                         ← frames HTML prontos para screenshot final
│       ├── template-screenshot.html   ← template base (arquivo de trabalho)
│       └── s1…s7-*.html               ★ ENTREGÁVEIS (s7-respirar é da V2)
├── export/                            ← PNGs finais (1080×1920 + feature graphic)
└── listing/
    └── estrategia-screenshots.md      ← copy de cada tela (criado pelo agente marketing)
```

**Entregáveis finais** = arquivos `.html` na pasta `final/` e `feature-graphic/`  
**Arquivos de trabalho** = PNGs em `raw/`, template base, este README

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
