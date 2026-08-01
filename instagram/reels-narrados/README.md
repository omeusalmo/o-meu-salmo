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

## CTA "Baixar grátis"
Decisão do Jeff (2026-08-01): **manter "Baixar grátis →"** em todos, pela consistência da série
com o vídeo de lançamento. Launch está próximo (AAB v1.0.1+3 pronto, 12/12 testadores).

## Nota de posicionamento
Áudio mono 24kHz do app (qualidade ok pra reel). O fill é um reveal de abertura, não
sincronizado palavra a palavra com a fala (não temos timing por palavra) — lê como
"o salmo sendo narrado com a estética do app", não como legenda karaokê exata.
