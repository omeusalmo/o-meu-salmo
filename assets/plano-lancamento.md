# Plano de Lançamento — O meu Salmo

> **TL;DR:** ~10 dias pro gate de 14 dias fechar (4 dias com 12 testadores em 2026-08-02).
> Prioridade #1 = **brigada de avaliação** (reviews do teste fechado NÃO migram; ficha nasce 0★).
> Sequência: pré-produção blinda o gate + aquece → dia D coordena tudo junto → pago só depois
> de ~15-20 reviews 5★. Consolidado de 4 agentes (gerente, marketing, tech-lead-loja, analista).

Gerado 2026-08-02.

---

## 🎯 Prioridade #1 (Gerente): Brigada de avaliação
Reviews do teste fechado **não passam** pra produção — a ficha estreia com 0 estrelas. Volume +
velocidade de 5★ nas primeiras 72h é o maior sinal de ASO pra listing nova.
- Recrutar **25-30 pessoas** comprometidas AGORA (12 testadores + rede pessoal + grupos de igreja/WhatsApp).
- Todas instalam e avaliam **no dia da liberação** (não antes — reviews só contam na produção).
- Custo zero, define o ranking inicial.

## ⚠️ 3 riscos que furam o lançamento (Gerente)
1. **Perder testador antes do dia 14** → gate escorrega, launch atrasa. → toque diário leve nos 12.
2. **Bug de fonte (T1/P0) não corrigido no AAB de produção** → primeiras reviews <5★ matam o ASO. → travar produção até validar no device físico.
3. **Ligar pago cedo demais** em ficha 0-review → verba queimada. → orgânico + reviews primeiro, pago amplifica depois.

---

## 📅 Sequência

### Pré-produção (próximos ~10 dias)
- [ ] Confirmar T1 corrigido no AAB que vai pra produção (shippar quebrado = reviews ruins).
- [ ] Toque diário nos 12 testadores → garantir 12/12 opt-in ativo até o dia 14.
- [ ] Montar a brigada de 25-30 (lista + mensagem-âncora com deep link pros grupos de WhatsApp).
- [ ] Aquecer canais: reaproveitar post do Salmo 23 (já engajou no FB) + agendar os 2 reels narrados.
- [ ] Campanha paga criada mas **PAUSADA**.
- [ ] Instrumentar o funil de ativação no Firebase (ver Analista abaixo) — antes do dia D.
- [ ] Aplicar quick wins de ASO (ver Tech-lead-loja) na ficha.

### Dia D (quando a produção estiver LIVE, não no clique de promover)
> Promover ≠ instantâneo. Google revisa (horas a dias). Coordenar a rajada só **após** confirmar a ficha no ar.
- [ ] Brigada instala + avalia 5★ **com texto** (citar "salmos", "áudio", "salmo 23").
- [ ] Post de estreia: card **nativo** no FB (não link) + Reel de áudio, IG + FB.
- [ ] Disparo nos grupos de WhatsApp/Facebook cristãos.
- [ ] LP com CTA "Baixar na Play" ativo.
- [ ] Pago ainda **OFF**.

### Semana 1 pós-produção
- [ ] Ligar o pago só **depois** de ~15-20 reviews 5★ no ar.
- [ ] Responder **100%** das reviews no Console nos 3 primeiros dias (sinal de dev ativo).
- [ ] Rating diário: se cair <4.3, **pausar aquisição** e atacar a causa antes de escalar.

---

## 📣 Conteúdo & Viral (Marketing)

**FB puxa mais que IG → não espelhar.** No FB o motor é compartilhamento, não descoberta por Reel.
- **Card nativo** (imagem, não link — algoritmo pune link externo). Link só na 1ª linha do comentário fixado.
- **Texto-primeiro**: post só de texto (salmo curto + 1 linha íntima) compartilha mais que arte. O 23 provou.
- **Grupos cristãos**: entrar em 5-8 grupos ativos (católicos + evangélicos). Participar 1 semana antes de postar, nunca colar link — oferecer o Salmo, não divulgar.
- CTA de comentário: "salva pra depois", "marca alguém que precisa hoje" (comentário = alcance no FB).

