# Instagram — O meu Salmo

> **Pra postar: abre `fila-de-postagem/` e segue a numeração.** Cada post tem a imagem
> (ou pasta com fundo+áudio) e a legenda `.txt` do lado. Copia, cola, publica.
> Estratégia completa: `marketing/estrategia-instagram.md`.

## Estrutura (sem duplicação)

**1 post = 1 pasta.** Abre a pasta do próximo número, arrasta a(s) imagem(ns), copia a `legenda.txt`. Fim.

```
instagram/
├── fila-de-postagem/        ★ 21 pastas, 1 por post, na ordem de publicação
│   ├── 00-pin-carrossel-app/       5 slides + legenda.txt   (1º post; FIXAR no perfil)
│   ├── 01-dom-card-esperanca/      post.png + legenda.txt   (light cobalt)
│   ├── 02-qua-reel-salmo-23/       fundo.png + audio.mp3 + legenda.txt (montar no CapCut)
│   ├── 03-sex-card-ansiedade/      post.png + legenda.txt   (dark cobalt)
│   ├── 04-dom-card-sono/           post.png + legenda.txt   (dark verde)
│   ├── 05-qua-carrossel-ansiedade/ 7 slides + legenda.txt   (subir na ordem dos nomes)
│   ├── 06-sex-card-gratidao/       post.png + legenda.txt   (light âmbar)
│   ├── 07-dom-card-perdao/         post.png + legenda.txt   (dark lavanda)
│   ├── 08-qua-reel-salmo-121/      fundo.png + audio.mp3 + legenda.txt (CapCut)
│   ├── 09-sex-card-louvor/         post.png + legenda.txt   (light âmbar)
│   ├── 10-dom-card-protecao/       post.png + legenda.txt   (dark verde)
│   ├── 11-especial-lancamento-producao/  post.png + legenda.txt (light cobalt; ⚠️ SÓ POSTAR após Jeff confirmar Produção no Play Console — ver aviso no topo do legenda.txt; CTA = link direto da Play Store, não omeusalmo.com.br)
│   ├── 12-qua-reel-salmo-42/       fundo.png + audio.mp3 + legenda.txt (dark malva, Luto; CapCut)
│   ├── 13-sex-card-ansiedade/      post.png + legenda.txt   (dark cobalt, Salmo 46)
│   ├── 14-dom-card-luto/           post.png + legenda.txt   (dark malva, Salmo 34)
│   ├── 15-qua-carrossel-como-funciona/ 6 slides + legenda.txt (dark cobalt, subir na ordem dos nomes)
│   ├── 16-sex-founder-por-que-fiz/ post.png + legenda.txt   (dark cobalt, quote card)
│   ├── 17-dom-card-gratidao/       post.png + legenda.txt   (light âmbar, Salmo 103)
│   ├── 18-qua-card-sono/           post.png + legenda.txt   (dark verde, Salmo 127)
│   ├── 19-sex-founder-gratis-sem-anuncio/ post.png + legenda.txt (dark cobalt, quote card)
│   └── 20-dom-card-esperanca/      post.png + legenda.txt   (light cobalt, Salmo 27)
└── fontes/                  ← só HTML (nunca PNG aqui)
    ├── gerar-tudo.sh        ★ regenera TODA a fila com 1 comando
    ├── cards/               (12 cards)
    ├── carrossel-app/       (5 slides)
    ├── carrossel-ansiedade/ (7 slides)
    ├── carrossel-como-funciona/ (6 slides)
    ├── founder/             (2 quote cards)
    ├── especial/            (1 card de lançamento em produção)
    └── reels/               (3 fundos 9:16)
```

**Nomenclatura das pastas:** `NN-dia-formato-tema` → `04-dom-card-sono` = 4º post, domingo, card, tema Sono.
O post 11 foge do padrão (`NN-especial-tema`, sem dia fixo) porque a data de publicação depende da confirmação da promoção pra Produção no Play Console.
**Editar uma arte:** mexe no HTML em `fontes/` → roda `fontes/gerar-tudo.sh` → fila atualizada.

## Paleta por emoção (herdada da LP, tokens `--emo-*` de docs/index.html)

| Emoção | Tema | Acento |
|---|---|---|
| Esperança | light | cobalt `#2A47DD` |
| Gratidão / Louvor | light âmbar | `#C99A38` |
| Ansiedade | dark | cobalt `#5567EA` |
| Sono / Proteção | dark verde | `#6A9A62` |
| Perdão | dark lavanda | `#8480AA` |
| Luto | dark malva | `#9A6A86` |

Base sempre DS: Playfair (títulos), Cormorant itálico (versículos), Instrument Sans (labels), gold `#C4A86A`/`#6B4E1C` nas referências.

## Specs
- Feed (cards/carrosséis): **1080×1350 (4:5)** · Reels: 1080×1920
- Carrossel: contador "N de X" no topo + "salve este post" no CTA
- Cadência: dom + qua + sex. Stories opcionais.
- Reels: montar no CapCut (passo a passo em `marketing/estrategia-instagram.md`)
- Postar via Meta Business Suite = Facebook + Instagram juntos
