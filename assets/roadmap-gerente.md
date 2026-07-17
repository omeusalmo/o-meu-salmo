# Roadmap Gerente — O meu Salmo
_Atualizado: 2026-06-08. Versão pós-construção do MVP, pré-lançamento._

---

## Estado atual do produto

**App Flutter:** MVP completo e funcional.

| Feature | Status |
|---|---|
| 150 salmos com reflexão + reflexao_pergunta | ✅ |
| 8 coleções emocionais | ✅ |
| Favoritos (offline, SharedPreferences) | ✅ |
| Salmo do dia (Home) | ✅ |
| Notificações locais (ciclo por dia do ano) | ✅ |
| Compositor de imagem + compartilhamento | ✅ |
| Firebase Analytics (6 eventos) | ✅ |
| Seção Apoie (Pix + bottom sheet) | ✅ |
| Sugestões via mailto | ✅ |
| Onboarding 3 telas + picker emocional | ✅ |
| WCAG 2.1 AA (contraste acessível) | ✅ |
| Release signing configurado (key.properties) | ✅ |
| Política de privacidade (HTML local) | ✅ |
| Landing Page | ✅ |

**Áudio narrado:** não implementado (fora do MVP).

---

## Bloqueadores de lançamento (Fase 2 crítica)

Estes itens **bloqueiam** a publicação no Google Play:

| # | Bloqueador | Responsável | Ação |
|---|---|---|---|
| B1 | Conta Google Play Console (US$ 25) | Jeff | Criar em play.google.com/console |
| B2 | Política de privacidade em URL pública | tech-lead-lp | Publicar `privacy_policy.html` na LP ou GitHub Pages |
| B3 | Screenshots do app (mín. 2, ideal 8) | Jeff + design | Capturar no emulador/device real |
| B4 | Feature Graphic (1024×500 px) | design | Criar com identidade visual |
| B5 | Closed testing: 12 testadores por 14 dias | Jeff | Convidar testers no Play Console |

---

## Sprint A — Lançamento (prioridade máxima)

_Meta: app publicado no Google Play._

### A1 · Publicação da política de privacidade
- Fazer deploy da `privacy_policy.html` em URL pública (GitHub Pages ou subdomínio da LP)
- Registrar URL no Play Console e no app (Ajustes > Política)

### A2 · ASO (App Store Optimization)
- **Título:** ≤30 chars, inclui "salmos" e emoção principal
- **Descrição curta:** ≤80 chars, benefício emocional + CTA
- **Descrição longa:** ≤4000 chars, palavras-chave: salmos, ansiedade, oração, dormir, gratidão, reflexão
- **Tags/categorias:** Lifestyle + Books & Reference

### A3 · Materiais visuais da loja
- 8 screenshots no formato portrait 9:16 (Phone)
- 1 Feature Graphic 1024×500 px
- Ícone já existe no app — exportar em 512×512 PNG

### A4 · Closed testing
- Criar track de testes interno no Play Console
- 12 testers × 14 dias (exigência atual do Google)
- Coletar feedback: bugs, UX, clareza do onboarding

### A5 · Validação final pre-store
- `flutter build appbundle --release` sem erros
- Testar install do .aab num device físico Android
- Verificar Analytics disparando (Firebase DebugView)

---

## Sprint B — Pós-lançamento imediato (semanas 1-4)

_Meta: primeiros 100 usuários, retenção D7 > 30%._

### B1 · Monitoramento
- Firebase Analytics: DAU, salmo_read, share_card, collection_opened
- Crashes: Firebase Crashlytics (adicionar ao app)
- Reviews: responder todas no Play Console na primeira semana

### B2 · Crescimento orgânico
- Compartilhamento via compositor de imagem (já implementado) — é o motor principal
- Divulgação em grupos de WhatsApp/Telegram de cristãos brasileiros
- Posts no Instagram com versículos usando visual do app

### B3 · Quick wins de UX
- ~~Onboarding de 1 slide~~ → entregue: onboarding 3 telas + picker emocional ✅
- Rating prompt na sessão 3 (após salmo lido)
- Deep link para salmo específico (para campanhas de divulgação)

---

## Sprint C — Crescimento (meses 2-3)

_Só iniciar com sinal de retenção D30 > 20%._

### C1 · Monetização: anúncios
- Integrar AdMob (banner na loja, não no conteúdo espiritual)
- Posicionamento: banner abaixo do compositor, não na leitura do salmo
- Meta: cobrir custos de infra antes de freemium

### C2 · Monetização: freemium
- Camada premium: áudio narrado, sem anúncios, widget na tela inicial
- Entitlements já têm base no app — ativar com produto IAP no Play Console
- Preço sugerido: R$ 9,90/mês ou R$ 69,90/ano

