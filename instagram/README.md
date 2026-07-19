# Instagram — O meu Salmo

> **Pra postar: abre `fila-de-postagem/` e segue a numeração.** Cada post tem a imagem
> (ou pasta com fundo+áudio) e a legenda `.txt` do lado. Copia, cola, publica.
> Estratégia completa: `marketing/estrategia-instagram.md`.

## Estrutura (sem duplicação)

```
instagram/
├── fila-de-postagem/        ★ ÚNICA casa dos PNGs finais + legendas
│   ├── 00-pin-carrossel-app/     (PRIMEIRO POST — apresenta o app; fixar no perfil)
│   ├── 01-dom-card-esperanca     (light cobalt)
│   ├── 02-qua-reel-salmo-23/     (fundo + áudio 43s → CapCut)
│   ├── 03-sex-card-ansiedade     (dark cobalt)
│   ├── 04-dom-card-sono          (dark verde)
│   ├── 05-qua-carrossel-ansiedade/ (7 slides)
│   ├── 06-sex-card-gratidao      (light âmbar)
│   ├── 07-dom-card-perdao        (dark lavanda)
│   ├── 08-qua-reel-salmo-121/    (fundo + áudio 40s → CapCut)
│   ├── 09-sex-card-louvor        (light âmbar)
│   └── 10-dom-card-protecao      (dark verde)
└── fontes/                  ← só HTML (nunca PNG aqui)
    ├── gerar-tudo.sh        ★ regenera TODA a fila com 1 comando
    ├── cards/               (7 cards)
    ├── carrossel-app/       (5 slides)
    ├── carrossel-ansiedade/ (7 slides)
    └── reels/               (2 fundos 9:16)
```

**Editar uma arte:** mexe no HTML em `fontes/` → roda `fontes/gerar-tudo.sh` → fila atualizada. Fim.

## Paleta por emoção (herdada da LP, tokens `--emo-*` de docs/index.html)

| Emoção | Tema | Acento |
|---|---|---|
| Esperança | light | cobalt `#2A47DD` |
| Gratidão / Louvor | light âmbar | `#C99A38` |
| Ansiedade | dark | cobalt `#5567EA` |
| Sono / Proteção | dark verde | `#6A9A62` |
| Perdão | dark lavanda | `#8480AA` |
| Luto (futuro) | dark malva | `#9A6A86` |

Base sempre DS: Playfair (títulos), Cormorant itálico (versículos), Instrument Sans (labels), gold `#C4A86A`/`#8A6A28` nas referências.

## Specs
- Feed (cards/carrosséis): **1080×1350 (4:5)** · Reels: 1080×1920
- Carrossel: contador "N de X" no topo + "salve este post" no CTA
- Cadência: dom + qua + sex. Stories opcionais.
- Reels: montar no CapCut (passo a passo em `marketing/estrategia-instagram.md`)
- Postar via Meta Business Suite = Facebook + Instagram juntos
