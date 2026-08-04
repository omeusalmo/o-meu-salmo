# Reels Narrados — O meu Salmo

Reels devocionais completos (vídeo + narração real do app muxada), prontos pra postar
no Facebook e Instagram. Conteúdo orgânico — Salmo 23 engajou organicamente no FB
(2026-07-23), público maior parece estar lá.

## Conteúdo

| Arquivo | Salmo | Emoção | Duração | Legenda |
|---|---|---|---|---|
| `salmo-121.mp4` | 121 · O Senhor, Nosso Guardião | Esperança | ~41s | `legenda-salmo-121.txt` |
| `salmo-100.mp4` | 100 · Louvai ao Senhor | Gratidão | ~37s | `legenda-salmo-100.txt` |
| `salmo-4.mp4` | 4 · Oração da Tarde | Sono | ~57s | `legenda-salmo-4.txt` |
| `salmo-150.mp4` | 150 · Louvor a Deus | Louvor | ~37s | `legenda-salmo-150.txt` |

## Qual pasta usar

| Destino | Pasta | Proporção |
|---|---|---|
| **Reels** (IG/FB) | raiz daqui | 1080×1920 (9:16) |
| **Feed** (IG/FB) | `feed-4x5/` | 1080×1350 (4:5) |

O composer da Meta só aceita de **4:5 a 16:9** no post de feed — 9:16 é rejeitado com
"Corrija a taxa de proporção". Os `feed-4x5/` são gerados nativos nessa altura (layout
recomposto, não cortado), mesmas legendas.

## Formato — DEVOCIONAL (estilo `fila-de-postagem/02-qua-reel-salmo-23/meupastor.mp4`)
- 1080×1920 (9:16), **com áudio** (narração real de `app/assets/audios/`), frame estático.
- Layout limpo (NÃO é o estilo do anúncio): eyebrow "O MEU SALMO", tag da emoção colorida +
  linha deco, **um versículo-assinatura centralizado** (Cormorant itálico branco), ref line gold
  "Salmos NNN · narração do app", número fantasma grande no canto, rodapé "ouça com o som ligado".
- **SEM** headline de posicionamento, **SEM** os 4 chips, **SEM** CTA "Baixar grátis". São posts
  devocionais compartilhados como os cards — quem oferece amparo, não quem vende app.
- Cor de acento por emoção (tag/deco/número): Esperança cobalt, Gratidão/Louvor âmbar, Sono verde.

## Regenerar
```bash
cd marketing/ads
./fontes/gerar-reel-narrado.sh 121          # 9:16 (Reels) — padrão
./fontes/gerar-reel-narrado.sh 121 4x5      # 4:5  (feed)  — sai em feed-4x5/
```
Config dos salmos (versículos exibidos, título) em `fontes/gerar-reel-narrado.py`.
Pra adicionar um salmo novo: incluir no dict PSALMS e rodar o .sh com o número.
As medidas de cada formato ficam no dict `LAYOUTS` do .py (altura, paddings,
marca d'água) — o 4:5 é recomposto, não é crop do 9:16.

## Histórico de CTA
- 2026-08-01: reels haviam adotado o template do anúncio (com "Baixar grátis →").
- 2026-08-03: **Jeff pediu pra remover o CTA** — os reels são posts devocionais compartilhados
  como os outros, não anúncio. Refeitos no estilo devocional (`meupastor.mp4`), sem botão de download.
- 2026-08-03: Meta rejeitou o 9:16 no composer de feed. Gerador ganhou o formato `4x5`
  e os 4 salmos foram gerados em `feed-4x5/`. Os 9:16 continuam válidos pra Reels.

## Nota de posicionamento
Áudio mono 24kHz do app (qualidade ok pra reel). Frame estático + narração, no estilo do
`meupastor.mp4` — o versículo-assinatura + "ouça com o som ligado" convidam a ligar o som.
