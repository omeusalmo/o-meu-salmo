# Reels Narrados — O meu Salmo

Reels devocionais completos (vídeo + narração real do app muxada), prontos pra postar
no Facebook e Instagram. Conteúdo orgânico — Salmo 23 engajou organicamente no FB
(2026-07-23), público maior parece estar lá.

## Conteúdo

| Arquivo | Salmo | Emoção | Duração | Legenda |
|---|---|---|---|---|
| `salmo-121.mp4` | 121 · O Senhor, Nosso Guardião | Esperança | ~41s | `legenda-salmo-121.txt` |
| `salmo-100.mp4` | 100 · Louvai ao Senhor | Gratidão | ~37s | `legenda-salmo-100.txt` |

## Formato — MESMO template do vídeo de lançamento (série consistente)
- 1080×1920 (9:16), **com áudio** (narração real de `app/assets/audios/`)
- Layout idêntico ao `marketing/ads/lancamento/anuncio-video-story.mp4` (Salmo 23): headline
  "O Salmo certo, pra cada emoção." no topo, ref line "Salmo NNN · título", fill dourado letra a
  letra, 4 chips de emoção, CTA cobalt "Baixar grátis →", microcopy "Grátis · Sem anúncios".
  Só variam o ref line e os versículos — pra o seguidor reconhecer a série na hora.
- Fill nos primeiros ~6s, depois segura os versículos enquanto a narração continua.

## Regenerar
```bash
cd marketing/ads
./fontes/gerar-reel-narrado.sh 121
./fontes/gerar-reel-narrado.sh 100
```
Config dos salmos (versículos exibidos, título) em `fontes/gerar-reel-narrado.py`.
Pra adicionar um salmo novo: incluir no dict PSALMS e rodar o .sh com o número.

## ⚠️ CTA "Baixar grátis" × fase do app
O template canônico tem o CTA "Baixar grátis →" (pra bater com o vídeo de lançamento). O app
ainda não está na produção da Play Store (teste fechado). Duas opções:
- **Segurar os reels** e disparar tudo no dia da produção (consistência total, CTA verdadeiro).
- **Postar agora** aproveitando o engajamento do FB: aí o CTA idealmente vira "Em breve na Play
  Store" ou some. Se for esse o caso, avisar que eu gero uma variante com o CTA ajustado.
Decisão do Jeff. Como launch está próximo (AAB v1.0.1+3 pronto, 12/12 testadores), manter o CTA
consistente é defensável.

## Nota de posicionamento
Áudio mono 24kHz do app (qualidade ok pra reel). O fill é um reveal de abertura, não
sincronizado palavra a palavra com a fala (não temos timing por palavra) — lê como
"o salmo sendo narrado com a estética do app", não como legenda karaokê exata.