### C3 · Conteúdo premium
- Áudio TTS narrado para salmos das coleções (começar pelas 8 coleções)
- Novas coleções: Casamento, Família, Trabalho, Doença
- Reflexões expandidas (versão longa) como conteúdo premium

### C4 · Expansão de plataforma
- Widget Android (salmo do dia na home screen)
- iOS: só após Android estável e com receita

---

---

## Benchmarking Competitivo — Insights (2026-06-08)

_Realizado por Designer + Gerente. Apps analisados: YouVersion, Glorify, Calm, Hallow, Bible.is, Lectio 365._

### Posicionamento — onde ganhar vs. onde perder

**Perde sempre contra apps com $10M de budget:**
- Biblioteca de conteúdo (planos, devocionais, vídeos)
- Comunidade/social features, áudio em escala
- Marketing pago

**Moat inimitável com budget zero:**
- **Curadoria emocional precisa de salmos** — nenhum app resolve "estou ansioso, qual salmo?" com cuidado editorial. YouVersion joga numa lista.
- **Zero fricção, zero cadastro** — cristão brasileiro 40 anos abre e já está no salmo. Não quebre com login cedo demais.
- **Identidade brasileira** — Glorify é americano, YouVersion é americano. Dores, contexto, fé popular BR = diferenciação inimitável.

### Alertas de risco (não repetir)
- **Streak nunca chamado de "streak" na UI** — usar "jornada", "presença", "caminhada". Gamificação religiosa visível = público BR rejeita.
- **Modo sono só com áudio humano de qualidade** — expectativa criada é alta; áudio robótico + relaxamento = reputação destruída.
- **Liturgia católica requer pesquisa profunda** — numeração LXX vs TM, erro de salmo no domingo = perde usuário católico para sempre.
- **Card de compartilhamento só com design forte** — card mediano não é compartilhado, esforço desperdiçado.

### Monetização futura — fundação freemium

| Tier | Features |
|------|----------|
| **Free always** | Salmo do Dia, 150 salmos leitura, favoritos, notificação diária genérica, plano 7 dias (1 emoção) |
| **Premium forte** | Modo sono, áudio offline completo, notificação contextual por emoção, planos ilimitados, velocidade narração |
| **Premium médio** | Widget personalizado (temas/salmo escolhido), reflexão guiada |
| **Nunca monetizar** | Diário espiritual (dados pessoais espirituais = sensível), conquistas/selos (gamificação religiosa cobra = toxic combo) |

---

## Sprint D — Retenção & Aquisição Orgânica (4-5 semanas)

_Pré-requisito: app publicado na Play Store. Meta: retenção D7 ≥ 35%, shares ≥ 5% DAU._

### D1 · Streak Devocional ("Jornada")
- Contador de dias consecutivos de acesso ao Salmo do Dia
- Linguagem: "jornada", "presença", "caminhada" — NUNCA "streak" ou "🔥" na UI
- Visual: sutil, tipográfico, não gamificado. Ex: "7 dias com os Salmos"
- KPI: retenção D7 ≥ 35%

### D2 · Card de Compartilhamento
- Card visual por verso/salmo com identidade forte do app (cobalt + Playfair)
- Gerado direto da tela de leitura — 1 tap → share sheet nativo
- Design não pode ser mediano: card bonito = motor de crescimento real
- KPI: shares ≥ 5% dos DAU semanais

---

## Sprint E — Engajamento Profundo (5-6 semanas)

_Pré-requisito: D7 ≥ 35% validado. Meta: D14 de quem faz plano ≥ 20pp acima de quem não faz._

### E1 · Plano de 7 Dias por Emoção
- Aproveita picker emocional do onboarding — transforma escolha em jornada estruturada
- 1 salmo curado por dia × 7 dias, por emoção (8 planos = 8 coleções)
- Progress indicator simples: "Dia 3 de 7"
- V1 free: 1 plano (emoção escolhida no onboarding). V2 premium: todos os planos.
- KPI: ≥ 40% dos que iniciam completam o plano completo

### E2 · Áudio Offline Completo (pré-requisito do Modo Sono)
- Completar narração dos 150 salmos (hoje parcial)
- Modo sono **só entra depois** deste item concluído — sem narração humana boa, não lançar
- KPI: % salmos com áudio = 100%

---

## Sprint F — Distribuição Passiva (5-6 semanas)

_Pré-requisito: E1 validado. Meta: ≥ 15% sessões via widget em 30 dias._

### F1 · Widget Homescreen Android
- Salmo do Dia visível sem abrir app = recall passivo diário
- Widget básico = free. Widget com salmo escolhido/tema customizado = premium
- Referência: YouVersion (35% das sessões diárias via widget)
- KPI: ≥ 15% sessões originadas via widget após 30 dias

