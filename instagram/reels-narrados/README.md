# Reels Narrados — O meu Salmo

Reels devocionais completos (vídeo + narração real do app muxada), prontos pra postar
no Facebook e Instagram. Conteúdo orgânico — Salmo 23 engajou organicamente no FB
(2026-07-23), público maior parece estar lá.

## Conteúdo

| Arquivo | Salmo | Emoção | Duração | Legenda |
|---|---|---|---|---|
| `salmo-121.mp4` | 121 · O Senhor, Nosso Guardião | Esperança | ~41s | `legenda-salmo-121.txt` |
| `salmo-100.mp4` | 100 · Louvai ao Senhor | Gratidão | ~37s | `legenda-salmo-100.txt` |

## Formato
- 1080×1920 (9:16), **com áudio** (narração real de `app/assets/audios/`)
- Fill dourado letra a letra nos primeiros ~6s (efeito de leitura do app), depois segura
  os versículos enquanto a narração continua
- Rodapé de marca suave (chip da emoção + site) — **sem CTA de download**, porque o app
  ainda está em teste fechado. Trocar por "Baixe grátis na Play Store" quando entrar em produção.

## Regenerar
```bash
cd marketing/ads
./fontes/gerar-reel-narrado.sh 121
./fontes/gerar-reel-narrado.sh 100
```
Config dos salmos (versículos exibidos, emoção, cor) em `fontes/gerar-reel-narrado.py`.
Pra adicionar um salmo novo: incluir no dict PSALMS e rodar o .sh com o número.

## Nota de posicionamento
Áudio mono 24kHz do app (qualidade ok pra reel). O fill é um reveal de abertura, não
sincronizado palavra a palavra com a fala (não temos timing por palavra) — lê como
"o salmo sendo narrado com a estética do app", não como legenda karaokê exata.
