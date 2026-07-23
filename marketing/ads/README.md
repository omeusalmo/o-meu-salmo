# Ads — O meu Salmo

## ⚠️ Status: app ainda em teste fechado, sem link público

8/12 nomes, 6/12 e-mails, **0 convites enviados**. Play Store não tem página
pública instalável ainda. Duas consequências práticas:

1. **Tráfego pago não pode rodar** — campanha "Promoção de app" precisa de
   um destino real pra instalar. Rodar agora = pagar por clique que trava
   num "app não encontrado".
2. **O post de anúncio "O app chegou" NÃO deve ir pro feed orgânico ainda**
   — prometer disponibilidade e a pessoa não conseguir instalar quebra
   confiança logo na largada. Guardar pra quando sair da faixa de teste.

**Ordem certa:** fechar os 12 testadores → 14 dias → produção liberada →
publicar este post + ligar a campanha paga no mesmo dia (o reveal vira o
gancho de lançamento nos dois canais ao mesmo tempo).

## O que está pronto pra esse dia

Kit coeso — os 3 formatos saem do mesmo sistema visual (Salmo 23, headline de
posicionamento, fill dourado, chips por emoção, CTA cobalt, microcopy):

- `lancamento/anuncio-feed.png` (1080×1350) — feed Instagram/Facebook. Gerado por
  `fontes/gerar-imagem-ads.py` (still do conceito do vídeo, fill congelado no meio da leitura).
- `lancamento/anuncio-story.png` (1080×1920) — Stories/Reels, dobra como criativo pago. Mesmo gerador.
- `lancamento/anuncio-video-story.mp4` (1080×1920, 7.5s, **mudo**) — headline de posicionamento
  grande fixo no topo ("O Salmo certo, pra cada emoção.") + Salmo 23 preenchendo **letra a letra**
  em dourado (efeito karaokê via clip-path de duas camadas: texto apagado embaixo, dourado
  revelado por wipe), termina parado no CTA cobalt. Feito pra rodar sem som no feed. Ver
  `legenda-video.txt`.
  - Fonte: `fontes/gerar-video-fill.py` (HTML determinístico por frame, progresso p in [0,1]) +
    `fontes/gerar-video-lancamento.sh` (screenshot 60 frames + hold no final + ffmpeg). Efeito de
    fill escolhido a pedido do Jeff (2026-07-22), substitui o teleprompter linha-a-linha anterior.
  - **Gotchas de renderização (não remover do pipeline):** (1) cada frame é um Chrome headless
    novo — sem `--virtual-time-budget=6000` a webfont não termina de carregar antes do screenshot
    e o texto cai em fallback com métrica diferente, fazendo a fonte "mudar de tamanho" entre
    frames. (2) grão estático de média-zero + `-crf 16 -x264-params aq-mode=3` matam o banding do
    gradiente escuro que, sem isso, tremeluz sob compressão. Ambos verificados com diff de frames
    consecutivos = ~0.
- `lancamento/legenda-organica.txt` / `legenda-video.txt` — legendas dos posts orgânicos
- `lancamento/copy-anuncio-meta.txt` — 3 variantes de copy pro Gerenciador de Anúncios (headline/texto/CTA)
- `fontes/gerar-imagem-ads.py` — regenera os 2 estáticos (feed 1350 + story 1920)
- `fontes/gerar-video-lancamento.sh` — regenera o vídeo do zero

### Revisão cruzada — Designer, Marketing, Gerente (2026-07-21)

Pedido: 3 personas do projeto (`.claude/agents/designer.md`, `marketing.md`, `gerente.md`)
revisaram o vídeo de lançamento, cada uma pela própria lente. Achados aplicados:

- 🔴 **CTA usava gold (`#C4A86A`) como cor de botão** — viola a regra mais dura do DS
  (`design-system.html:255`, `verse_line.dart:8-10`: "âmbar nunca é cor de UI, só o
  versículo em destaque"). Corrigido pra **cobalt `#5567EA`** (mesma cor do botão real
  "Ler o salmo" no app) em **todo o kit** — vídeo E os 2 estáticos tinham o mesmo erro.
