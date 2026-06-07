# UI Kit — Aplicativo "O meu Salmo"

Recriação em alta fidelidade do app (Android-first). Componentes React (Babel inline) montados num protótipo clicável.

## Telas
1. **Emoções** — entrada por curadoria: "Como você está chegando hoje?" + grade de emoções.
2. **Coleção** — lista de Salmos de uma emoção (ex.: "Para a ansiedade").
3. **Leitura** — o Salmo: título Playfair, versículos em Cormorant, player de áudio fixo, versículo em destaque (âmbar).

## Componentes (`components.jsx`)
`StatusBar`, `EyebrowLabel`, `EmotionChip`, `PsalmCard`, `AudioPlayer`, `VerseLine`, `IconButton`, `Logotype`.

## Como rodar
Abra `index.html`. Alterna entre noturno/diurno pelo botão no topo. Estado fake (sem backend).

## Fonte de verdade
Tokens em `../../colors_and_type.css`. Voz/tom e regras no `../../README.md`. Modo padrão = **noturno**.
