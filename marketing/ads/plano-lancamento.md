# Plano de mídia paga — lançamento O meu Salmo

> **TL;DR:** kit criativo pronto e de alta qualidade (feed/story/vídeo + 3 copies A/B/C). Mas o app **não tem nenhum SDK de rastreamento do Meta** instalado, só Firebase Analytics. Rodar campanha "Promoção de app" oficial agora vai gastar dinheiro sem o Meta conseguir confirmar quem instalou de verdade, só quem clicou. Recomendação: **Fase 1 (agora, sem mexer no app) roda como campanha de Tráfego, orçamento baixo de teste. Fase 2 (quando quiser escalar) integra rastreamento de verdade.**

**Atualizado:** 2026-08-08. Escrito porque `prompt-opus-campanhas-pagas.md` nunca tinha sido de fato rodado, só existia como prompt pronto pra colar — Jeff pediu revisão da campanha antes de investir de verdade.

---

## O achado que muda o plano

O `pubspec.yaml` do app só tem `firebase_analytics` + `firebase_crashlytics`. Não tem `facebook_app_events` nem nenhum SDK de atribuição do Meta. Nenhum servidor próprio pra usar a Conversions API do Meta (server-side) também.

Na prática: se você criar uma campanha "Promoção de app" (App Installs) no Gerenciador de Anúncios apontando pro link da Play Store, o Meta vai cobrar por otimização de instalação, mas **não recebe o evento de instalação de volta** — o algoritmo fica otimizando às cegas, o que costuma sair mais caro por instalação (CPI pior) do que uma campanha simples de cliques.

Isso não impede rodar ads agora. Só muda qual tipo de campanha faz sentido.

## Fase 1 — agora, sem mudar o app

**Tipo de campanha:** Tráfego (Traffic), não "Promoção de app". Destino: link direto da Play Store.

Por quê: sem SDK, o Meta não consegue otimizar por instalação mesmo que você escolha o objetivo "certo" no nome. Campanha de Tráfego é honesta sobre o que o Meta de fato consegue medir (cliques no link) e costuma sair mais barata por resultado nessa situação.

**O que já está pronto** (`marketing/ads/lancamento/`):
- `anuncio-feed.png` (1080×1350) e `anuncio-story.png` (1080×1920) — estáticos, alta qualidade, já revisados
- `anuncio-video-story.mp4` (7.5s, mudo, efeito karaokê dourado) — mesma peça, formato vídeo
- `copy-anuncio-meta.txt` — 3 variantes (Reveal / Dor específica / Hábito diário)

**Orçamento sugerido:** R$20-30/dia por variante, 3 variantes rodando em paralelo, 4-5 dias. Total do teste: ~R$300-450. Depois disso, olhar qual variante teve CTR (cliques ÷ impressões) mais alto e CPC (custo por clique) mais baixo, matar as 2 piores, concentrar o orçamento na vencedora.

**Públicos:** interesses fé/espiritualidade, música gospel, devocionais, bem-estar mental, meditação. PT-BR, Brasil. Posicionamentos: Feed + Stories + Reels (Instagram e Facebook), deixar o Meta otimizar automaticamente entre eles (não travar só em um).

**Ordem de prioridade das 3 copies:** começar pela **Variante B (dor específica: ansiedade/sono)**, não a A (reveal). Dor específica converte melhor em público frio, que ainda não te conhece — a pessoa se reconhece no problema antes de saber que existe um app. Reveal genérico funciona melhor no orgânico, pra quem já te segue (é o que o post 11 já faz). Variante A e C entram depois, como comparação.

**Rastreamento sem precisar de SDK novo:** o Google Play tem "Install Referrer" nativo. Se o link do anúncio incluir um parâmetro de campanha, o Firebase Analytics (já instalado no app) captura automaticamente de qual campanha veio cada instalação — sem precisar integrar nada. Usar esse link no anúncio em vez do link puro:
```
https://play.google.com/store/apps/details?id=com.omeusalmo.salmos&referrer=utm_source%3Dmeta%26utm_medium%3Dcpc%26utm_campaign%3Dlancamento
```
Isso não é tão completo quanto o SDK do Meta (o Meta em si continua sem saber quem instalou, então a otimização automática de lance continua limitada), mas o **Firebase Console → Analytics → Aquisição/Campanhas** vai mostrar instalação real separada por fonte, o que já dá um sinal muito melhor que só CTR do anúncio.

**Como saber se está funcionando:**
1. **Gerenciador de Anúncios:** CTR, CPC, gasto por variante — isso o Meta mede direito mesmo sem SDK
2. **Firebase Console → Analytics → Aquisição:** instalações reais atribuídas à campanha via referrer (ver acima)
3. **Play Console → Estatísticas → Visão geral:** instalações totais por dia, cruzamento geral

## Fase 2 — quando quiser escalar de verdade

Só vale o esforço quando Fase 1 mostrar que o CPC compensa e você quiser aumentar o orçamento de forma consistente (não em R$300/mês pontual).

**Opção A — Meta:** integrar o pacote `facebook_app_events` no Flutter + configurar o app no Meta for Developers (App ID, evento `fb_mobile_activate_app`). Exige nova build + novo ciclo de revisão na Play Store (não é imediato). Depois disso sim faz sentido rodar campanha "Promoção de app" oficial com otimização real.

**Opção B — Google Ads (App Campaigns / UAC):** caminho de menor fricção técnica, porque o app já tem Firebase Analytics — basta linkar o projeto Firebase à conta do Google Ads (Firebase Console → Integrações → Google Ads), sem precisar mexer em código. Google Ads então enxerga os eventos que o Firebase já capta. Vale considerar como alternativa ou complemento ao Meta, não só como substituto.

**Recomendação:** não fazer isso antes do lançamento. É trabalho de dev + delay de revisão que não cabe nos próximos dias. Fica pro roadmap pós-lançamento, quando Fase 1 já tiver validado que vale escalar.

## Setup

**Confirmado 2026-08-09:** Business Manager "O meu Salmo" já existe e ativo, Página + Instagram @omeusalmo conectados (Meta Business Suite). Falta só confirmar se a conta de anúncios (BRL) e forma de pagamento já estão configuradas — checar em Gerenciador de Anúncios → Configurações antes de criar a campanha.

## Sequência de lançamento (fator que mais importa)

Reveal orgânico (post 11 da fila) e a campanha paga entram **no mesmo dia** em que promover pra Produção no Play Console, não antes (link quebra pra quem não é testador) nem depois (perde o pico de atenção do "chegou"). É o maior fator de sucesso do lançamento, mais que qualquer ajuste fino de copy ou público.

## Regenerar o criativo (se precisar ajustar)

Ver `marketing/ads/README.md`, seção "Regenerar o criativo" — comandos prontos.