- Opacidade da linha inativa ajustada de `.45` pra `.32`, batendo com o valor real do
  karaokê da LP (`docs/index.html:542`).
- Vídeo cortado de 6 pra 4 falas + frame final ("outro") 3.2s parado com a frase de
  posicionamento "O Salmo certo, pra cada emoção." — a versão anterior não tinha
  nenhum texto de proposta de valor explícito, só ficava implícito nos chips; e o ritmo
  de 6 falas em 8.3s corria rápido demais pro público-alvo (momento de ansiedade/luto
  pede pausa, não teleprompter correndo).
- Microcopy "Grátis · Sem anúncios" adicionada perto do CTA (esses diferenciais só
  apareciam na copy paga externa, não na peça em si).
- **Não alterado**: cores dos chips de emoção. São os tokens oficiais da LP (`--emo-*`)
  clareados de propósito pra contraste em fundo escuro — mesma matiz, mais claros — e o
  mesmo padrão já usado nos carrosséis do Instagram. Trocar pros tons literais (calibrados
  pra fundo claro) prejudicaria a legibilidade sem ganho real de fidelidade.

Gerente: aprovou o timing de "pronto e guardado até produção liberar"; sinalizou que o
gargalo real do projeto é recrutamento de testadores (9/12 nomes, 7/12 e-mails em
2026-07-21), não o kit de marketing.

### Coesão do kit (revisão 2026-07-23)

Os estáticos eram de uma geração anterior (full-bleed de screenshot real da tela) e ficaram
fora de sintonia com o vídeo. Refeitos do mesmo sistema visual do vídeo (`gerar-imagem-ads.py`):

- **Salmo 23, não 68.** A versão anterior usava o screenshot da home com o Salmo 68 do dia
  ("pereçam os ímpios diante de Deus" / "Cantai a Deus") — conteúdo marcial que contradiz o
  posicionamento de conforto pra quem está em ansiedade/luto. Salmo 23 (o pastor) é o certo.
- **CTA e microcopy iguais ao vídeo:** barra cobalt full-width "Baixar grátis →" + "Grátis ·
  Sem anúncios" (antes era pill pequena "Baixe grátis", sem microcopy).
- **Still do fill:** o versículo aparece com o preenchimento dourado congelado no meio da
  leitura, comunicando o diferencial (narração acende o texto) mesmo parado.

## Estratégia de mídia paga (visão geral)

Plano completo e passo a passo de setup: `marketing/prompt-opus-campanhas-pagas.md`
(cole esse prompt no Opus quando o app estiver em produção — ele monta a
campanha inteira: estrutura, públicos, orçamento, A/B).

Resumo do que importa agora:

- **Objetivo de campanha:** Promoção de app (App Installs), não tráfego genérico
- **Por que essa criativo funciona pra ads:** mostra o produto real (screenshot),
  não uma peça abstrata — reduz risco percebido, aumenta CTR em campanhas de instalação
- **Teste A/B:** as 3 variantes de copy em `copy-anuncio-meta.txt` atacam ângulos
  diferentes (reveal / dor específica / hábito) — rodar as 3 com orçamento igual
  por 4-5 dias, matar as 2 piores, escalar a vencedora
- **Página + conta de anúncios:** já configuradas ([[project-meta-ads-setup]])
- **Orçamento:** cenário enxuto R$300-500/mês ou R$1.000/mês — ver prompt completo

## Regenerar o criativo

```bash
cd marketing/ads
# estáticos (feed + story):
python3 fontes/gerar-imagem-ads.py
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless=new --virtual-time-budget=6000 --screenshot=lancamento/anuncio-story.png \
  --window-size=1080,1920 --hide-scrollbars "file:///tmp/ads-story.html"
"$CHROME" --headless=new --virtual-time-budget=6000 --screenshot=lancamento/anuncio-feed.png \
  --window-size=1080,1350 --hide-scrollbars "file:///tmp/ads-feed.html"

# vídeo:
./fontes/gerar-video-lancamento.sh
```
> `--virtual-time-budget` é obrigatório (sem ele a webfont não carrega antes do screenshot).
