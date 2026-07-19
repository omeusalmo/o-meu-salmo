# Instagram — O meu Salmo

> **Pra postar: abre `fila-de-postagem/` e segue a numeração.** Cada post tem a imagem
> (ou pasta com fundo+áudio) e a legenda `.txt` do lado. Copia, cola, publica.
> Estratégia completa: `marketing/estrategia-instagram.md`.

## Estrutura

```
instagram/
├── fila-de-postagem/        ★ USAR — posts prontos na ordem do calendário
│   ├── 00-pin-carrossel-app/                 (PRIMEIRO POST — apresenta o app; fixar no perfil)
│   ├── 01-dom-card-esperanca.png + .txt      (Semana 1, domingo · LIGHT)
│   ├── 02-qua-reel-salmo-23/                 (Semana 1, quarta: fundo + áudio + legenda → montar no CapCut)
│   ├── 03-sex-card-ansiedade.png + .txt      (Semana 1, sexta)
│   ├── 04-dom-card-sono.png + .txt           (Semana 2, domingo)
│   ├── 05-qua-carrossel-ansiedade/           (Semana 2, quarta: 7 slides na ordem + legenda)
│   ├── 06-sex-card-gratidao.png + .txt       (Semana 2, sexta · LIGHT)
│   ├── 07-dom-card-perdao.png + .txt         (Semana 3, domingo)
│   ├── 08-qua-reel-salmo-121/                (Semana 3, quarta: CapCut)
│   ├── 09-sex-card-louvor.png + .txt         (Semana 3, sexta · LIGHT)
│   └── 10-dom-card-protecao.png + .txt       (Semana 4, domingo)
├── semana-1/                ← FONTE dos cards (HTML + gerador)
├── carrossel-ansiedade/     ← FONTE do carrossel de emoção (HTML)
├── carrossel-app/           ← FONTE do carrossel de apresentação (post 00)
├── reels/                   ← FONTE dos reels (HTML + áudios copiados do app)
├── gerar-slides.js          ← gerador do carrossel
├── legendas-semana-1.md     ← legendas originais dos 7 cards
└── _arquivo/v2/             ← versão antiga (fontes pequenas), não usar
```

## Design System (revisão 2026-07-19)
- Tokens oficiais aplicados: cobalt `#2A47DD/#5567EA`, gold `#C4A86A` (dark) / `#8A6A28` (light), bases `#080B1C/#10142C` e `#E9EDFD` (light)
- Fontes DS: Playfair Display (títulos), Cormorant itálico (versículos), Instrument Sans (labels)
- **Mix light/dark**: emoções luminosas (Esperança, Gratidão, Louvor) em tema claro; noturnas (Ansiedade, Sono, Perdão, Proteção) em escuro — grid alterna, tudo on-brand

## Specs (revisão 2026-07-19, skill social-media-carousel)
- Feed (cards + carrossel): **1080×1350 (4:5)** — ocupa mais tela que o quadrado, mais alcance
- Reels: 1080×1920 (9:16)
- Carrossel: contador de progresso "N de 5" no topo dos slides de valor + "Salve este post" no CTA (save > like pro algoritmo)
- Geradores já ajustados pra 1350; regenerar mantém o formato

## Regras rápidas
- Cadência: **dom + qua + sex** (3/semana). Stories opcionais.
- Reels (02 e 08): montar no CapCut (~10 min) — passo a passo em `marketing/estrategia-instagram.md`.
- Carrossel (05): subir os 7 slides **na ordem dos nomes**.
- Postar pelo Meta Business Suite marca Facebook + Instagram de uma vez.
- Editar um card → mexe no HTML da pasta fonte → regenera PNG → recopia pra fila.

## Fluxo de edição (regenerar imagens)
```bash
# cards semana-1
node semana-1/gerar-semana-1.js
# carrossel / reels (Chrome headless direto)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new \
  --screenshot=SAIDA.png --window-size=1080,1350 --hide-scrollbars "file://$PWD/ARQUIVO.html"
# (reels usam --window-size=1080,1920)
```