### F2 · Notificação Contextual por Emoção
- Push usa emoção salva do picker do onboarding
- Ex: "Sentindo ansiedade? O Salmo 91 foi escrito pra esse momento." vs. push genérico
- Opt-out 4x menor que push genérico (padrão Calm)
- KPI: opt-out notificação contextual ≤ 50% do opt-out da notificação genérica

---

## Backlog — Features Cortadas (revisitar com dados)

| Feature | Motivo do corte | Quando revisar |
|---------|----------------|----------------|
| Modo Sono | Depende de áudio offline completo (Sprint E2) | Após E2 |
| Reflexão Guiada (3 perguntas) | Esforço editorial + precisar audiência para validar | Após D validado |
| Diário Espiritual | Escopo grande, risco de privacidade, monetização incerta | v3+ |
| Conquistas / Selos | Risco de gamificação religiosa, sem fundação para premium | Nunca (risco alto) |
| Liturgia Católica | Requer pesquisa profunda (numeração LXX vs TM) | Só com consultor litúrgico |
| Velocidade de Narração | Feature de QoL — fazer junto com áudio offline, não sprint dedicado | Sprint E2 |
| Planos Compartilhados | Requer backend/auth — fora do escopo offline-first | v3+ |

---

## Internacionalização (i18n) — arquitetura preparada (pós-MVP)

Decisão (2026-06-25): **deixar a fundação pronta sem commitar idioma**. App nasce só PT-BR.
Não mexer no código durante o ciclo de teste/lançamento — executar i18n só depois do MVP no ar.

### Escopo real — 3 camadas (custo bem diferente)

| Camada | Conteúdo | Esforço | Fonte por idioma |
|---|---|---|---|
| **UI** (~50 labels) | "Ajustes", "Coleções", "Compartilhar", "Apoie o app"… (hoje hardcoded em PT) | Baixo, mecânico | tradução de strings |
| **Conteúdo bíblico** | 150 salmos × {título, versículos} + 8 coleções | Alto | **tradução bíblica de domínio público** (PT = Almeida 1911; ES = Reina-Valera 1909; EN = KJV) |
| **Reflexões** | 150 reflexões + perguntas (conteúdo **original**, fonte `assets/reflexoes-salmos.md`) | Alto, editorial | traduzir/adaptar uma a uma |
| **Áudio** | 150 narrações por idioma | Alto, scriptável | TTS no idioma via `gerar_audios.py` |

> A UI é barata. O caro é conteúdo + áudio: cada idioma novo ≈ 150 textos traduzidos + 150 reflexões + 150 narrações TTS.

### Arquitetura-alvo (quando executar)

- **UI:** adicionar `flutter_localizations` + `intl`, `l10n.yaml`, ARB por idioma (`app_pt.arb`, `app_es.arb`…). Migrar strings hardcoded de forma incremental. `supportedLocales` no `MaterialApp` + seletor de idioma em Ajustes.
- **Conteúdo:** quebrar `salmos.json` por idioma → `assets/content/salmos_<lang>.json` (mesma estrutura: `salmos[]` com numero/titulo/traducao/versiculos/temas/reflexao/audio/reflexao_pergunta). Carregar conforme locale.
- **Áudio:** pasta por idioma → `assets/audios/<lang>/salmo_NNN.mp3`. Campo `audio` no JSON vira relativo ao idioma. **Casa com o item "áudio sob demanda"** do backlog técnico — não embutir N idiomas no bundle; baixar só o idioma ativo.
- **Atribuição:** cada idioma exibe sua tradução/licença em Ajustes → "Sobre" (hoje: "João Ferreira de Almeida ed. 1911 — domínio público").

### Play Console (independente do app — fazer quando lançar idioma)
- Store listing por idioma: Console → **Presença na Play Store → Configurações da ficha → Idiomas e traduções** → adicionar idioma → traduzir título/descrições. **Não exige rebuild** do app.
- Screenshots podem ser reaproveitados ou localizados por idioma.

### Sequência recomendada
1. UI i18n primeiro (prova de conceito, baixo risco) — app fica bilíngue na casca, conteúdo segue PT
2. Um idioma completo de conteúdo+áudio como piloto (ES = maior ROI: LatAm católico/evangélico, Reina-Valera 1909 domínio público)
3. Medir adoção antes de abrir o 3º idioma

> **Não tocar no código agora.** Migração de strings = diff grande + re-test. Executar em branch dedicada pós-MVP.

---

## Batch v1.0.0+3 — "Hardening" (executar só APÓS o teste fechado passar)

Agrupar tudo que exige rebuild numa versão só. **Não rebuildar o AAB aprovado no meio do teste.**

