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

- `lancamento/anuncio-feed.png` (1080×1350) — feed Instagram/Facebook
- `lancamento/anuncio-story.png` (1080×1920) — Stories/Reels, dobra como criativo pago
- `lancamento/anuncio-video-story.mp4` (1080×1920, 8.3s, **mudo**) — Salmo 23 sendo lido em
  efeito teleprompter (linha ativa em destaque, como no app), crossfade entre linhas, CTA fixo
  no rodapé. Feito pra rodar sem som no feed. Ver `legenda-video.txt`.
- `lancamento/legenda-organica.txt` / `legenda-video.txt` — legendas dos posts orgânicos
- `lancamento/copy-anuncio-meta.txt` — 3 variantes de copy pro Gerenciador de Anúncios (headline/texto/CTA)
- `fontes/anuncio-lancamento.html` — template fonte dos estáticos
- `fontes/gerar-video-lancamento.sh` — regenera o vídeo do zero (screenshots dos 6 estados + ffmpeg)

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

### Direção visual (revisão 2026-07-20)

- **Fonte da screenshot:** `play-store/screenshots/raw-cropped/` (tela limpa, sem overlay de
  marketing). Nunca usar `play-store/export/s*.png` como fundo de anúncio — essas têm frase
  sobreposta pela própria arte da ficha da loja.
- **Full-bleed, não floating-card:** a screenshot cobre a arte inteira (recortada da tela de
  leitura, versículo real como textura) em vez de um card flutuante com sombra sobre fundo
  sólido. O floating-card-com-glow é o clichê genérico de anúncio SaaS — full-bleed lê como
  conteúdo real, não como peça publicitária, e para mais o scroll.
- **Scrim sólido, não gradiente puro:** faixa opaca (não degradê) atrás do headline pra garantir
  zero colisão com o texto da própria UI do app por trás.

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
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new \
  --screenshot=lancamento/anuncio-feed.png --window-size=1080,1350 --hide-scrollbars \
  "file://$PWD/fontes/anuncio-feed.html"
# story: --window-size=1080,1920 + fontes/anuncio-story.html
```