**5 ideias com viral real (não "poste versículo"):**
1. **"Qual Salmo pra hoje?"** — enquete/caixinha, pessoa comenta a emoção, você responde com o Salmo. Curadoria pública ao vivo.
2. **"O Salmo que me segurou"** — audiência conta em 1 frase o Salmo que carregou num dia difícil. UGC emocional.
3. **Áudio às cegas** — Reel só narração + tela preta "feche os olhos 40s". Diferencial do app vira gancho.
4. **"Ansiedade às 3h da manhã"** — conteúdo por horário/estado (insônia, luto). Nomeia a dor, não o produto.
5. **Duelo suave** — "Salmo 91 ou 23 quando o medo aperta?" enquete que gera comentário e defesa.

**12 testadores → amplificadores:** kit pronto no WhatsApp (1 card + 1 frase pra reencaminhar), pedir print da tela favorita (repost UGC), pedir 1 review no dia D.

**Semana do lançamento:** D-3 teaser + bastidor founder · D-1 "O Salmo que me segurou" (UGC aquece) · **Dia D manhã** estreia (card FB + Reel + 12 compartilham juntos + grupos) · D+1 enquete "qual emoção você abriu primeiro" · D+3 repost dos melhores comentários (prova social fecha a onda).

---

## 🔎 ASO (Tech-lead-loja)

**Base:** Google Play indexa só **título, descrição curta, descrição longa e reviews**. As "tags" do aso-copy **não contam**. Keyword fora desses 4 lugares = invisível.

**Quick wins de alto impacto:**
1. **Título** → incluir "Salmos e Orações" (combo de altíssima busca cristã BR, maior alavanca de rank):
   `O meu Salmo: Salmos e Orações` (29 chars). Melhor que "do dia" ou "por emoção".
2. **Descrição curta** → injetar os salmos mais buscados do Brasil:
   `Salmos e orações em áudio. Salmo 23, 91 e mais, para cada emoção. Offline.` (76 chars)
3. **Descrição longa** → **miss grave: "salmo 23" e "salmo 91" (termos mais buscados) não aparecem.**
   Adicionar natural ("do Salmo 23 ao 91") e repetir "salmos"/"orações" mais vezes. Hoje é poética mas pobre de keyword.
4. **Reviews keyword-rich** no dia D (a review é indexada) — pedir que citem "salmos", "áudio", "salmo 23".
5. **8º screenshot** com prova social (nota/review). **Vídeo promocional não existe** → gap de conversão (prioridade baixa, planejar).
6. Velocidade de instalação 24-48h + **não desinstalar** (uninstall derruba rank) + responder toda review.

**Arquivo a editar:** `play-store/listing/aso-copy.md` (título, curta, longa).

---

## 📊 Métricas (Analista-dados)

**Painel de sucesso (dia D + semana 1):**
| Métrica | Meta D0 | Meta Semana 1 |
|---|---|---|
| Instalações | 50–100 | 300–500 |
| Ativação (leu 1 salmo OU ouviu áudio na 1ª sessão) | ≥40% | ≥40% |
| Retenção D1 | — | ≥35% |
| Retenção D7 | — | ≥30% |
| Share rate (`share_card`/DAU) | — | ≥5% |
| Rating / crash-free | — | ≥4.3 / ≥99% |

> Instalação sozinha = vaidade. Norte real = **ativação × D1**.

**Funil de ativação a instrumentar (falta):** `first_open` (com param `source` = install referrer, senão não separa pago de orgânico) → `onboarding_start` → `emotion_selected` → `onboarding_complete` → `first_salmo_read` → `audio_play` → `favorito_added` → `d1_return`.

**Pago vale a pena?** CPI alvo R$0,50–1,50 (>R$2,50 = criativo/segmentação ruim). Coorte paga precisa D1 ≥80% da orgânica. Métrica que manda = **custo por usuário ativado (CPI ÷ ativação) < R$3,50**.

**Critério objetivo:**
- **Foi bem** (liga Sprint B / escala pago): D7 ≥30% **E** ativação ≥40% **E** rating ≥4.3 **E** crash-free ≥99% **E** share ≥5%.
- **Corrigir antes de escalar:** D7 <15% → refazer onboarding. Ativação <30% → 1ª sessão/áudio. Rating <4.0 → responder reviews. Pago D1 <25% → desligar até ajustar criativo.