| Item | O quê |
|---|---|
| R8 / minify | `isMinifyEnabled` + `isShrinkResources` = true (build.gradle.kts). Ganho modesto (áudio domina), mas melhora stack traces. |
| Remover AD_ID | `tools:node="remove"` na permissão do Firebase → então re-declarar "não usa ID de publicidade" no Console. Combina com o posicionamento sem anúncios. |
| Atualizar deps | firebase_core 3.6.0, flutter_local_notifications 17.2.2, share_plus 13.1.0 + resolver aviso KGP (firebase_analytics, in_app_review, share_plus). |
| DUMP | já removido no manifest (commit 72485d9) — entra neste build. |
| **Travessões nas strings de UI** | Tom humanizado (LP já limpa em 2026-07-13). 4 casos de **prosa** a trocar por ponto: `home_screen.dart:454`, `onboarding_screen.dart:362`, `leitura_salmo_screen.dart:338`, `notification_service.dart:70`. **MANTER** `compositor_screen.dart:61` (travessão de citação = norma tipográfica). Opcionais (separadores): `ajustes_screen.dart:197` e `:318`. `salmos.json` já está limpo (0/150). |
| Crashlytics | opcional: incluir gatilho temporário de crash pra revalidar. |

> Descrição da loja (`play-store/listing/aso-copy.md`, 22 travessões) **não** depende de rebuild — editar direto no Console quando quiser.

---

## Backlog Técnico — Otimização & Infra (pós-MVP)

Levantado durante a publicação na Play (2026-06-22). Nenhum bloqueia o lançamento.

| Item | Contexto | Tensão / cuidado |
|---|---|---|
| Tamanho do bundle (124MB AAB; 62MB de áudio) | Download real do usuário é menor (AAB split por ABI/densidade, ~50-70MB). Áudio já é mono 24kHz 32kbps MP3 — já enxuto. | Re-encode (24kbps ou HE-AAC) dá só ~20-35%. Ganho modesto vs. esforço (instalar ffmpeg + rebuild + re-test). |
| Áudio sob demanda (baixar no 1º play, CDN/Supabase) | Única alavanca que tira os 62MB do bundle. Supabase já existe no projeto Plantio (ref `rkpqpghtuacjxcomisle`). | **CONFLITA com "100% offline" da LP e com a decisão offline-first.** Só vale se cachear permanente após 1º download. Reconciliar com Sprint E2 (Áudio Offline Completo) antes de decidir — as duas direções se opõem. |
| Domínio omeusalmo.com.br | NXDOMAIN — não registrado. Privacy URL atual = github.io (funciona, não bloqueia loja). | Cloudflare **não** dá domínio grátis (só registro a preço de custo + DNS grátis). `.com.br` só via registro.br (~R$40/ano). Freenom morto, não usar. Ao comprar: apontar A records pros IPs do GitHub Pages (185.199.108-111.153) + CNAME www→omeusalmo.github.io. Desbloqueia App Links (assetlinks.json já pronto). |
| ~~**Hardening da API key Firebase**~~ ✅ FEITO 2026-07-09 | Key `AIzaSy...PtJQ` restrita por package `com.omeusalmo.salmos` + SHA-1 (assinatura + upload) no Cloud Console (projeto `o-meu-salmo`, não `meu-salmo`/TTS). | ✅ Validado 2026-07-12: crash de teste chegou no Crashlytics com a key restrita (build release local, cert de upload). |

---

## Decisões fixadas (não renegociar sem motivo)

| Decisão | Razão |
|---|---|
| Sem Google Play Billing no MVP | Sem mecanismo de monetização ainda |
| Ads + freemium no futuro (não IAP de compra) | Menor fricção de entrada, público católico/evangélico sensível a paywall |
| Android-first | 80%+ dos cristãos brasileiros usam Android |
| Offline-first (JSON local) | Usuários em zonas rurais, sem dados |
| Sem servidor backend no MVP | Zero custo operacional até ter retenção |

---

## KPIs de saúde do produto

| Métrica | Meta D30 | Crítico |
|---|---|---|
| Retenção D7 | >30% | <15% = revisar onboarding |
| Retenção D30 | >20% | <10% = pivotar conteúdo |
| Salmos lidos/sessão | >2 | <1 = problema de navegação |
| Taxa de compartilhamento | >5% das sessões | <1% = revisar compositor |
| Rating médio | >4.3 | <4.0 = atuar em reviews |

---

## Time de agentes

| Agente | Frente | Sprint atual |
|---|---|---|
| `gerente` | Estratégia, coordenação, ASO | Sprint A (A2) |
| `tech-lead-app` | Flutter, bugs, features | Sprint A (A5) + B3 |
| `tech-lead-lp` | Landing page, privacidade pública | Sprint A (A1) |
| `tech-lead-loja` | Play Console, screenshots, ASO copy | Sprint A (A2, A3) |
